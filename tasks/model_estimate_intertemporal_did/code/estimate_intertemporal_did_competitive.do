// this script relies on did_multiplegt_dyn
clear

import delimited using "../input/close_runoffs_combined_intertemporal.csv", clear


// create unique identifier for each ward_precinct_locate
gen ward_precinct_locate2 = ward * 1000 + precinct
gen treatment_size = treatment * percentile/100

// run twfe regression
xtset ward_precinct_locate2 year
xtreg spending_fraction treatment_size, fe cluster(ward)
sum

clear
import delimited using "../input/corruption_intertemporal_did_panel.csv"

xtset ward_precinct_locate year
gen treatment_size = treatment * percentile/100
xtreg spending_fraction treatment_size, fe