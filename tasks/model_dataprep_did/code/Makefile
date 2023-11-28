SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
years := 2015 2019 #years to include in the analysis
close_cutoff := 0.05 1.0 #cutoffs for "close" elections
precinct_count := $(shell seq 5 1 12) #number of "most-supporting" precincts to include in the analysis
triples = $(foreach year, $(years), $(foreach cutoff, $(close_cutoff), $(foreach precinct, $(precinct_count), year_$(year)_cutoff_$(cutoff)_count_$(precinct))))
OUTPUTS = $(foreach triple, $(triples), ../output/close_runoffs_$(triple).rda)
OUTPUTS_combined = $(foreach cutoff, $(close_cutoff), $(foreach precinct, $(precinct_count), ../output/close_runoffs_combined_$(cutoff)_$(precinct).rda))
all: $(OUTPUTS) $(OUTPUTS_combined) ../output/corruption_5_precincts.rda ../output/corruption_8_precincts.rda ../output/corruption_10_precincts.rda ../output/corruption_15_precincts.rda

#OUTPUT RECIPES
$(OUTPUTS): ../output/close_runoffs_%.rda: did_dataprep_close_runoffs.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' did_dataprep_close_runoffs.R) | ../output run.sbatch slurmlogs
	$(R) $< $(call get_even_elements, $(subst _, ,$*))
../output/corruption_%_precincts.rda: did_dataprep_corruption.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' did_dataprep_corruption.R) | ../output run.sbatch slurmlogs
	$(R) $< $*
../output/close_runoffs_combined_%.rda: did_dataprep_close_runoffs_combined.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' did_dataprep_close_runoffs_combined.R) | ../output run.sbatch slurmlogs
	$(R) $< $(subst _, ,$*)
#INPUT RECIPES
../input/incumbent_challenger_voteshare_df_precinct_level.csv: ../input/%: ../../data_clean_elections/output/% | ../input
	ln -s $< $@
../input/ward_precinct_menu_panel_2012_2022.rds: ../../data_combine_geomatched_menu/output/ward_precinct_menu_panel_2012_2022.rds | ../input
	ln -s $< $@
../input/incumbent_contribution_supporting_opposing_precincts.csv: ../../determine_supporting_or_opposing_precincts_contributions/output/incumbent_contribution_suppporting_opposing_precincts.csv | ../input
	ln -s $< $@
include ../../generic.make