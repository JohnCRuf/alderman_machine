# data_geocode_menu
    This task uses the census and google maps APIs to geocode each individual contribution to a specific alderman and save the results as a CSV.

    Note that this repo distinguishes between geocoding and geomatching. We use geocoding to mean the process of finding the geographic coordinates of a location from a text format, while geomatching means the process of matching coordinates to a geographic boundary. This task only performs geocoding.

## Output
* `geocoded_(alderman)_df.csv`: A CSV file containing the menu money allocation cost, the ward, year, and the geographic coordinates of the contribution address for a specific location text format.


## Code
* `geocode_contributions.R`: This script filters the campaign contribution data to only include in-state individual contributions geocodes each individual's address data using the census and google maps APIs.

## Inputs
* `(alderman)_receipts.csv`: A dataset containing every contribution to a specific alderman, taken from the Illinois campaign contribution database.


This task only takes a few minutes to run per alderman.