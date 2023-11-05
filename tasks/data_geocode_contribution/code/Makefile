SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
alders = austin beale brookins burke burnett cochran daley mitts moreno munoz reboyras solis stone tunney zalewski
INPUT_data = $(foreach alder, $(alders), ../input/$(alder)_receipts.csv)
OUTPUTS = $(foreach alder, $(alders), ../output/geocoded_$(alder).csv)
all: $(OUTPUTS)


#OUTPUT RECIPES
../output/geocoded_%.csv: geocode_contributions.R ../input/%_receipts.csv ../input/geocode_function.R | ../output
	$(R) $< ../input/$*_receipts.csv $@
#INPUT RECIPES
$(INPUT_data): ../input/%: ../../initialdata/output/% | ../input
	ln -s $< $@
../input/geocode_function.R: ../../data_geocode_menu/code/geocode_function.R | ../input
	ln -s $< $@

include ../../generic.make