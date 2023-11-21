SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUT = ../output/ward_map_2003_2011.rds ../output/ward_map_2012_2022.rds
TEMP = ../temp/ward_precincts_2012_2022 ../temp/ward_precincts_2003_2011
INPUTS_maps = $(addprefix ../input/, ward_precincts_2003_2011.zip \
ward_precincts_2012_2022.zip)
all: $(OUTPUT)

#OUTPUT RECIPES
../output/ward_map_%.rds: create_ward_maps.R $(TEMP) ../input/map_data_prep_fn.R | ../output
	$(R) --no-job-name $< ../temp/ward_precincts_$*/ward_precincts_$*.shp $@

#TEMP RECIPES
../temp/ward_precincts_%: ../input/ward_precincts_%.zip | ../temp
	unzip -o -d ../temp/ward_precincts_$* $<
	for file in ../temp/ward_precincts_$*/* ; do \
		mv $$file ../temp/ward_precincts_$*/ward_precincts_$*.`basename $$file | sed 's/.*\.//'`; \
	done
#INPUT RECIPES

../input/map_data_prep_fn.R: ../input/%: ../../data_geomatch_menu/code/% | ../input
	ln -s $< $@
$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@
$(INPUTS_menu): ../input/%: ../../data_combine_geomatched_menu/output/% | ../input
	ln -s $< $@
include ../../generic.make