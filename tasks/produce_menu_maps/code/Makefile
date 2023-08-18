SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/ward_50_menu_map_2005_2010.png ../output/ward_50_menu_map_2010_2014.png ../output/ward_50_menu_map_2015_2018.png

#OUTPUT RECIPES
#args for menu_map_production.R go as follows: year_start year_end ward legend_arg color_arg break_gap max_y_axis
../output/ward_50_menu_map_2005_2010.png: menu_map_production.R ../input/ward_precinct_menu_panel_2003_2011.rds | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2005 2010 50 total viridis 100000 130000000 $@
../output/ward_50_menu_map_2010_2014.png: menu_map_production.R ../input/ward_precinct_menu_panel_2003_2011.rds  | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2010 2014 50 total viridis 100000 130000000 $@
../output/ward_50_menu_map_2015_2018.png: menu_map_production.R ../input/ward_precinct_menu_panel_2012_2022.rds  | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2015 2018 50 total viridis 100000 130000000 $@
#INPUT RECIPES
../input/ward_precinct_menu_panel_%.rds: ../../data_combine_geomatched/output/ward_precinct_menu_panel_%.rds | ../input
	ln -s $< $@

include ../../generic.make