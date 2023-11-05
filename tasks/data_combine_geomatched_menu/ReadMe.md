# data_combine_geomatched
    This task compiles the geomatched data into singular .rds and .csv files for all allocations between 2003 and 2022, under the 2003 through 2012 ward-precinct boundaries.
## Output
* `ward_precinct_menu_panel_2003_2011.csv`: 
A csv file containing the sum of the area-weighted menu money cost allocation for each precinct in the 2003-2011 ward-precinct boundaries for each year between 2003 and 2022.
* `ward_precinct_menu_panel_2003_2011.rds`: 
An rds file containing the sum of the area-weighted menu money cost allocation for each precinct in the 2003-2011 ward-precinct boundaries for each year between 2003 and 2022. Ward and precinct shapes are also stored.

* `ward_precinct_menu_panel_2012_2022.csv`: 
A csv file containing the sum of the area-weighted menu money cost allocation for each precinct in the 2012-2022 ward-precinct boundaries for each year between 2003 and 2022.
* `ward_precinct_menu_panel_2012_2022.rds`: 
An rds file containing the sum of the area-weighted menu money cost allocation for each precinct in the 2012-2022 ward-precinct boundaries for each year between 2003 and 2022. Ward and precinct shapes are also stored.


## Code
* `combine_geomatched.r`: Combines all of the precinct-map geomatched files into one dataframe, binds them to the map, and assigns 0 to all values that are in the map but not in the dataframe.

## Inputs
* `geomatched_(format)_df_(shape/line/point).csv`: A CSV file containing the menu money allocation cost, the ward, year, and the geographic coordinates of the project location for a specific location text format for shapes, lines, and points.

Due to missing geocoordiantes, projects that should be shapes or lines are often geomatched as singular points.
The location text formats include "points," "lines," "quad," and "pent"

Leftover contains the uncategorized location text formats and are just fed into the google maps API as a last-ditch effort to geocode the project. 
There are currently ~300 leftover projects from the ~45000 total projects.
