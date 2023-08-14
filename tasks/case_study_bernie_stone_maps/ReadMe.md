# case_study_bernie_stone
    This task creates a set of figures illustrating Bernie Stone's menu money expenditures and election results.

    “You take care of the people who take care of you — you know, the people who voted for you. That’s not Chicago politics, that’s Politics 101.” - Bernie Stone

## Output
* `stone_menu_money_spending_map_2005_2011.png`: A map of Bernie Stone's menu money spending by precinct from 2005 to 2011.
* `stone_(year)_(type)_precinct_(outcome).png`: A map of Bernie Stone's (year) (type) election (results/turnout) by precinct.


## Code
* `stone_menu_money_map.R`: Creates a map of Bernie Stone's menu money spending by precinct from 2005 to 2011.
* `stone_election_results_map.R`: Creates a map of Bernie Stone's election results by precinct given a specific year and type.
* `stone_menu_voting_scatterplot.R`: Creates a scatterplot of Bernie Stone's menu money spending by precinct against net votes for him in a specific election.
* `prepare_stone_data.R`: Prepares the data for the above scripts by merging the inputs.

## Inputs
* `incumbent_challenger_voteshare_df_precinct_level.csv`: Precinct level vote counts, ward level vote counts and shares, and an incumbency dummy for each candidate in each election.
* `ward_precinct_menu_panel_2003_2011.rds`: A panel dataset of menu expenditures by ward, 2003-2011 precinct, and year.