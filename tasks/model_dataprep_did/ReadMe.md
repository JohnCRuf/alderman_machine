# Model Dataprep DID
     This folder contains the code to prepare the data for differences-in-differences (DID) estimation. 

## OUTPUTS
* `close_runoffs_year_(year)_cutoff_(cutoff)_n_(n).rda`: 
A RDA file with a ward-precinct level menu expenditure panel dataset, a list of the top n incumbent supporting" precincts for each ward in the sample, and a list of treatment and control wards for a given cutoff.


## CODE
* `did_dataprep_close_runoffs.R`: Takes in menu expenditure and election data and creates the necessary variables for a DiD model for election year (year), cutoff (cutoff).

## INPUTS
* `ward_precinct_menu_panel_2003_2011.csv`: 
A csv file containing the sum of the area-weighted menu money cost allocation for each precinct in the 2003-2011 ward-precinct boundaries for each year between 2003 and 2022.
* `ward_precinct_menu_panel_2003_2011.rds`: 
An rds file containing the sum of the area-weighted menu money cost allocation for each precinct in the 2003-2011 ward-precinct boundaries for each year between 2003 and 2022. Ward and precinct shapes are also stored.
* `incumbent_challenger_voteshare_df_precinct_level.csv`: Precinct level vote counts, ward level vote counts and shares, and an incumbency dummy for each candidate in each election.