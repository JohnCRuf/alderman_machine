SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
INPUTS_shapes_lines_points = $(addprefix ../input/geomatched_, $(foreach geo, shapes lines points, \
 3_ands_2012_2022_$(geo).csv  mult_ands_2012_2022_shapes.csv  ))
INPUTS_lines_points = $(addprefix ../input/geomatched_, $(foreach geo, lines points, \
 2_ands_2012_2022_$(geo).csv and_dash_2012_2022_$(geo).csv \
from_to_2012_2022_$(geo).csv double_dash_to_2012_2022_$(geo).csv through_address_2012_2022_$(geo).csv \
) leftover_dash_2012_2022_lines.csv)
INPUTS_points = $(addprefix ../input/geomatched_,  \
  normal_address_2012_2022_points.csv  intersection_2012_2022_points.csv \
  school_park_2012_2022_points.csv leftover_2012_2022_points.csv)
INPUTS_maps = $(addprefix ../input/, ward_precincts_2012_2022.zip \
ward_precincts_2012_2022.zip)
all: ../output/ward_precinct_menu_panel_2012_2022.rds ../output/ward_precinct_menu_panel_2012_2022.csv


#OUTPUT RECIPES
../output/ward_precinct_menu_panel_2012_2022.rds ../output/ward_precinct_menu_panel_2012_2022.csv: combine_2012_2022.R $(INPUTS_shapes_lines_points) $(INPUTS_lines_points) $(INPUTS_points) ../temp/ward_precincts_2012_2022 ../input/map_data_prep_fn.R | ../output
	$(R) --no-job-name $< $(INPUTS_shapes_lines_points) $(INPUTS_lines_points) $(INPUTS_points)

#TEMP RECIPES
../temp/ward_precincts_%: ../input/ward_precincts_%.zip | ../temp
	unzip -o -d ../temp/ward_precincts_$* $<
	for file in ../temp/ward_precincts_$*/* ; do \
		mv $$file ../temp/ward_precincts_$*/ward_precincts_$*.`basename $$file | sed 's/.*\.//'`; \
	done
#INPUT RECIPES
../input/geomatched_%.csv: ../../data_geomatch_menu/output/geomatched_%.csv | ../input
	ln -s $< $@
../input/map_data_prep_fn.R: ../../data_geomatch_menu/code/map_data_prep_fn.R | ../input
	ln -s $< $@
$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@
include ../../generic.make