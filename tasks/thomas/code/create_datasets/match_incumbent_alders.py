import pandas as pd
import numpy as np
import janitor
import nltk

import statsmodels.formula.api as smf

def main():
    alder_results = pd.read_parquet('../../data/out/alder_results.parquet')

    alder_results['pct'] = alder_results.votes / alder_results.total_votes

    ward_results = alder_results.filter_on('precinct == "Total"').copy()

    ward_results['place'] = ward_results.groupby('elec_id').pct.rank(method='dense', ascending=False)

    ward_results['margin'] = 2 * (ward_results.pct - 0.5)
    ward_results['winner'] = ward_results.margin > 0

    ward_results = ward_results.reset_index(drop=True)
    ward_results['idx'] = ward_results.index

    ward_results['wardyear'] = ward_results.year * 100 + ward_results.ward

    incumbents = pd.read_parquet('../../data/out/incumbents.parquet')
    incumbents['wardyear'] = incumbents.year * 100 + incumbents.ward

    match_df = incumbents.merge(
        ward_results.loc[ward_results.elec_type == 'general', ['idx', 'candidate', 'wardyear']],
        how='left',
        on='wardyear'
    )

    match_df.name = match_df.name.str.title().str.replace(r"[^\w\s]", "", regex=True).str.strip()
    match_df.candidate = match_df.candidate.str.title().str.replace(r"[^\w\s]", "", regex=True).str.strip()

    match_df['name_score'] = [
        nltk.distance.jaro_winkler_similarity(a,b)
        for
        a,b
        in
        zip(
            match_df.name,
            match_df.candidate
        )
    ]

    matches = match_df.sort_values('name_score', ascending=False).groupby('wardyear').head(1)

    goodmatches = matches.filter_on('name_score > 0.7').copy()
    goodmatches['incumbent'] = True

    ward_results_inc = ward_results.merge(goodmatches[['idx', 'incumbent']], how='left', on='idx')

    ward_results_inc.incumbent = ward_results_inc.groupby(['ward', 'year', 'candidate']).incumbent.transform('max').fillna(False)

    ward_results_inc.to_parquet('../../data/out/alder_results_incumbency.parquet', index=False)

if __name__ == '__main__':
    main()