SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
alders = austin beale brookins burke burnett cochran daley mitts moreno munoz reboyras solis stone tunney zalewski
inputs = $(foreach alder, $(alders), ../input/$(alder)_contribution_panel_2003_2011.rds ../input/$(alder)_contribution_panel_2012_2022.rds)
OUTPUT = ../output/contribution_map_burke_ward_14_2012_2022.png ../output/contribution_map_stone_ward_50_2003_2011.png
all: $(OUTPUT)

#OUTPUT RECIPES
../output/contribution_map_burke_ward_14_%.png: contribution_map_production.R ../input/burke_contribution_panel_%.rds  | ../output
	$(R) $< ../input/burke_contribution_panel_$*.rds 14 $(subst ward,, $(subst _, ,$*)) $@
../output/contribution_map_stone_ward_50_2003_2011.png: contribution_map_production.R ../input/stone_contribution_panel_2003_2011.rds  | ../output
	$(R) $< ../input/stone_contribution_panel_2003_2011.rds 50 2003 2011 $@

#INPUT RECIPES 
$(inputs): ../input/%.rds: ../../data_combine_geomatched_contribution/output/%.rds | ../input
	ln -s $< $@

include ../../generic.make