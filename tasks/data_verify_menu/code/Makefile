SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
all: ../output/menu_total_errors.csv

#OUTPUT RECIPES
../output/menu_total_errors.csv: verify_menu_totals.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[A-Z|a-z]*' verify_menu_totals.R) | ../output
	$(R) verify_menu_totals.R $^ $@

#INPUT RECIPES
../input/menu_df.csv: ../../menumoney_datacleaner/output/menu_df.csv | ../input
	ln -s $< $@
../input/menu_totals.csv: ../../gather_menu_data/output/menu_totals.csv | ../input
	ln -s $< $@


include ../../generic.make