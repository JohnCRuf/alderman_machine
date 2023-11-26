SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUT = ../output/border_discontinuity_data.csv
INPUTS_block_maps = $(addprefix ../input/, block_map_2000.rds block_map_2010.rds)
INPUTS_ward_maps = $(addprefix ../input/, ward_map_2003_2011.rds ward_map_2012_2022.rds)
INPUTS_menu = $(addprefix ../input/, block_menu_panel_2012_2022.rds)
all: $(OUTPUT)
inputs: $(INPUTS_block_maps) $(INPUTS_ward_maps) $(INPUTS_menu)

#OUTPUT RECIPES
$(OUTPUT): border_discontinuity_dataprep.R ../input/ward_needs_data.csv ../input/map_data_prep_fn.R $(INPUTS_menu) | ../output
	$(R) --no-job-name $<


#INPUT RECIPES
../input/ward_needs_data.csv: ../input/%: ../../border_discontinuity_impute_need/output/% | ../input
	ln -s $< $@
$(INPUTS_block_maps): ../input/%.rds: ../../data_produce_census_block_maps/output/%.rds | ../input
	ln -s $< $@
$(INPUTS_ward_maps): ../input/%.rds: ../../data_produce_ward_maps/output/%.rds | ../input
	ln -s $< $@
$(INPUTS_menu): ../input/%: ../../data_combine_geomatched_menu_block/output/% | ../input
	ln -s $< $@
include ../../generic.make