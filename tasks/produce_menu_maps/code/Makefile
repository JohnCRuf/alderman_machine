SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
wards = 50 14 11 25
ward_50_maps = $(foreach range, 2005_2010 2011_2014 2015_2018, ../output/ward_50_menu_map_$(range).png)
corruption_maps = $(foreach range, 2012_2019 2020_2022, $(foreach ward, 11 25 1 20, ../output/ward_$(ward)_menu_map_$(range).png))
whole_chicago_maps = $(foreach range, 2005_2011 2012_2022, ../output/whole_chicago_map_$(range).png)
whole_chicago_maps_cat = $(foreach range, 2005_2011 2012_2022, $(foreach cat, alley_sidewalks resurfacing lights misc beaut camera streets, ../output/whole_chicago_map_$(range)_$(cat).png))
all: $(ward_50_maps) $(corruption_maps) $(whole_chicago_maps) $(whole_chicago_maps_cat)
cat_maps: $(whole_chicago_maps_cat)
#OUTPUT RECIPES
#args for menu_map_production.R go as follows: year_start year_end ward legend_arg color_arg break_gap max_y_axis
../output/ward_50_menu_map_2005_2010.png: menu_map_production.R ../input/ward_precinct_menu_panel_2003_2011.rds | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2005 2010 50 total cividis 100000 130000000 $@
../output/ward_50_menu_map_2011_2014.png: menu_map_production.R ../input/ward_precinct_menu_panel_2003_2011.rds  | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2011 2014 50 total cividis 100000 130000000 $@
../output/ward_50_menu_map_2015_2018.png: menu_map_production.R ../input/ward_precinct_menu_panel_2012_2022.rds  | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2015 2018 50 total cividis 100000 130000000 $@
../output/ward_14_menu_map_2012_2022.png: menu_map_production.R ../input/ward_precinct_menu_panel_2012_2022.rds  | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2012 2022 14 total cividis 100000 130000000 $@
../output/ward_%_menu_map_2012_2019.png: menu_map_production.R ../input/ward_precinct_menu_panel_2012_2022.rds  | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2012 2019 $* total cividis 100000 130000000 $@
../output/ward_%_menu_map_2020_2022.png: menu_map_production.R ../input/ward_precinct_menu_panel_2012_2022.rds  | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2020 2022 $* total cividis 100000 130000000 $@
#whole chicago map outputs, total spending
../output/whole_chicago_map_2012_2022.png: whole_chicago_map.R ../input/ward_precinct_menu_panel_2012_2022.rds | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2012 2022 total 100000 130000000 $@
../output/whole_chicago_map_2005_2011.png: whole_chicago_map.R ../input/ward_precinct_menu_panel_2003_2011.rds | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2005 2011 total 100000 130000000 $@

#whole chicago map outputs, category spending
../output/whole_chicago_map_2012_2022_%.png: whole_chicago_map.R ../input/ward_precinct_menu_panel_2012_2022_%.rds | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2012 2022 total 100000 130000000 $@
../output/whole_chicago_map_2005_2011_%.png: whole_chicago_map.R ../input/ward_precinct_menu_panel_2003_2011_%.rds | menu_title_mapper.R ../output run.sbatch slurmlogs
	$(R) $^ 2005 2011 total 100000 130000000 $@
#INPUT RECIPES
../input/ward_precinct_menu_panel_2012_2022.rds ../input/ward_precinct_menu_panel_2003_2011.rds: ../input/%: ../../data_combine_geomatched_menu/output/% | ../input
	ln -s $< $@
../input/ward_precinct_menu_panel_2012_2022_%.rds:  ../../data_combine_geomatched_menu_cat/output/ward_precinct_menu_panel_2012_2022_%.rds | ../input
	ln -s $< $@
../input/ward_precinct_menu_panel_2003_2011_%.rds:  ../../data_combine_geomatched_menu_cat/output/ward_precinct_menu_panel_2003_2011_%.rds | ../input
	ln -s $< $@

include ../../generic.make