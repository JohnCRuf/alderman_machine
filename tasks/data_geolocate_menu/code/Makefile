SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
all: ../output/geolocated_menu.csv

#OUTPUT RECIPES

../output/geolocated_menu.csv: merge_geolocated_dfs.R $(shell grep -o '../temp/[A-Za-z_0-9]*\.[a-z]*'  merge_geolocated_dfs.R)  | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

#TEMP RECIPES
../temp/geolocated_normal_address_df.csv: geolocate_normal_addresses.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geolocate_normal_addresses.R) geolocate_function.R | ../temp run.sbatch slurmlogs
	$(R) --no-job-name $<

../temp/from_to_df.csv ../temp/normal_address_df.csv ../temp/double_dash_to_df ../temp/school_park_df.csv:   clean_menu_location.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' clean_menu_location.R) | ../output ../temp run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
../input/menu_df.csv: ../input/%: ../../data_clean_menu/output/% | ../input
	ln -s $< $@


include ../../generic.make