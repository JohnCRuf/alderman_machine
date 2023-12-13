SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
categories = alley_sidewalks resurfacing lights misc beaut camera streets
OUTPUTS = $(foreach years, 2012_2022 2003_2011, $(foreach cat, $(categories), $(foreach stub, rds csv, ../output/ward_precinct_menu_panel_$(years)_$(cat).$(stub))))
INPUTS_shapes_lines_points_2012_2022 = $(addprefix ../input/geomatched_, $(foreach geo, shapes lines points,  quad_2012_2022_$(geo).csv) pent_2012_2022_shapes.csv)
INPUTS_lines_points_2012_2022 = $(addprefix ../input/geomatched_, $(foreach geo, lines points,  line_2012_2022_$(geo).csv))
INPUTS_points_2012_2022 = ../input/geomatched_point_2012_2022_points.csv

INPUTS_shapes_lines_points_2003_2011 = $(addprefix ../input/geomatched_, $(foreach geo, shapes lines points,  quad_2003_2011_$(geo).csv ) pent_2003_2011_shapes.csv)
INPUTS_lines_points_2003_2011 = $(addprefix ../input/geomatched_, $(foreach geo, lines points,  line_2003_2011_$(geo).csv))
INPUTS_points_2003_2011 = ../input/geomatched_point_2003_2011_points.csv

INPUTS_maps = $(addprefix ../input/, ward_precincts_2012_2022.zip ward_precincts_2003_2011.zip)
all: $(OUTPUTS)


#OUTPUT RECIPES
../output/ward_precinct_menu_panel_2012_2022_%.rds ../output/ward_precinct_menu_panel_2012_2022_%.csv: combine_geomatched_cat.R $(INPUTS_shapes_lines_points_2012_2022) $(INPUTS_lines_points_2012_2022) $(INPUTS_points_2012_2022) ../temp/ward_precincts_2012_2022 ../input/map_data_prep_fn.R | ../output
	$(R) --no-job-name $< $* 2012_2022 $(INPUTS_shapes_lines_points_2012_2022) $(INPUTS_lines_points_2012_2022) $(INPUTS_points_2012_2022)

../output/ward_precinct_menu_panel_2003_2011_%.rds ../output/ward_precinct_menu_panel_2003_2011_%.csv: combine_geomatched_cat.R $(INPUTS_shapes_lines_points_2003_2011) $(INPUTS_lines_points_2003_2011) $(INPUTS_points_2003_2011) ../temp/ward_precincts_2003_2011 ../input/map_data_prep_fn.R | ../output
	$(R) --no-job-name $< $* 2003_2011 $(INPUTS_shapes_lines_points_2003_2011) $(INPUTS_lines_points_2003_2011) $(INPUTS_points_2003_2011)
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