SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
set_precincts = 8
set_year = 2007 2011
OUTPUTS = $(addprefix ../output/ward_50_, $(foreach i, $(set_precincts), $(foreach year, $(set_year), $(i)_precinct_$(year)_year_timeline.png)))

all: $(OUTPUTS) ../output/stone_eventstudy_observed_spending_precincts.csv ../output/ward_50_contribution_9_precincts_timeline.png

#OUTPUT RECIPES
../output/ward_50_%_year_timeline.png: ward_50_spending_timeline.R ../temp/stone_eventstudy_%_year.rds | ../output run.sbatch slurmlogs
	$(eval args := $(subst _, ,$*))
	$(R) $< $(args)
../output/ward_50_contribution_%_precincts_timeline.png: ward_50_spending_timeline_contributions.R  ../input/ward_precinct_menu_panel_2003_2011.rds ../input/stone_50_supporting_opposing_precincts_2003_2011.csv | ../output run.sbatch slurmlogs
	$(R) $< $*
../output/stone_eventstudy_observed_spending_precincts.csv: compute_observed_spending_totals.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[A-Z|a-z]*' compute_observed_spending_totals.R)| ../output run.sbatch slurmlogs
	$(R) $<
#TEMP RECIPES
../temp/stone_eventstudy_%_year.rds: data_prep_ward_50_es.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[A-Z|a-z]*' data_prep_ward_50_es.R)| ../temp run.sbatch slurmlogs
	$(eval args := $(subst _, ,$*))
	$(R) $< $(args)

#INPUT RECIPES
../input/incumbent_challenger_voteshare_df_precinct_level.csv: ../input/%: ../../data_clean_elections/output/% | ../input
	ln -s $< $@
../input/ward_precinct_menu_panel_2003_2011.rds: ../../data_combine_geomatched_menu/output/ward_precinct_menu_panel_2003_2011.rds | ../input
	ln -s $< $@
../input/stone_50_supporting_opposing_precincts_2003_2011.csv: ../../determine_supporting_or_opposing_precincts_contributions/output/stone_50_supporting_opposing_precincts_2003_2011.csv | ../input
	ln -s $< $@
include ../../generic.make