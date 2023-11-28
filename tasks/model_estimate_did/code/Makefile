SHELL=bash
include ../../shell_functions.make
## DEFINITIONS
support := top bottom
years := 2015 2019 #years to include in the analysis
close_cutoff := 0.05 1.0 #cutoffs for "close" elections
precinct_count := $(shell seq 5 1 12)
close_election_stubs = $(foreach sup, $(support), $(foreach year, $(years), $(foreach cutoff, $(close_cutoff), $(foreach precinct, $(precinct_count), support_$(sup)_year_$(year)_cutoff_$(cutoff)_count_$(precinct)))))

OUTPUTS_close_TWFE = $(foreach stub, $(close_election_stubs), ../output/twfe_table_$(stub).tex)
OUTPUTS_close_HTE = $(foreach stub, $(close_election_stubs), ../output/hte_figure_$(stub).png)
OUTPUTS_corruption = $(foreach precinct, $(precinct_count), $(foreach support, $(support), ../output/corruption_$(precinct)_precincts_$(support)_figure.png ../output/corruption_$(precinct)_precincts_$(support)_estimate.txt ../output/corruption_$(precinct)_precincts_$(support)_estimate_agg.txt))
OUTPUTS_combined = $(foreach cutoff, $(close_cutoff), $(foreach precinct, $(precinct_count), $(foreach support, $(support), ../output/close_runoffs_combined_$(cutoff)_$(precinct)_$(support)_figure.png ../output/close_runoffs_combined_$(cutoff)_$(precinct)_$(support)_estimate.txt ../output/close_runoffs_combined_$(cutoff)_$(precinct)_$(support)_estimate_agg.txt)))
all: $(OUTPUTS_close_HTE) $(OUTPUTS_corruption_HTE)
TWFE: $(OUTPUTS_close_TWFE)
HTE: $(OUTPUTS_close_HTE)
corruption: $(OUTPUTS_corruption)
combined: $(OUTPUTS_combined)

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
../output/corruption_%_precincts_top_figure.png ../output/corruption_%_precincts_top_estimate.txt ../output/corruption_%_precincts_top_estimat_agg.txt: estimate_corruption_het_te_did.R ../input/corruption_%_precincts.rda | ../output run.sbatch slurmlogs
	$(R) $^ top
../output/corruption_%_precincts_bottom_figure.png ../output/corruption_%_precincts_bottom_estimate.txt ../output/corruption_%_precincts_bottom_estimat_agg.txt: estimate_corruption_het_te_did.R ../input/corruption_%_precincts.rda | ../output run.sbatch slurmlogs
	$(R) $^ bottom

../output/close_runoffs_combined_%_top_figure.png ../output/close_runoffs_combined_%_top_estimate.txt ../output/close_runoffs_combined_%_top_estimate_agg.txt: estimate_close_election_het_te_did_combined.R ../input/close_runoffs_combined_%.rda | ../output run.sbatch slurmlogs
	$(R) $^ top
../output/close_runoffs_combined_%_bottom_figure.png ../output/close_runoffs_combined_%_bottom_estimate.txt ../output/close_runoffs_combined_%_bottom_estimate_agg.txt: estimate_close_election_het_te_did_combined.R ../input/close_runoffs_combined_%.rda | ../output run.sbatch slurmlogs
	$(R) $^ bottom
#INPUT RECIPES
../input/%: ../../model_dataprep_did/output/% | ../input
	ln -s $< $@

include ../../generic.make