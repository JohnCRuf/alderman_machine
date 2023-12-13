SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUT = ../output/ward_needs_data.csv ../output/log_cubed_model.rds
TEMP = ../temp/ward_precincts_2012_2022 ../temp/ward_precincts_2003_2011
INPUTS_maps = $(addprefix ../input/, ward_precincts_2003_2011.zip \
ward_precincts_2012_2022.zip)
all: $(OUTPUT)

#OUTPUT RECIPES
$(OUTPUT): impute_needs.R $(TEMP) ../input/map_data_prep_fn.R ../input/oig_audit_needs.csv | ../output
	$(R) --no-job-name $<

#TEMP RECIPES
../temp/ward_precincts_%: ../input/ward_precincts_%.zip | ../temp
	unzip -o -d ../temp/ward_precincts_$* $<
	for file in ../temp/ward_precincts_$*/* ; do \
		mv $$file ../temp/ward_precincts_$*/ward_precincts_$*.`basename $$file | sed 's/.*\.//'`; \
	done
#INPUT RECIPES
../input/oig_audit_needs.csv: ../input/%: ../../initialdata/output/% | ../input
	ln -s $< $@
../input/map_data_prep_fn.R: ../input/%: ../../data_geomatch_menu/code/% | ../input
	ln -s $< $@
$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@
include ../../generic.make