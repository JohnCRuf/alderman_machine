import pandas as pd
import numpy as np
import scipy


def load_election_data():
    elecs = pd.read_parquet('../../data/out/alder_results_incumbency.parquet')

    elecs['incumbent_victory'] = (elecs.incumbent & elecs.winner).astype(int)

    elecs['runoff'] = ((elecs.winner) & (elecs.elec_type == 'runoff')).astype(int)

    elec_results = elecs.groupby(['ward', 'year']).agg({
        'margin': 'max',
        'incumbent': np.any,
        'incumbent_victory': np.any,
        # 'close_election': np.any,
        'runoff': np.any
    }).reset_index().rename({'year': 'election_year'}, axis=1)

    elec_results.ward = elec_results.ward.astype(float)

    elec_dates = pd.read_csv('../../data/raw/election_dates.csv')
    elec_dates.general_date = pd.to_datetime(elec_dates.general_date, format='%d%b%Y')
    elec_dates.runoff_date = pd.to_datetime(elec_dates.runoff_date, format='%d%b%Y')
    elec_dates.term_date = pd.to_datetime(elec_dates.term_date, format='%d%b%Y')

    elec_dates_l = elec_dates.melt(id_vars='election_year', var_name='elec_type', value_name='elec_date')
    elec_dates_l = elec_dates_l.rename({'election_year': 'year'}, axis=1)
    elec_dates_l.elec_type = elec_dates_l.elec_type.str.replace(r'_[\s\S]+', '', regex=True)

    elecs = elecs.merge(
        elec_dates_l,
        how='left',
        on=['year', 'elec_type']
    )

    elec_results = elec_results.merge(
        elec_dates,
        how='left',
        on='election_year'
    )

    elecs['election_decided'] = elecs.groupby(['ward', 'elec_type', 'year']).winner.transform(np.any)
    elecs['election_year'] = elecs.elec_name.str.extract(r'(\d\d\d\d)').astype(int)

    total_votes = elecs.groupby(['year', 'elec_type', 'ward']).total_votes.sum().reset_index()

    total_votes_offset = elecs.query('election_decided').groupby(['year', 'ward']).total_votes.sum().reset_index()
    total_votes_offset.year += 4
    total_votes_offset.rename({'total_votes': 'total_votes_L1'}, axis=1, inplace=True)

    total_votes = total_votes.merge(
        total_votes_offset,
        how='left',
        on=['ward', 'year'],
        validate='m:1'
    )

    decisive_incumbent_elecs = elecs.query('election_decided & incumbent & (year >= 2007)')

    decisive_incumbent_elecs = decisive_incumbent_elecs.drop('total_votes', axis=1).merge(
        total_votes,
        how='left',
        on=['year', 'elec_type', 'ward'],
        validate='1:1'
    )

    return {
        "elecs": elecs,
        "decisive_elecs": decisive_incumbent_elecs
    }

def load_template(fname):
    with open(fname, 'r') as infile:
        template = infile.read()
    
    template = template.replace('{', '{{').replace('}', '}}').replace('⟪', '{').replace('⟫', '}')
    return template

def make_stars(p):
    if p < 0.01:
        return '$^{***}$'
    if p < 0.05:
        return '$^{**}$'
    if p < 0.1:
        return '$^{*}$'
    return ''

def t_test(t, dof):
    return scipy.stats.t(dof).pdf(t)