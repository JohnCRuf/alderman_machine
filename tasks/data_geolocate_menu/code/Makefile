SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
all: ../output/geolocated_menu.csv

#OUTPUT RECIPES

../output/geolocated_menu.csv: geolocate_menu_expenditures.R $(shell grep -o '../type/[A-Za-z_0-9]*\.[a-z]*' geolocate_menu_expenditures.R)  | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

#TEMP RECIPES

../temp/cleaned_menu.csv :   clean_menu_location.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' clean_menu_location.R) | ../output ../temp run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
../input/menu_df.csv: ../input/%: ../../data_clean_menu/output/% | ../input
	ln -s $< $@


include ../../generic.make