SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
all:  ../output/spending_histogram_2012_2022.png ../output/spending_histogram_2005_2011.png
#OUTPUT RECIPES

../output/spending_histogram_2012_2022.png: menu_spending_histogram.R ../input/ward_precinct_menu_panel_2012_2022.rds | ../output run.sbatch slurmlogs
	$(R) $^ 2012 2022  $@
../output/spending_histogram_2005_2011.png: menu_spending_histogram.R ../input/ward_precinct_menu_panel_2003_2011.rds | ../output run.sbatch slurmlogs
	$(R) $^ 2005 2011 $@
../output/five_number_summary.tex: menu_five_number_summary.R ../input/ward_precinct_menu_panel_2012_2022.rds | ../output run.sbatch slurmlogs
	$(R) $^ 2012 2022 $@
#INPUT RECIPES
../input/ward_precinct_menu_panel_%.rds: ../../data_combine_geomatched_menu/output/ward_precinct_menu_panel_%.rds | ../input
	ln -s $< $@

include ../../generic.make