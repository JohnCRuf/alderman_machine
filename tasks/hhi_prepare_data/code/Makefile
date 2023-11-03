SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
cycle_outputs = $(foreach range, 2003_2011 2012_2022, ../output/menu_cycle_hhi_$(range).csv)
annual_outputs = $(foreach range, 2003_2011 2012_2022, ../output/menu_annual_hhi_$(range).csv)

all: $(cycle_outputs) $(annual_outputs)
reports = $(foreach range, 2003_2011 2012_2022, ../report/menu_cycle_hhi_$(range).csv ../report/menu_annual_hhi_$(range).csv.log)

#OUTPUT RECIPES
#args for menu_map_production.R go as follows: year_start year_end ward legend_arg color_arg break_gap max_y_axis
../output/menu_annual_hhi_%.csv: prepare_annual_hhi_data.R ../input/ward_precinct_menu_panel_%.rds | ../output run.sbatch slurmlogs
	$(R) $^ $(subst _, ,$*) 
../output/menu_cycle_hhi_%.csv: prepare_cycle_hhi_data.R ../input/ward_precinct_menu_panel_%.rds | ../output run.sbatch slurmlogs
	$(R) $^ $(subst _, ,$*)

#INPUT RECIPES
../input/ward_precinct_menu_panel_%.rds: ../../data_combine_geomatched/output/ward_precinct_menu_panel_%.rds | ../input
	ln -s $< $@

include ../../generic.make