import pandas as pd
import geopandas as gpd
import janitor
import numpy as np
from utils import *
from LLR import *
from pathlib import Path

import matplotlib.pyplot as plt
import statsmodels.formula.api as smf

import json

with open('params.json', 'r') as infile:
    params = json.load(infile)

def main():
    # Load electoral data
    election_data = load_election_data()

    elecs = election_data['elecs']
    decisive_incumbent_elecs = election_data['decisive_elecs']

    # Load geocoded contracts
    contracts_coded = gpd.read_file('../../data/out/contracts_geocoded.geojson')

    # We need to assign a ward to each contract. However, remember that district boundaries changed halfway through our sample!

    redistricting_date = '19jan2012'
    contracts_coded.approval_date = pd.to_datetime(contracts_coded.approval_date)

    contracts_coded = contracts_coded.to_crs('EPSG:3857')

    wards = load_ward_shapefiles()

    contracts = pd.concat([
            contracts_coded[contracts_coded.approval_date <= redistricting_date].sjoin(wards['pre'], how='left', predicate='intersects'),
            contracts_coded[contracts_coded.approval_date > redistricting_date].sjoin(wards['post'], how='left', predicate='intersects')
        ]).change_type('ward', int, ignore_exception='fillna').clean_names(remove_special = True)
    
    # Aggregate to the vendor-purchase order level, summing awards. This eliminates large negative transactions

    contracts = contracts.groupby(['purchase_order_contract_number', 'vendor_id']).agg({
        'ward': 'first',
        'award_amount': 'sum',
        'approval_date': 'first'
    }).reset_index()

    # Collapse to the ward-day level, keeping only contracts smaller than the 95th percentile in value
    # For each ward-day, count the number of contracts and their total value

    contracts_byday = contracts.query('ward.notna() & (award_amount < award_amount.quantile(0.95))').groupby([
        pd.Grouper(key='approval_date', freq='d'),
        'ward'
    ]).agg({
        'award_amount': 'sum',
        'vendor_id': 'count'
    }).reset_index().rename({'vendor_id': 'contract_count'}, axis=1)

    contracts['year'] = contracts.approval_date.dt.year

    contract_byward_counts = (
        contracts.query('ward.notna() & (award_amount < award_amount.quantile(0.95))')
        .groupby([
            'year',
            'ward'
        ])
        .approval_date
        .count()
    )

    # Delete the original geocoded contracts---saves quite a bit of memory
    del contracts_coded

    # Calculate demeaned (on ward and day) contract counts and award amounts

    for var in ['contract_count', 'award_amount']:
        adj_s = contracts_byday[var].copy()
        for grp in ['approval_date', 'ward']:
            s = contracts_byday.groupby(grp)[var].transform('mean')
            
            adj_s = adj_s - s
        
        contracts_byday[f'{var}_adj'] = -adj_s

    # For each election in the sample:
    out = []
    for _, row in decisive_incumbent_elecs.iterrows():
        ward = row.ward
        
        # Calculate the beginning of the "electoral period", as defined in the config file
        period_begin = pd.Timestamp(
            year = row.year + params['period_begin_year_offset'], 
            month=params['period_begin_month'], 
            day=params['period_begin_day']
        )

        period_end = row.elec_date
        
        period_len = (period_end - period_begin).days
        
        # Take the subset of contracts issued in that ward during the "electoral period"
        df_sub = contracts_byday[
            (contracts_byday.ward == ward) &
            (contracts_byday.approval_date >= period_begin) &
            (contracts_byday.approval_date < period_end)   
        ]
        
        # And collapse, taking the by-day mean of contract count and value (as well as demeaned versions thereof)
        results = df_sub[[
                'award_amount', 
                'contract_count', 
                'award_amount_adj', 
                'contract_count_adj',
            ]].sum().div(period_len).to_dict()
        
        unique_counts = len(contracts[
            (contracts.ward == ward) &
            (contracts.approval_date >= period_begin) &
            (contracts.approval_date < period_end)   
        ].vendor_id.unique())
        
        results['unique_vendors'] = unique_counts
        
        out.append(
            results
        )

    # Create a dataset at the election level, with one entry per incumbent election, with the contract values calculated above
    # merged in
    decisive_elections_contracts = decisive_incumbent_elecs.join(
        pd.DataFrame(out, index=decisive_incumbent_elecs.index)
    )

    # Calculate demeaned number of unique vendors
    decisive_elections_contracts['unique_vendors_res'] = (
        decisive_elections_contracts.unique_vendors -
        decisive_elections_contracts.groupby('year').unique_vendors.transform('mean') -
        decisive_elections_contracts.groupby('ward').unique_vendors.transform('mean') +
        decisive_elections_contracts.unique_vendors.mean()
    )

    # And define pretty names for all variables
    var_mapping = {
        'award_amount': 'Contract value awarded',
        'contract_count': 'Number of contracts awarded',
        'award_amount_adj': 'Contract value awarded (adj.)',
        'contract_count_adj': 'Number of contracts awarded (adj.)',
        'unique_vendors': 'Number of unique suppliers',
        'unique_vendors_res': 'Number of unique suppliers (adj.)',
    }

    bw = params['bw']
    num_elecs_in_bw = len(decisive_incumbent_elecs.query(f'margin.abs() < {bw/2}'))
    num_wards_in_bw = len(decisive_incumbent_elecs.query(f'margin.abs() < {bw/2}').ward.unique())

    out = []
    

    # Do the same LLR procedure done for turnout and services.
    for var in ['award_amount', 
                'contract_count', 
                'award_amount_adj', 
                'contract_count_adj',
                'unique_vendors',
                'unique_vendors_res'
            ]:
        print(f'Processing {var}')
        df = decisive_elections_contracts.copy()
        
        df[f'll_fit_{var}'] = local_linear_reg(
            df.margin.to_numpy(),
            df[var].to_numpy(),
            c=0,
            kernel=tri_K,
            bw=bw
        )
        
    #     integral = np.trapz(
    #         (m:=df.sort_values('margin'))[f'll_fit_{var}'].to_numpy(),
    #         m.margin.to_numpy()
    #     )
        
    #     print(integral)
        
    #     df[f'll_fit_{var}'] = df[f'll_fit_{var}'] / integral
    #     df[var] = df[var] / integral
        
        m = df.query('margin.abs() < 0.5').sort_values('margin')

        fix,ax = plt.subplots()

        m.query('margin < 0').plot(x='margin', y=f'll_fit_{var}', ax=ax, color='k', legend=False)
        m.query('margin > 0').plot(x='margin', y=f'll_fit_{var}', ax=ax, color='k', legend=False)

        m.plot.scatter(x='margin', y = var, ax=ax, marker='.', color='0.5')
        plt.axvline(0, color='k', linestyle=':')
        
        plt.xlabel('Margin')
        plt.ylabel(var_mapping[var])
        
        plt.savefig(f'../../outputs/figures/procurement/{var}.pdf')
        

        
        m_plus = m.query('winner == 1').margin.head(1).item()
        f_plus = m.query('winner == 1')[f'll_fit_{var}'].head(1).item()
        m_minus = m.query('winner != 1').margin.tail(1).item()
        f_minus = m.query('winner != 1')[f'll_fit_{var}'].tail(1).item()
        
        theta = np.log(f_plus) - np.log(f_minus)
        sigma_theta = sigma(len(df), bw, f_plus, f_minus)
        
        t_stat_l = theta / sigma_theta
        
        print(f"(LOGGED) theta = {theta}, sigma = {sigma_theta}, t = {t_stat_l}")
        
        p1 = local_linear_reg_backend(
            m_plus,
            df.margin.to_numpy(),
            df[var].to_numpy(),
            c=0,
            kernel=tri_K,
            bw=bw,
            groups = df.ward.to_numpy()
        )

        p0 = local_linear_reg_backend(
            m_minus,
            df.margin.to_numpy(),
            df[var].to_numpy(),
            c=0,
            kernel=tri_K,
            bw=bw,
            groups = df.ward.to_numpy()
        )

        mean_diff = p1.params[0] - p0.params[0]

        var_diff = p1.cov_params()[0,0] + p0.cov_params()[0,0]

        t_stat = mean_diff / np.sqrt(var_diff)


        print(f"theta = {mean_diff}, sigma = {np.sqrt(var_diff)}, t = {t_stat}\n")
        
        out.append({
            'var': var,
            'theta_l': theta,
            'sigma_l': sigma_theta,
            't_stat_l': t_stat_l,
            'p_value_l': scipy.stats.t(len(df)-2).pdf(t_stat_l),
            'theta': mean_diff,
            'sigma': np.sqrt(var_diff),
            't_stat': t_stat,
            'p_value_l': scipy.stats.t(len(df)-2).pdf(t_stat),
        })

    contracts_results = pd.DataFrame(out)

    contract_data = {'NO_ELECS': num_elecs_in_bw, 'NO_WARDS': num_wards_in_bw}

    for _, row in contracts_results.iterrows():
        if row['var'] == 'contract_count':
            prefix = 'VAR0'
        elif row['var'] == 'contract_count_adj':
            prefix = 'VAR1'
        elif row['var'] == 'award_amount':
            prefix = 'VAR2'
        elif row['var'] == 'award_amount_adj':
            prefix = 'VAR3'
        else:
            continue
        
        contract_data[prefix + '_MEAN'] = row.theta
        contract_data[prefix + '_SE'] = row.sigma
        contract_data[prefix + '_STARS'] = make_stars(t_test(row.t_stat, num_wards_in_bw - 2))
        

    with open('../../outputs/tables/contracts_table.tex', 'w') as outfile:
        outfile.write(load_template('../../outputs/templates/contracts_template.tex').format(**contract_data))

if __name__ == '__main__':
    main()
    Path('../../outputs/figures/procurement/procurement.txt').touch()