SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUT = ../output/border_discontinuity_data.csv
TEMP = ../temp/ward_precincts_2012_2022 ../temp/ward_precincts_2003_2011
INPUTS_maps = $(addprefix ../input/, ward_precincts_2003_2011.zip \
ward_precincts_2012_2022.zip)
INPUTS_menu = $(addprefix ../input/, ward_precinct_menu_panel_2003_2011.csv ward_precinct_menu_panel_2012_2022.csv)
all: $(OUTPUT)

#OUTPUT RECIPES
$(OUTPUT): border_discontinuity_dataprep.R $(TEMP) ../input/ward_needs_data.csv ../input/map_data_prep_fn.R $(INPUTS_menu) | ../output
	$(R) --no-job-name $<

#TEMP RECIPES
../temp/ward_precincts_%: ../input/ward_precincts_%.zip | ../temp
	unzip -o -d ../temp/ward_precincts_$* $<
	for file in ../temp/ward_precincts_$*/* ; do \
		mv $$file ../temp/ward_precincts_$*/ward_precincts_$*.`basename $$file | sed 's/.*\.//'`; \
	done
#INPUT RECIPES
../input/ward_needs_data.csv: ../input/%: ../../border_discontinuity_impute_need/output/% | ../input
	ln -s $< $@
../input/map_data_prep_fn.R: ../input/%: ../../data_geomatch_menu/code/% | ../input
	ln -s $< $@
$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@
$(INPUTS_menu): ../input/%: ../../data_combine_geomatched_menu/output/% | ../input
	ln -s $< $@
include ../../generic.make