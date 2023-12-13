import pandas as pd
import numpy as np
from utils import *
from LLR import *
from pathlib import Path

import matplotlib.pyplot as plt
import statsmodels.formula.api as smf

import json

with open('params.json', 'r') as infile:
    params = json.load(infile)

# This function, for a generic service, loads the preprocessed data, applies the standard demeaning proedure,
# does the nonparametric fit, and reports the magnitude and SE of the discontinuity for service count and response time
def calculate_service(service_type):
    # Load electoral data
    election_data = load_election_data()

    elecs = election_data['elecs']
    decisive_incumbent_elecs = election_data['decisive_elecs']

    service_req_all = pd.read_parquet(f'../../data/out/{service_type}.parquet')

    service_req_all['duration_res'] = (
        service_req_all.duration
        - service_req_all.groupby(pd.Grouper(key='created_date', freq='M')).duration.transform('mean')
        - service_req_all.groupby('ward').duration.transform('mean')
        + service_req_all.duration.mean()
    )

    service_reqs_byday = (
        service_req_all
        .groupby([pd.Grouper(key='created_date', freq='d'), 'ward'])
        .sr_number
        .count()
        .unstack()
        .fillna(0)
        .stack(level=-1)
        .rename(service_type)
        .reset_index()
    )

    service_reqs_byday[f'{service_type}_res'] = (
        service_reqs_byday[service_type]
        - service_reqs_byday.groupby('created_date')[service_type].transform('mean')
        - service_reqs_byday.groupby('ward')[service_type].transform('mean')
        + service_reqs_byday[service_type].mean()
    )

    out = []

    for _, row in decisive_incumbent_elecs.iterrows():
        ward = row.ward
        
        period_begin = pd.Timestamp(year = row.year + params['period_begin_year_offset'], 
                                    month=params['period_begin_month'],
                                    day=params['period_begin_day']
                                    )
        
        period_end = row.elec_date
        
        period_len = (period_end - period_begin).days
        
        df_sub = service_reqs_byday[
            (service_reqs_byday.ward == ward) &
            (service_reqs_byday.created_date >= period_begin) &
            (service_reqs_byday.created_date < period_end)
            
        ]
        
        res = df_sub[[
                service_type, 
                f'{service_type}_res'
            ]].sum().div(period_len)
        
        df2_sub = service_req_all[
            (service_req_all.ward == ward) & 
            (service_req_all.created_date >= period_begin) &
            (service_req_all.created_date < period_end)
        ]
        
        res['duration'] = df2_sub.duration.mean()
        res['duration_res'] = df2_sub.duration_res.mean()
        
        out.append(
            res
        )

    decisive_election_values = decisive_incumbent_elecs.join(
        pd.DataFrame(out, index=decisive_incumbent_elecs.index)
    )

    decisive_election_values[service_type] = decisive_election_values[service_type].replace({0: np.nan})
    decisive_election_values[f'{service_type}_res'] = decisive_election_values[f'{service_type}_res'].replace({0: np.nan})

    decisive_election_values.duration = decisive_election_values.duration.dt.total_seconds() / (60 * 60 * 24)
    decisive_election_values.duration_res = decisive_election_values.duration_res.dt.total_seconds() / (60 * 60 * 24)

    var_mapping = {
        service_type: service_type.title(),
        f'{service_type}_res': f'{service_type.title()} (FE)',
        'duration': 'Service time',
        'duration_res': 'Service time (FE)'
    }

    out = []
    bw = params['bw']

    for var in [service_type, 
                f'{service_type}_res',
                'duration',
                'duration_res'
            ]:
        print(f'Processing {var}')
        df = decisive_election_values.copy()
        
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
        
        plt.savefig(f'../../outputs/figures/services/{var}.pdf')
        

        
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

    results = pd.DataFrame(out).set_index('var')

    return results

def main():
    election_data = load_election_data()

    elecs = election_data['elecs']
    decisive_incumbent_elecs = election_data['decisive_elecs']

    bw = params['bw']
    num_elecs_in_bw = len(decisive_incumbent_elecs.query(f'margin.abs() < {bw/2}'))
    num_wards_in_bw = len(decisive_incumbent_elecs.query(f'margin.abs() < {bw/2}').ward.unique())

    potholes_results = calculate_service('potholes')
    rats_results     = calculate_service('rats')
    graffiti_results = calculate_service('graffiti')

    services_results = {'NO_ELECS': num_elecs_in_bw, 'NO_WARDS': num_wards_in_bw}

    def prep_results(prefix, series):
        return {
            f'{prefix}_MEAN': series.theta,
            f'{prefix}_SE':   series.sigma,
            f'{prefix}_STARS': make_stars(t_test(series.t_stat, num_wards_in_bw - 2))
        }

    services_results.update(
        prep_results('VAR0', rats_results.loc['duration'])
    )

    services_results.update(
        prep_results('VAR1', rats_results.loc['duration_res'])
    )

    services_results.update(
        prep_results('VAR2', graffiti_results.loc['duration'])
    )

    services_results.update(
        prep_results('VAR3', graffiti_results.loc['duration_res'])
    )

    services_results.update(
        prep_results('VAR4', potholes_results.loc['duration'])
    )

    services_results.update(
        prep_results('VAR5', potholes_results.loc['duration_res'])
    )

    res_table = load_template('../../outputs/templates/services_template.tex').format(**services_results)

    with open('../../outputs/tables/services_table.tex', 'w') as outfile:
        outfile.write(res_table)

if __name__ == '__main__':
    main()
    Path('../../outputs/figures/services/services.txt').touch()