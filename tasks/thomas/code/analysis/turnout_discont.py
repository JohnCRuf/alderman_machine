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

def main():
    # Load electoral data
    election_data = load_election_data()

    elecs = election_data['elecs']
    decisive_incumbent_elecs = election_data['decisive_elecs']

    # Calculate adjusted values by two methods: year-ward fixed effects, and controlling for lagged turnout (and the combination)
    # of the two
    decisive_incumbent_elecs['total_votes_adj'] = (decisive_incumbent_elecs.total_votes - smf.ols(
        'total_votes ~ 1 + total_votes_L1',
        data=decisive_incumbent_elecs
    ).fit().predict(decisive_incumbent_elecs))

    decisive_incumbent_elecs['total_votes_FE'] = (decisive_incumbent_elecs.total_votes - smf.ols(
        'total_votes ~ 1 + C(ward) + C(year)',
        data=decisive_incumbent_elecs
    ).fit().predict(decisive_incumbent_elecs))

    decisive_incumbent_elecs['total_votes_adj_FE'] = (decisive_incumbent_elecs.total_votes - smf.ols(
        'total_votes ~ 1 + total_votes_L1 + C(ward) + C(year)',
        data=decisive_incumbent_elecs
    ).fit().predict(decisive_incumbent_elecs))

    # Assign nice names to each output variable
    var_mapping = {
        'total_votes': 'Turnout',
        'total_votes_adj': 'Turnout Residual (Lag)',
        'total_votes_FE': 'Turnout Residual (FE)',
        'total_votes_adj_FE': 'Turnout Residual (Lag, FE)',
    }

    out = []
    bw = params['bw']

    decisive_incumbent_elecs.total_votes = decisive_incumbent_elecs.total_votes.astype(float)

    num_elecs_in_bw = len(decisive_incumbent_elecs.query(f'margin.abs() < {bw/2}'))
    num_wards_in_bw = len(decisive_incumbent_elecs.query(f'margin.abs() < {bw/2}').ward.unique())

    # For each output, calculate a nonparametric fit and compute the magnitude (and SE) of discontinuity

    for var in ['total_votes', 'total_votes_adj', 'total_votes_FE', 'total_votes_adj_FE']:
        print(f'Processing {var}')
        df = decisive_incumbent_elecs.copy()
        
        if var == "award_amount_adj":
            df = df.query('award_amount_adj > 0').copy()
        
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

        # And make a nice picture of the discontinuity (we don't use all of these.)

        fix,ax = plt.subplots()

        m.query('margin < 0').plot(x='margin', y=f'll_fit_{var}', ax=ax, color='k', legend=False)
        m.query('margin > 0').plot(x='margin', y=f'll_fit_{var}', ax=ax, color='k', legend=False)

        m.plot.scatter(x='margin', y = var, ax=ax, marker='.', color='0.5')
        plt.axvline(0, color='k', linestyle=':')
        
        plt.xlabel('Margin')
        plt.ylabel(var_mapping[var])
        
        plt.savefig(f'../../outputs/figures/turnout/{var}.pdf')
        
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

    # And write all the results to a table

    turnout_results = pd.DataFrame(out)

    turnout_data = {'NO_ELECS': num_elecs_in_bw, 'NO_WARDS': num_wards_in_bw}

    for i, row in turnout_results.iterrows():
        turnout_data[f'VAR{i}_MEAN'] = row.theta
        turnout_data[f'VAR{i}_SE'] = row.sigma
        turnout_data[f'VAR{i}_STARS'] = make_stars(t_test(row.t_stat, num_wards_in_bw - 2))


    with open('../../outputs/tables/turnout_discontinuity.tex', 'w') as outfile:
        outfile.write(load_template('../../outputs/templates/turnout_template.tex').format(**turnout_data))


if __name__ == '__main__':
    main()
    Path('../../outputs/figures/turnout/turnout.txt').touch()