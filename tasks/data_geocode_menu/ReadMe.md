# data_geolocate_menu
    This task uses the census and google maps APIs to geolocate each construction project and save the results as a CSV. 

## Output
* `geolocated_menu.csv`: A CSV file containing the menu money allocation cost, the ward, year, and the geographic coordinates of the project.

## Code
* `clean_menu_location.R`: This script cleans the menu money data's location column to prepare it for geolocation.
* `geolocate_menu_expenditures.R`: This script geolocates the menu money data using the census and google maps APIs.

## Inputs
* `menu_category_panel_df.csv`: A panel dataset of menu expenditures by alderman, with election data merged in.