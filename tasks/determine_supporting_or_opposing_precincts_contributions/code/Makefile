SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
alders = austin_34 beale_9 brookins_21 burke_14 burnett_27 cochran_20 \
daley_11 mitts_37 moreno_1 munoz_22 reboyras_30 solis_25  \
stone_50 tunney_44 zalewski_23 
OUTPUTS = $(foreach alder, $(alders), $(foreach map, 2003_2011 2012_2022, ../output/$(alder)_supporting_opposing_precincts_$(map).csv))

INPUTS_maps = $(addprefix ../input/, ward_precincts_2012_2022.zip ward_precincts_2003_2011.zip)
all: $(OUTPUTS)

#OUTPUT RECIPES
.SECONDEXPANSION:
../output/%_supporting_opposing_precincts_2003_2011.csv: determine_supporting_or_opposing_precincts_contributions_2003_2011.R ../input/$$(shell echo $$* | sed 's/[0-9_]//g')_contribution_panel_2003_2011.rds  | ../output
	$(R) --no-job-name $<  ../input/$(shell echo $* | sed 's/[0-9_]//g')_contribution_panel_2003_2011.rds $(shell echo $* | sed 's/[a-z_]//g') $@

../output/%_supporting_opposing_precincts_2012_2022.csv: determine_supporting_or_opposing_precincts_contributions_2012_2022.R ../input/$$(shell echo $$* | sed 's/[0-9_]//g')_contribution_panel_2012_2022.rds  | ../output
	$(R) --no-job-name $< ../input/$(shell echo $* | sed 's/[0-9_]//g')_contribution_panel_2012_2022.rds $(shell echo $* | sed 's/[a-z_]//g') $@
#INPUT RECIPES
../input/%_contribution_panel_2012_2022.rds : ../../data_combine_geomatched_contribution/output/%_contribution_panel_2012_2022.rds | ../input
	ln -s $< $@
../input/%_contribution_panel_2003_2011.rds: ../../data_combine_geomatched_contribution/output/%_contribution_panel_2003_2011.rds | ../input
	ln -s $< $@
../input/map_data_prep_fn.R: ../../data_geomatch_menu/code/map_data_prep_fn.R | ../input
	ln -s $< $@
$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@

include ../../generic.make