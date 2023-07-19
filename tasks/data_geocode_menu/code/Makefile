SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUTS = $(addprefix ../output/, geolocated_3_ands_df.csv geolocated_from_to_df.csv geolocated_double_dash_df.csv geolocated_normal_address_df.csv)
INPUTS = $(addprefix ../input/, from_to_df.csv normal_address_df.csv double_dash_to_df.csv df_with_2_ands.csv df_with_3_ands.csv intersection_df.csv school_park_df.csv leftover_df.csv)
all: $(OUTPUTS)


#OUTPUT RECIPES
../output/geolocated_3_ands_df.csv: geolocate_3_ands_format.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geolocate_3_ands_format.R) geolocate_function.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

../output/geolocated_from_to_df.csv: geolocate_from_to_format.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geolocate_from_to_format.R) geolocate_function.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

../output/geolocated_double_dash_df.csv: geolocate_double_dash_format.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geolocate_double_dash_format.R) geolocate_function.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

../output/geolocated_normal_address_df.csv: geolocate_normal_addresses.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geolocate_normal_addresses.R) geolocate_function.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<


#INPUT RECIPES
$(INPUTS): ../input/%: ../../data_clean_menu_location/output/% | ../input
	ln -s $< $@


include ../../generic.make