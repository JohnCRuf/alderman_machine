## Border_discontinuity_dataprep
This task prepares the data needed to conduct a border design study similar to Bordeu et al's (2023) JMP. 

### Output
* `border_discontinuity_data.rda`: A data frame containing each precinct's distance to the nearest border, the ward of the nearest border, the needs gap between the precinct's ward and the nearest ward across the border, the election cycle of the precinct's spending, and the precinct's total spending in that election cycle. 

### Code
* `border_discontinuity_dataprep.R`: Takes in the map of precincts, imputed-ward needs, precinct spending data, and combines them into a single data frame.

### Input