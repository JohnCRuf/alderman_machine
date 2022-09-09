SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/menu_panel_df_beauty.csv ../output/menu_panel_df.csv

#OUTPUT RECIPES

../output/menu_panel_df_beauty.csv ../output/menu_panel_df.csv:   menu_money_cleaner.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' menu_money_cleaner.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

#INPUT RECIPES
../input/elections.csv: ../input/%: ../../webscrape_elections_data/output/% | ../input
	ln -s $< $@
../input/menu.csv: ../input/%: ../../initialdata/output/% | ../input
	ln -s $< $@


include ../../generic.make