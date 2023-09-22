SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
types = point line quad pent
OUTPUT = $(foreach type, $(types), ../output/menu_data_$(type).csv)
TEMP = $(addprefix ../temp/, from_to_df.csv normal_address_df.csv double_dash_to_df.csv df_with_2_ands.csv df_with_3_ands.csv intersection_df.csv school_park_df.csv and_dash_df.csv leftover_df.csv)
all: $(OUTPUT)
test: $(TEMP)

#OUTPUT RECIPES
$(OUTPUT): compile_menu_location.R $(TEMP) | ../output
	$(R) --no-job-name $<
#TEMP RECIPES
$(TEMP): clean_menu_location.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' clean_menu_location.R) intersection_generation_fn.R ordinal_indicator_fn.R editing_fns.R | ../temp run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
../input/menu_df.csv: ../input/%: ../../data_clean_menu_money/output/% | ../input
	ln -s $< $@


include ../../generic.make