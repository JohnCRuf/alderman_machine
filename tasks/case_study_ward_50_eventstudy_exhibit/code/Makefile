SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
set_precincts = 5 10 15
OUTPUTS = $(addprefix ../output/ward_50_, $(foreach i, $(set_precincts), $(i)_precinct_timeline.png))

all: $(OUTPUTS)

#OUTPUT RECIPES
../output/ward_50_%_precinct_timeline.png: ward_50_spending_timeline.R ../temp/stone_eventstudy_%_precincts.rds | ../output run.sbatch slurmlogs
	$(R) $< $*

#TEMP RECIPES
../temp/stone_eventstudy_%_precincts.rds: data_prep_ward_50_es.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[A-Z|a-z]*' data_prep_ward_50_es.R)| ../temp run.sbatch slurmlogs
	$(R) $< $*

#INPUT RECIPES
../input/incumbent_challenger_voteshare_df_precinct_level.csv: ../input/%: ../../data_clean_elections/output/% | ../input
	ln -s $< $@
../input/ward_precinct_menu_panel_2003_2011.rds: ../../data_combine_geomatched/output/ward_precinct_menu_panel_2003_2011.rds | ../input
	ln -s $< $@

include ../../generic.make