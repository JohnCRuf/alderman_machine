SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
shapes = point line quad pent
OUTPUTS = $(foreach shape, $(shapes), ../output/geocoded_$(shape)_df.csv)
INPUTS = $(foreach shape, $(shapes), ../input/menu_data_$(shape).csv)
all: $(OUTPUTS)


#OUTPUT RECIPES
.SECONDEXPANSION:
../output/geocoded_%_df.csv: geocode_%_format.R $$(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geocode_$$*_format.R) geocode_function.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

#INPUT RECIPES
$(INPUTS): ../input/%: ../../data_clean_menu_location/output/% | ../input
	ln -s $< $@


include ../../generic.make