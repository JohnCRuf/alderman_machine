# case_study_bernie_stone_eventstudy
    This task creates a set of figures analyzing the impacts of Bernie Stone being voted out of office in 2011.

## Output
* `stone_menu_money_spending_eventstudy.png`: A time line of The 50th ward's menu spending by year, by percentile of precinct that voted for Bernie Stone in 2007.


## Code
* `data_prep_stone_es.R`: This script prepares the data for the event study.
* `ward_50_event_study.R`: This script creates the event study plot.

## Inputs
* `incumbent_challenger_voteshare_df_precinct_level.csv`: Precinct level vote counts, ward level vote counts and shares, and an incumbency dummy for each candidate in each election.
* `ward_precinct_menu_panel_2003_2011.rds`: A panel dataset of menu expenditures by ward, 2003-2011 precinct, and year.