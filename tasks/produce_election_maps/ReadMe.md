# case_study_bernie_stone
    This task creates a set of figures illustrating  ward election results and turnout.


## Output
* `ward_#_year_type_incumbent_precinct_results.png`: A map of net votes for the incumbent in ward # in year for election type.
* `ward_#_year_type_incumbent_precinct_turnout.png`: A map of overall turnout in ward # in year for election type.


## Code
* `map_election_results.R`: Creates a map of election results for a given ward, year, and election type.
* `map_election_turnout.R`: Creates a map of election turnout for a given ward, year, and election type.


## Inputs
* `incumbent_challenger_voteshare_df_precinct_level.csv`: Precinct level vote counts, ward level vote counts and shares, and an incumbency dummy for each candidate in each election.
* `ward_precinct_menu_panel_2003_2011.rds`: A panel dataset of menu expenditures by ward, 2003-2011 precinct, and year.