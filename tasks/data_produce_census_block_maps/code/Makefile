SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUT = ../output/block_map_2010.rds ../output/block_map_2000.rds
TEMP = $(addprefix ../temp/, census_blocks_2010 census_blocks_2000)
INPUTS_maps = $(addprefix ../input/, census_blocks_2010.zip census_blocks_2000.zip)
all: $(OUTPUT)

#OUTPUT RECIPES
../output/block_map_%.rds: create_block_maps.R $(TEMP) | ../output
	$(R) --no-job-name $< ../temp/census_blocks_$*/census_blocks_$*.shp $@

#TEMP RECIPES
../temp/census_blocks_%: ../input/census_blocks_%.zip | ../temp
	unzip -o -d ../temp/census_blocks_$* $<
	for file in ../temp/census_blocks_$*/* ; do \
		mv $$file ../temp/census_blocks_$*/census_blocks_$*.`basename $$file | sed 's/.*\.//'`; \
	done
	
#INPUT RECIPES
$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@
$(INPUTS_menu): ../input/%: ../../data_combine_geomatched_menu/output/% | ../input
	ln -s $< $@
include ../../generic.make