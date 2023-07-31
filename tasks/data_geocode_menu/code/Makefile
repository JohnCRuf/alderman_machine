SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUTS = $(addprefix ../output/geocoded_, 3_ands_df.csv 2_ands_df.csv \
from_to_df.csv normal_address_df.csv double_dash_to_df.csv \
intersection_df.csv school_park_df.csv leftover_df.csv through_address_df.csv \
and_dash_df.csv mult_ands_df.csv )
INPUTS = $(addprefix ../input/, from_to_df.csv normal_address_df.csv double_dash_to_df.csv df_with_2_ands.csv df_with_3_ands.csv intersection_df.csv school_park_df.csv leftover_df.csv through_address_df.csv \
and_dash_df.csv df_with_mult_ands.csv)
all: $(OUTPUTS)


#OUTPUT RECIPES
.SECONDEXPANSION:
../output/geocoded_%_df.csv: geocode_%_format.R $$(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geocode_$$*_format.R) geocode_function.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

#INPUT RECIPES
$(INPUTS): ../input/%: ../../data_clean_menu_location/output/% | ../input
	ln -s $< $@


include ../../generic.make