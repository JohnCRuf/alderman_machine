SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: $(addprefix ../output/, stone_menu_money_spending_map_2005_2011.png stone_2007_runoff_precinct_results.png \
stone_2003_general_precinct_results.png \
stone_2011_runoff_precinct_results.png stone_spending_2007_results_scatterplot.png \
stone_spending_2011_results_scatterplot.png)

#OUTPUT RECIPES

../output/stone_%_precinct_results.png: stone_election_results_map.R ../temp/stone_dataset.rds | ../output run.sbatch slurmlogs
	$(eval args := $(subst _, ,$*))
	$(R) $< $(args)
../output/stone_menu_money_spending_map_2005_2011.png: stone_menu_money_map.R ../temp/stone_dataset.rds | ../output run.sbatch slurmlogs
	$(R) $< 
../output/stone_spending_%_results_scatterplot.png: stone_menu_voting_scatterplot.R ../temp/stone_dataset.rds | ../output run.sbatch slurmlogs
	$(R) $< $*
#TEMP RECIPES
../temp/stone_dataset.rds: prepare_stone_data.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[A-Z|a-z]*' prepare_stone_data.R)| ../temp run.sbatch slurmlogs
	$(R) $<
#INPUT RECIPES
../input/incumbent_challenger_voteshare_df_precinct_level.csv: ../input/%: ../../data_clean_elections/output/% | ../input
	ln -s $< $@
../input/ward_precinct_menu_panel_2003_2011.rds: ../../data_combine_geomatched/output/ward_precinct_menu_panel_2003_2011.rds | ../input
	ln -s $< $@

include ../../generic.make