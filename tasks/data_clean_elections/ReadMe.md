# Data Clean Elections
    This task processes the data scraped in the data_scrape_elections task and creates voteshare and incumbency variables for each candidate in each election.

## Output
* `incumbent_voteshare_df_ward_level.csv`: Ward-level vote counts, vote shares, and an incumbency dummy for each candidate in each election.
* `incumbent_challenger_voteshare_df_precinct_level.csv`: Precinct level vote counts, ward level vote counts and shares, and an incumbency dummy for each candidate in each election.
## Code
* `ward_level_elections_incumbent_cleaning.R`: Creates ward-level voteshare and incumbency variables for each candidate in each election, and cleans names of candidates.
* `precinct_level_elections_incumbent_cleaning.R`: Creates precinct-level voteshare and incumbency variables for each candidate in each election, and cleans names of candidates.  

## Input
* `elections.csv`: A CSV file containing precinct-level voting counts for each candidate in each election.