## data geomatch contributions
This task uses the census and google maps APIs to geocode each individual contribution to a specific alderman and save the results as a CSV.

## Output
* `geomatched_(Alder)_contributions_(map).csv`: Contains the amount, ward, and precinct where a specific campaign contribution was made as well as the geographic coordinates of the contribution address.

## Code
* `geomatch_campaign_contributions.R`: This script takes the geographic coordinates of each contribution and matches them to a ward and precinct for a given map.

## Inputs
* `geocoded_(Alder)_contributions.csv`: A dataset containing every contribution to a specific alderman, taken from the Illinois campaign contribution database.