SHELL=bash
include ../../shell_functions.make
## DEFINITIONS
support := top bottom
years := 2015 2019 #years to include in the analysis
close_cutoff := 0.05 1.0 #cutoffs for "close" elections
precinct_count := 5 8 10 15 #number of "most-supporting" precincts to include in the analysis
close_election_stubs = $(foreach sup, $(support), $(foreach year, $(years), $(foreach cutoff, $(close_cutoff), $(foreach precinct, $(precinct_count), support_$(sup)_year_$(year)_cutoff_$(cutoff)_count_$(precinct)))))

OUTPUTS_close_TWFE = $(foreach stub, $(close_election_stubs), ../output/twfe_table_$(stub).tex)
OUTPUTS_close_HTE = $(foreach stub, $(close_election_stubs), ../output/hte_figure_$(stub).png)
OUTPUTS_corruption_HTE = $(foreach precinct, $(precinct_count), ../output/hte_figure_corruption_bottom_$(precinct)_precincts.png ../output/hte_figure_corruption_top_$(precinct)_precincts.png)
all: $(OUTPUTS_close_TWFE) $(OUTPUTS_close_HTE) $(OUTPUTS_corruption_HTE)
TWFE: $(OUTPUTS_close_TWFE)
HTE: $(OUTPUTS_close_HTE)
corruption: $(OUTPUTS_corruption_HTE)

#OUTPUT RECIPES
../output/twfe_table_support_top_%.tex: estimate_twfe_did.R ../input/close_runoffs_%.rda | ../output run.sbatch slurmlogs
	$(R) $^ $@
../output/twfe_table_support_bottom_%.tex: estimate_twfe_did.R ../input/close_runoffs_%.rda | ../output run.sbatch slurmlogs
	$(R) $^ $@
../output/hte_figure_support_top_%.png: estimate_het_te_did.R ../input/close_runoffs_%.rda | ../output run.sbatch slurmlogs
	$(R) $^ $@
../output/hte_figure_support_bottom_%.png: estimate_het_te_did.R ../input/close_runoffs_%.rda | ../output run.sbatch slurmlogs
	$(R) $^ $@
../output/hte_figure_corruption_bottom_%_precincts.png: estimate_corruption_het_te_did.R ../input/corruption_%_precincts.rda | ../output run.sbatch slurmlogs
	$(R) $^ $@
../output/hte_figure_corruption_top_%_precincts.png: estimate_corruption_het_te_did.R ../input/corruption_%_precincts.rda | ../output run.sbatch slurmlogs
	$(R) $^ $@
../output/hte_figure_combined_support_bottom.png: estimate_close_election_het_te_did_combined.R ../input/close_runoffs_combined.rda | ../output run.sbatch slurmlogs
	$(R) $^ $@
../output/hte_figure_combined_support_top.png: estimate_close_election_het_te_did_combined.R ../input/close_runoffs_combined.rda | ../output run.sbatch slurmlogs
	$(R) $^ $@
#INPUT RECIPES
../input/%: ../../model_dataprep_did/output/% | ../input
	ln -s $< $@

include ../../generic.make