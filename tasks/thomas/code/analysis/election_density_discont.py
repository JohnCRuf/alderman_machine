import pandas as pd
import numpy as np
from utils import *
from LLR import *

import matplotlib.pyplot as plt

import json

with open('params.json', 'r') as infile:
    params = json.load(infile)

def main():
    election_data = load_election_data()

    elecs = election_data['elecs']
    decisive_incumbent_elecs = election_data['decisive_elecs']

    hist_points = np.arange(-1, 1.0001, 0.01)
    binsize = (hist_points.max() - hist_points.min()) / (len(hist_points) - 1)

    a,b = np.histogram(
            decisive_incumbent_elecs.margin, 
            bins = hist_points
        )

    margin_df = pd.DataFrame(
        np.dstack((b[:-1],a))[0],
        columns = ['margin', 'freq']
    )

    n = margin_df.freq.sum()

    margin_df.freq = margin_df.freq / (binsize * n)

    margin_df['winner'] = (margin_df.margin >= 0).astype(int)
    margin_df['margin_mp'] = margin_df.margin + binsize / 2

    bw = params['bw']

    num_elecs_in_bw = len(decisive_incumbent_elecs.query(f'margin.abs() < {bw/2}'))
    num_wards_in_bw = len(decisive_incumbent_elecs.query(f'margin.abs() < {bw/2}').ward.unique())

    margin_df['ll_est'] = local_linear_reg(
        margin_df.margin_mp.to_numpy(),
        margin_df.freq.to_numpy(),
        c=0,
        kernel=tri_K,
        bw=bw
    )

    plt.plot((m:=margin_df.query('margin<0')).margin_mp, m.ll_est, color='k')
    plt.plot((m:=margin_df.query('margin>=0')).margin_mp, m.ll_est, color='k')
    plt.axvline(0, color='k', linestyle=':')

    plt.scatter(margin_df.margin_mp, margin_df.freq, marker='.', color='k')
    plt.ylim((0,4))

    plt.xlabel('Margin')
    plt.ylabel('Density')

    plt.savefig('../../results/figures/electoral_density.pdf')

    m_plus = margin_df.query('winner == 1').head(1).margin_mp.item()
    f_plus = margin_df.query('winner == 1').head(1).ll_est.item()
    m_minus = margin_df.query('winner == 0').tail(1).margin_mp.item()
    f_minus = margin_df.query('winner == 0').tail(1).ll_est.item()

    theta = (
        np.log(f_plus) - np.log(f_minus)
    )

    p1 = local_linear_reg_backend(
        m_plus,
        margin_df.margin_mp.to_numpy(),
        margin_df.freq.to_numpy(),
        c=0,
        kernel=tri_K,
        bw=bw
    )

    p0 = local_linear_reg_backend(
        m_minus,
        margin_df.margin_mp.to_numpy(),
        margin_df.freq.to_numpy(),
        c=0,
        kernel=tri_K,
        bw=bw
    )

    mean_diff = p1.params[0] - p0.params[0]

    var_diff = p1.cov_params()[0,0] + p0.cov_params()[0,0]
    se_diff = np.sqrt(var_diff)

    t_stat = mean_diff / np.sqrt(var_diff)

    print(mean_diff)
    print(var_diff)
    print(t_stat)

    sigma_theta = sigma(n, bw, f_plus, f_minus)

    res_table = load_template('../../results/templates/hist_template.tex').format(**{
        'LEVEL_MEAN_EST': mean_diff,
        'LEVEL_SE': se_diff,
        'LEVEL_STARS': make_stars(t_test(mean_diff / se_diff, num_wards_in_bw - 2)),
        'LOGGED_MEAN_EST': theta,
        'LOGGED_SE': sigma_theta,
        'LOGGED_STARS': make_stars(t_test(theta / sigma_theta, num_wards_in_bw - 2)),
        'NO_ELECS': num_elecs_in_bw,
        'NO_WARDS': num_wards_in_bw
    })

    with open('../../results/tables/base_discont_table.tex', 'w') as outfile:
        outfile.write(res_table)

    
if __name__ == '__main__':
    main()