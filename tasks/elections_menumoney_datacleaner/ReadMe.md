# elections_menumoney_datacleaner
    This task collects menu expenditures data and merges it with election data to create a dataset of menu expenditures by Alderman. 

## Output
* `menu_panel_df.csv`: A panel dataset of menu expenditures by alderman, with election data merged in.
## Input
* `menu_2005_2010.csv`: A CSV of menu expenditures by alderman for the years 2005-2010
* `menu_2011_2015.csv`: A CSV of menu expenditures by alderman for the years 2012-2015
* `menu_2016_2022.csv`: A CSV of menu expenditures by alderman for the years 2016-2022
* `elections.csv`: A CSV of election data for the years 2003-2022
## Code
* `menu_money_cleaner.R`: A script that merges the menu expenditure data with election data and creates a panel dataset.

This code borrows heavily from the City Bureau's aldermanic menu money repo, available here:
https://github.com/City-Bureau/aldermanic-menu-money