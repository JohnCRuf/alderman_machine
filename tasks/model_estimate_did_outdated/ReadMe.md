# model estimate did
    This task fits TWFE and heterogeneous treatment effect robust DiD models to menu data for a variety of parameterizations.

## Output
* `twfe_table_support_(top/bottom)_year_(year)_cutoff_(c)_count_(n).tex`:
The TWFE table for the top/bottom `n` precincts in `year` with a close-election cutoff of `c`.
## Code
* `estimate_twfe_did.R`: Estimates a TWFE model for a given parameterization.
* `estimate_het_te_did.R`: Estimates a heterogeneous treatment effect robust DiD model for a given parameterization.
## Inputs

* `close_runoffs_year_(year)_cutoff_(cutoff)_n_(n).rda`: 
A RDA file with a ward-precinct level menu expenditure panel dataset, a list of the top and bottom n incumbent supporting" precincts for each ward in the sample by net vote count, and a list of treatment and control wards for a given cutoff.
