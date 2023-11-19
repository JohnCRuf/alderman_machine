## Border_discontinuity_dataprep
This task prepares the data needed to conduct a border design study similar to Bordeu et al's (2023) JMP. 

### Output
* `ward_pct_of_needs.rda`: A data frame containing each precinct's distance to the nearest border, the ward of the nearest border, the needs gap between the precinct's ward and the nearest ward across the border, the election cycle of the precinct's spending, and the precinct's total spending in that election cycle. 

* `area_vs_pct_of_needs.png`: A scatterplot of the area of a ward vs the percent of the ward's needs that are met.

### Code
* `impute_need.R`: Takes in both ward maps, and OIG ward needs and regresses ward needs on ward size. Then it imputes ward needs for the 2003-2011 period. Finally, it produces a scatterplot of ward needs vs ward size.

### Inputs
* `oig_audit_needs.csv`: Ward-needs data from the OIG audit.
* `ward_precincts_2003_2011.zip`: Shapefile of ward precincts from 2003-2011.
* `ward_precincts_2012_2020.zip`: Shapefile of ward precincts from 2012-2020.