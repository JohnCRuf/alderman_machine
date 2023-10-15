# produce_menu_maps
    This task creates a set of figures illustrating ward-level menu money expenditures.

    “You take care of the people who take care of you — you know, the people who voted for you. That’s not Chicago politics, that’s Politics 101.” - Bernie Stone

## Output
* `ward_#_money_map_year1_year2.png`: A map of ward in ward # with menu money spending from year1 to year2.

## Code
* `menu_title_mapper.R`: A set of function that maps arguments to detailed legends and titles for the maps.
* `menu_money_map_production.R`: Creates a map of menu money spending for a given ward from year1 to year2.

## Inputs
* `incumbent_challenger_voteshare_df_precinct_level.csv`: Precinct level vote counts, ward level vote counts and shares, and an incumbency dummy for each candidate in each election.
* `ward_precinct_menu_panel_2003_2011.rds`: A panel dataset of menu expenditures by ward, 2003-2011 precinct, and year.
* `ward_precinct_menu_panel_2012_2022.rds`: A panel dataset of menu expenditures by ward, 2003-2011 precinct, and year.