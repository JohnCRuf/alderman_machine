# data_combine_geomatched_contributions
    This task compiles the geomatched campaign contribution data into a singular .rds file for all allocations between 2003 and 2022, under the 2003 through 2012 ward-precinct boundaries.
## Output
* `$(alderman)_contribution_panel_(year-year).rds`: 
A csv file containing the sum of the area-weighted menu money cost allocation for each precinct in the (year-year) ward-precinct boundaries for each year between 2003 and 2022.

## Code
* `combine_geomatched_contributions.r`: Combines the individual contribution panel into a summed annual panel for each precinct in the city of Chicago.

## Inputs
* `geomatched_(Alder)_contributions_(map).csv`: Contains the amount, ward, and precinct where a specific campaign contribution was made as well as the geographic coordinates of the contribution address.
