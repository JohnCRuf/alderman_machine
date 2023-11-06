SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
alders = austin beale brookins burke burnett cochran daley mitts moreno munoz reboyras solis stone tunney zalewski
OUTPUTS = $(foreach alder, $(alders), $(foreach map, 2003_2011 2012_2022, ../output/$(alder)_contribution_panel_$(map).rds))

INPUTS_maps = $(addprefix ../input/, ward_precincts_2012_2022.zip ward_precincts_2003_2011.zip)
all: $(OUTPUTS)

#OUTPUT RECIPES
../output/%_contribution_panel_2012_2022.rds : combine_geomatched_contributions.R  ../input/geomatched_%_contributions_2012_2022.csv ../temp/ward_precincts_2012_2022 ../input/map_data_prep_fn.R | ../output
	$(R) --no-job-name $< ../input/geomatched_$*_contributions_2012_2022.csv 2012_2022 $@

../output/%_contribution_panel_2003_2011.rds: combine_geomatched_contributions.R  ../input/geomatched_%_contributions_2003_2011.csv ../temp/ward_precincts_2003_2011 ../input/map_data_prep_fn.R | ../output
	$(R) --no-job-name $< ../input/geomatched_$*_contributions_2003_2011.csv 2003_2011 $@
#TEMP RECIPES
../temp/ward_precincts_%: ../input/ward_precincts_%.zip | ../temp
	unzip -o -d ../temp/ward_precincts_$* $<
	for file in ../temp/ward_precincts_$*/* ; do \
		mv $$file ../temp/ward_precincts_$*/ward_precincts_$*.`basename $$file | sed 's/.*\.//'`; \
	done
#INPUT RECIPES
../input/geomatched_%.csv: ../../data_geomatch_contribution/output/geomatched_%.csv | ../input
	ln -s $< $@
../input/map_data_prep_fn.R: ../../data_geomatch_menu/code/map_data_prep_fn.R | ../input
	ln -s $< $@
$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@

include ../../generic.make