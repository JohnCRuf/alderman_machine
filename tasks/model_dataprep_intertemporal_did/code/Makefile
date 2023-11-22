SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/corruption_intertemporal.csv ../output/close_runoffs_combined_intertemporal.csv

#OUTPUT RECIPES
../output/corruption_intertemporal.csv: did_dataprep_corruption.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' did_dataprep_corruption.R) | ../output run.sbatch slurmlogs
	$(R) $< 0.5
../output/close_runoffs_combined_intertemporal.csv: did_dataprep_close_runoffs_combined.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' did_dataprep_close_runoffs_combined.R) | ../output run.sbatch slurmlogs
	$(R) $< 0.05
#INPUT RECIPES
../input/incumbent_challenger_voteshare_df_precinct_level.csv: ../input/%: ../../data_clean_elections/output/% | ../input
	ln -s $< $@
../input/ward_precinct_menu_panel_2012_2022.rds: ../../data_combine_geomatched_menu/output/ward_precinct_menu_panel_2012_2022.rds | ../input
	ln -s $< $@
../input/incumbent_contribution_supporting_opposing_precincts.csv: ../../determine_supporting_or_opposing_precincts_contributions/output/incumbent_contribution_suppporting_opposing_precincts.csv | ../input
	ln -s $< $@
include ../../generic.make