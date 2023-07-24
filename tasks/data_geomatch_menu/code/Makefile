SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUTS = $(addprefix ../output/geomatched_, 3_ands_df.csv 2_ands_df.csv \
from_to_df.csv normal_address_df.csv double_dash_to_df.csv \
intersection_df.csv school_park_df.csv leftover_df.csv through_address_df.csv)
INPUTS_csv = $(addprefix ../input/geolocated_, 3_ands_df.csv 2_ands_df.csv \
from_to_df.csv normal_address_df.csv double_dash_to_df.csv \
intersection_df.csv school_park_df.csv leftover_df.csv through_address_df.csv)
INPUTS_maps = $(addprefix ../input/, ward_precincts_2003_2011.zip \
ward_precincts_2012_2022.zip)
all: $(OUTPUTS)


#OUTPUT RECIPES
.SECONDEXPANSION:
../output/geomatched_%_df.csv: geomatch_%_format.R $$(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geomatch_$$*_format.R) $$(shell grep -o 'geomatch_[A-Za-z_0-9]*\.R' geomatch_$$*_format.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

#TEMP RECIPES
../temp/ward_precincts_%: ../input/ward_precincts_%.zip | ../temp
	unzip -d ../temp/ward_precincts_$* $<


#INPUT RECIPES
$(INPUTS_csv): ../input/%.csv: ../../data_geocode_menu/output/%.csv | ../input
	ln -s $< $@

$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@
include ../../generic.make