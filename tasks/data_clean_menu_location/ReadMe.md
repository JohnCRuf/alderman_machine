# data_clean_menu_location
    This task cleans the text-based location data from the menu money data to prepare it for geolocation.

## Output
* `df_(format).csv`: A CSV file containing the menu money allocation cost, the ward, year, and the text-based descriptive and location data for a specific location text format.

## Code
* `clean_menu_location.R`: This script cleans the menu money data's location column to prepare it for geolocation. 
It does this by splitting the data by location text format and then cleaning each format individually.


## Inputs
* `menu_df.csv`: A panel dataset of menu expenditures by ward.