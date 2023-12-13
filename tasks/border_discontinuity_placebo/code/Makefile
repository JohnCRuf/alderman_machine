SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
seeds = $(shell seq 1 50)
INPUTS_placebo = $(foreach seed,$(seeds),../input/placebo_map_ward_seed_$(seed).rds)
INPUTS_block_maps = $(addprefix ../input/, block_map_2000.rds block_map_2010.rds)
INPUTS_menu = $(addprefix ../input/, block_menu_panel_2012_2022.rds)
TEMP_clean = $(foreach seed,$(seeds),../temp/clean_placebo_map_ward_seed_$(seed).rds)
TEMP_needs = $(foreach seed,$(seeds),../temp/needs_placebo_map_ward_seed_$(seed).rds)
all: $(OUTPUTS)

#OUTPUT RECIPES
../output/placebo_estimates.rds: compute_placebo_estimates.R $()

#TEMP RECIPES
$(TEMP_needs): ../temp/needs_placebo_map_ward_seed_%.rds: impute_needs_placebo.R ../input/placebo_map_ward_seed_%.rds ../input/log_cubed_model.rds | ../temp
	$(R) --no-job-name $< $@

$(TEMP_clean): ../temp/clean_placebo_map_ward_seed_%.rds: clean_placebo_maps.R ../input/placebo_map_ward_seed_%.rds | ../temp
	$(R) --no-job-name $< $@
#INPUT RECIPES
../input/log_cubed_model.rds: ../input/%: ../../border_discontinuity_impute_need/output/% | ../input
	ln -s $< $@
$(INPUTS_placebo): ../input/%: ../../border_discontinuity_generate_placebo_maps/output/% | ../input
	ln -s $< $@
$(INPUTS_block_maps): ../input/%.rds: ../../data_produce_census_block_maps/output/%.rds | ../input
	ln -s $< $@
$(INPUTS_menu): ../input/%: ../../data_combine_geomatched_menu_block/output/% | ../input
	ln -s $< $@
include ../../generic.make									