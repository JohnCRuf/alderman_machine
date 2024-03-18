SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
seeds = $(shell seq 1 50)
OUTPUTS = $(foreach seed,$(seeds),../output/placebo_map_$(seed).rds)
INPUTS_block_maps = $(addprefix ../input/, block_map_2000.rds block_map_2010.rds)
all: $(OUTPUTS)

#OUTPUT RECIPES
$(OUTPUTS): ../output/placebo_map_%.rds: generate_ward_maps.R ../input/block_map_2010.rds| ../output
	$(R) --no-job-name $< $*

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