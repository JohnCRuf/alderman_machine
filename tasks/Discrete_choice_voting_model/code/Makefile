SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/menu_panel_df_beauty.csv ../output/menu_panel_df.csv

#OUTPUT RECIPES

../output/voteshare_off_menu_ols.tex ../output/voteshare_off_menu_BLP.tex:   BLP_model_estimation.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' BLP_model_estimation.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

../output/voteshare_beauty_ols.tex ../output/voteshare_beauty_BLP.tex:   BLP_model_estimation_beauty.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' BLP_model_estimation_beauty.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
#TEMP RECIPES

../temp/BLP_df.csv ../temp/BLP_df_beauty.csv:   BLP_data_preprocessing.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' BLP_data_preprocessing.R) | ../output ../temp run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
../input/elections.csv: ../input/%: ../../webscrape_elections_data/output/% | ../input
	ln -s $< $@
../input/menu.csv: ../input/%: ../../initialdata/output/% | ../input
	ln -s $< $@


include ../../generic.make