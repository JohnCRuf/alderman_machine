# data_geomatch_menu
    This task geomatches the menu money data to the ward boundaries for 2003-2011 and 2012-2022.

    Note that this repo distinguishes between geocoding and geomatching. We use geocoding to mean the process of finding the geographic coordinates of a location from a text format, while geomatching means the process of matching coordinates to a geographic boundary. This task only performs geomatching.
## Output
* `geomatched_(format)_df_(shape/line/point).csv`: A CSV file containing the menu money allocation cost, the ward, year, and the geographic coordinates of the project location for a specific location text format for shapes, lines, and points.

Due to missing geolocation, projects that should be shapes or lines are often geomatched as singular points.
The location text formats include "2 ands," "3 ands," "double dash to," "from to," "intersection", "normal address," "school park," "through address," and "leftover."

Leftover contains the uncategorized location text formats and are just fed into the google maps API as a last-ditch effort to geocode the project. 
There are currently ~700 leftover projects from the ~45000 total projects.


## Code
* `geomatch_(df).R`: A custom script for each df that takes in the maps and the dataframe and outputs the geomatched dataframe accordingly. 

## Inputs
* `geocoded_(format)_df.csv`: A CSV file containing the menu money allocation cost, the ward, year, and the geographic coordinates of the project location for a specific location text format.
The location text formats include "2 ands," "3 ands," "double dash to," "from to," "intersection", "normal address," "school park," "through address," and "leftover."

Leftover contains the uncategorized location text formats and are just fed into the google maps API as a last-ditch effort to geocode the project. 
There are currently ~700 leftover projects from the ~45000 total projects.
