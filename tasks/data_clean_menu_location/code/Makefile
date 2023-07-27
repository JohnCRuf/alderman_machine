SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUT = $(addprefix ../output/, from_to_df.csv normal_address_df.csv double_dash_to_df.csv df_with_2_ands.csv df_with_3_ands.csv intersection_df.csv school_park_df.csv leftover_df.csv)
all: $(OUTPUT)

#OUTPUT RECIPES
$(OUTPUT):   clean_menu_location.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' clean_menu_location.R) intersection_generation_fn.R ordinal_indicator_fn.R keyword_fn.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
../input/menu_df.csv: ../input/%: ../../data_clean_menu_money/output/% | ../input
	ln -s $< $@


include ../../generic.make