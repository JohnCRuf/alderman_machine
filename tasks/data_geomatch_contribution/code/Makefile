SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
alders = austin beale brookins burke burnett cochran daley mitts moreno munoz reboyras solis stone tunney zalewski
OUTPUTS = $(foreach alder, $(alders), $(foreach map, 2003_2011 2012_2022, ../output/geomatched_$(alder)_contributions_$(map).csv))
INPUTS_maps = $(addprefix ../input/, ward_precincts_2003_2011.zip \
ward_precincts_2012_2022.zip)

all: $(OUTPUTS)

#OUTPUT RECIPES
.SECONDEXPANSION:
../output/geomatched_%_contributions_2003_2011.csv: geomatch_campaign_contributions.R ../input/geocoded_%.csv $$(shell grep -o '../input/[A-Za-z_0-9]*\.[a-zA-Z]*' geomatch_campaign_contributions.R) ../temp/ward_precincts_2003_2011 | ../output run.sbatch slurmlogs
	$(R) --no-job-name $< ../input/geocoded_$*.csv ../temp/ward_precincts_2003_2011/ward_precincts_2003_2011.shp $@

.SECONDEXPANSION:
../output/geomatched_%_contributions_2012_2022.csv:  geomatch_campaign_contributions.R ../input/geocoded_%.csv $$(shell grep -o '../input/[A-Za-z_0-9]*\.[a-zA-Z]*' geomatch_campaign_contributions.R) ../temp/ward_precincts_2012_2022 | ../output run.sbatch slurmlogs
	$(R) --no-job-name $< ../input/geocoded_$*.csv ../temp/ward_precincts_2012_2022/ward_precincts_2012_2022.shp $@
#TEMP RECIPES
../temp/ward_precincts_%: ../input/ward_precincts_%.zip | ../temp
	unzip -o -d ../temp/ward_precincts_$* $<
	for file in ../temp/ward_precincts_$*/* ; do \
		mv $$file ../temp/ward_precincts_$*/ward_precincts_$*.`basename $$file | sed 's/.*\.//'`; \
	done
#INPUT RECIPES
../input/geocoded_%.csv: ../../data_geocode_contribution/output/geocoded_%.csv | ../input
	ln -s $< $@
$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@
../input/map_data_prep_fn.R: ../../data_geomatch_menu/code/map_data_prep_fn.R | ../input
	ln -s $< $@
../input/geomatch_points_fn.R: ../../data_geomatch_menu/code/geomatch_points_fn.R | ../input
	ln -s $< $@
include ../../generic.make