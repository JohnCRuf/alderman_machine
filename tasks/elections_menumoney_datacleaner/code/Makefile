SHELL=bash
include ../../shell_functions.make

INPUTS_menu = $(foreach range, 2005_2010 2011_2015 2016_2022, ../input/menu_$(range).csv)
## DEFINITIONS

all: ../output/menu_panel_df.csv

#OUTPUT RECIPES

../output/menu_panel_df_beauty.csv ../output/menu_panel_df.csv:   menu_money_cleaner.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' menu_money_cleaner.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

#INPUT RECIPES
../input/elections.csv: ../input/%: ../../webscrape_elections_data/output/% | ../input
	ln -s $< $@
$(INPUTS_menu): ../input/%: ../../gather_menu_data/output/% | ../input
	ln -s $< $@


include ../../generic.make