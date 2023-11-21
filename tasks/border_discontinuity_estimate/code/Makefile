SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUT = ../output/border_discontinuity_data.rda
TEMP = ../temp/ward_precincts_2012_2022 ../temp/ward_precincts_2003_2011
INPUTS_maps = $(addprefix ../input/, ward_precincts_2003_2011.zip \
ward_precincts_2012_2022.zip)
INPUTS_menu = $(addprefix ../input/, ward_precinct_menu_panel_2003_2011.csv ward_precinct_menu_panel_2012_2022.csv)
all: $(OUTPUT)

#OUTPUT RECIPES
../output/border_discontinuity_table.tex ../output/border_discontinuity_quad_table.tex: estimate_border_discontinuity.R ../input/border_discontinuity_data.csv | ../output
	$(R) --no-job-name $<

#INPUT RECIPES
../input/border_discontinuity_data.csv: ../../border_discontinuity_dataprep/output/border_discontinuity_data.csv | ../input
	ln -s $< $@
include ../../generic.make