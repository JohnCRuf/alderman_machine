SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
years := 2019 #years to include in the analysis
close_cutoff := 0.05 #cutoffs for "close" elections
precinct_count := 5 10 15 #number of "most-supporting" precincts to include in the analysis
triples = $(foreach year, $(years), $(foreach cutoff, $(close_cutoff), $(foreach precinct, $(precinct_count), year_$(year)_cutoff_$(cutoff)_count_$(precinct))))
OUTPUTS = $(foreach triple, $(triples), ../output/close_runoffs_$(triple).rda)
all: $(OUTPUTS) 

#OUTPUT RECIPES
$(OUTPUTS): ../output/close_runoffs_%.rda: did_dataprep_close_runoffs.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' did_dataprep_close_runoffs.R) | ../output run.sbatch slurmlogs
	$(R) $< $(call get_even_elements, $(subst _, ,$*))
#INPUT RECIPES
../input/incumbent_challenger_voteshare_df_precinct_level.csv: ../input/%: ../../data_clean_elections/output/% | ../input
	ln -s $< $@
../input/ward_precinct_menu_panel_2012_2022.rds: ../../data_combine_geomatched/output/ward_precinct_menu_panel_2012_2022.rds | ../input
	ln -s $< $@

include ../../generic.make