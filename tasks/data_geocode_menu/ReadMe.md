# data_geocode_menu
    This task uses the census and google maps APIs to geocode each construction project and save the results as a CSV.

    Note that this repo distinguishes between geocoding and geomatching. We use geocoding to mean the process of finding the geographic coordinates of a location from a text format, while geomatching means the process of matching coordinates to a geographic boundary. This task only performs geocoding.

## Output
* `geocoded_(format)_df.csv`: A CSV file containing the menu money allocation cost, the ward, year, and the geographic coordinates of the project location for a specific location text format.
The location text formats include "2 ands," "3 ands," "double dash to," "from to," "intersection", "normal address," "school park," "through address," and "leftover."

Leftover contains the uncategorized location text formats and are just fed into the google maps API as a last-ditch effort to geocode the project. 
There are currently ~700 leftover projects from the ~45000 total projects.


## Code
* `clean_menu_location.R`: This script cleans the menu money data's location column to prepare it for geocoding.
* `geocode_menu_expenditures.R`: This script geocodes the menu money data using the census and google maps APIs.

## Inputs
* `menu_category_panel_df.csv`: A panel dataset of menu expenditures by alderman, with election data merged in.