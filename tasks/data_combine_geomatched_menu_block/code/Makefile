SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
INPUTS_shapes_lines_points_2012_2022 = $(addprefix ../input/geomatched_, $(foreach geo, shapes lines points,  quad_2012_2022_$(geo).csv) pent_2012_2022_shapes.csv)
INPUTS_lines_points_2012_2022 = $(addprefix ../input/geomatched_, $(foreach geo, lines points,  line_2012_2022_$(geo).csv))
INPUTS_points_2012_2022 = ../input/geomatched_point_2012_2022_points.csv

INPUTS_shapes_lines_points_2003_2011 = $(addprefix ../input/geomatched_, $(foreach geo, shapes lines points,  quad_2003_2011_$(geo).csv ) pent_2003_2011_shapes.csv)
INPUTS_lines_points_2003_2011 = $(addprefix ../input/geomatched_, $(foreach geo, lines points,  line_2003_2011_$(geo).csv))
INPUTS_points_2003_2011 = ../input/geomatched_point_2003_2011_points.csv

INPUTS_maps = $(addprefix ../input/, block_map_2000.rds block_map_2010.rds)

all: ../output/ward_precinct_menu_panel_2012_2022.rds ../output/ward_precinct_menu_panel_2012_2022.csv ../output/ward_precinct_menu_panel_2003_2011.rds ../output/ward_precinct_menu_panel_2003_2011.csv


#OUTPUT RECIPES
../output/ward_precinct_menu_panel_2012_2022.rds ../output/ward_precinct_menu_panel_2012_2022.csv: combine_geomatched.R $(INPUTS_shapes_lines_points_2012_2022) $(INPUTS_lines_points_2012_2022) $(INPUTS_points_2012_2022) ../input/block_map_2010.rds  | ../output
	$(R) --no-job-name $< 2012_2022 ../input/block_map_2010.rds $(INPUTS_shapes_lines_points_2012_2022) $(INPUTS_lines_points_2012_2022) $(INPUTS_points_2012_2022)

../output/ward_precinct_menu_panel_2003_2011.rds ../output/ward_precinct_menu_panel_2003_2011.csv ../input/block_map_2000.rds: combine_geomatched.R $(INPUTS_shapes_lines_points_2003_2011) $(INPUTS_lines_points_2003_2011) $(INPUTS_points_2003_2011) | ../output
	$(R) --no-job-name $< 2003_2011 ./input/block_map_2000.rds $(INPUTS_shapes_lines_points_2003_2011) $(INPUTS_lines_points_2003_2011) $(INPUTS_points_2003_2011)

#INPUT RECIPES
../input/geomatched_%.csv: ../../data_geomatch_menu_block/output/geomatched_%.csv | ../input
	ln -s $< $@

$(INPUTS_maps): ../input/%.rds: ../../data_produce_census_block_maps/output/%.rds | ../input
	ln -s $< $@

include ../../generic.make