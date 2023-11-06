SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
ward_14_general_results_outputs = $(foreach year, 2003 2007 2011 2015, ../output/ward_14_$(year)_general_incumbent_precinct_results.png)
ward_50_general_results_outputs = $(foreach year, 2003 2007 2011 2015, ../output/ward_50_$(year)_general_incumbent_precinct_results.png)
ward_50_runoff_results_outputs = $(foreach year, 2007 2011, ../output/ward_50_$(year)_runoff_incumbent_precinct_results.png)
ward_50_general_turnout_outputs = $(foreach year, 2003 2007 2011 2015, ../output/ward_50_$(year)_general_precinct_turnout.png)
ward_50_runoff_turnout_outputs = $(foreach year, 2007 2011, ../output/ward_50_$(year)_runoff_precinct_turnout.png)
INPUTS_maps = $(addprefix ../input/, ward_precincts_2012_2022.zip ward_precincts_2003_2011.zip)
TEMP_maps = $(addprefix ../temp/, ward_precincts_2012_2022 ward_precincts_2003_2011)
all: $(ward_50_general_results_outputs) $(ward_50_runoff_results_outputs) $(ward_50_general_turnout_outputs) $(ward_50_runoff_turnout_outputs) $(ward_14_general_results_outputs)
## OUTPUTS
../output/ward_%_incumbent_precinct_results.png: map_election_results.R $(TEMP_maps) $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-zA-Z]*' map_election_results.R) | ../output run.sbatch slurmlogs
	$(eval args := $(subst _, ,$*))
	$(R) $< $(args) 200 50 $@
../output/ward_%_precinct_turnout.png: map_election_turnout.R $(TEMP_maps) $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-zA-Z]*' map_election_turnout.R) | ../output run.sbatch slurmlogs
	$(eval args := $(subst _, ,$*))
	$(R) $< $(args) 400 100 $@
## TEMP
../temp/ward_precincts_%: ../input/ward_precincts_%.zip | ../temp
	unzip -o -d ../temp/ward_precincts_$* $<
	for file in ../temp/ward_precincts_$*/* ; do \
		mv $$file ../temp/ward_precincts_$*/ward_precincts_$*.`basename $$file | sed 's/.*\.//'`; \
	done
## INPUTS
../input/incumbent_challenger_voteshare_df_precinct_level.csv: ../input/%: ../../data_clean_elections/output/% | ../input
	ln -s $< $@
#INPUT RECIPES
../input/map_data_prep_fn.R: ../../data_geomatch_menu/code/map_data_prep_fn.R | ../input
	ln -s $< $@
$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@
include ../../generic.make