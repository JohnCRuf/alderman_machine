# Data Clean Elections
    This task processes the data scraped in the data_scrape_elections task and creates voteshare and incumbency variables for each candidate in each election.

## Output
* `incumbent_voteshare_df.csv`: A CSV file containing ward-level vote counts, vote shares, and an incumbency dummy for each candidate in each election.
## Code
* `elections_incumbent_cleaning.R`: Creates voteshare and incumbency variables for each candidate in each election, and cleans names of candidates and parties. 

## Input
* `elections.csv`: A CSV file containing precinct-level voting counts for each candidate in each election.