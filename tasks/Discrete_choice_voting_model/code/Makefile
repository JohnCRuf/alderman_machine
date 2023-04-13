SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/voteshare_off_menu_ols.tex ../output/voteshare_off_menu_BLP.tex ../output/voteshare_beauty_ols.tex ../output/voteshare_beauty_BLP.tex

#OUTPUT RECIPES

../output/voteshare_off_menu_ols.tex ../output/voteshare_off_menu_BLP.tex:   BLP_model_estimation.R $(shell grep -o '../\(temp\|input\)/[A-Za-z_0-9]*\.[a-z]*' BLP_model_estimation.R)  | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

../output/voteshare_beauty_ols.tex ../output/voteshare_beauty_BLP.tex:   BLP_model_estimation_beauty.R $(shell grep -o '../\(temp\|input\)/[A-Za-z_0-9]*\.[a-z]*' BLP_model_estimation_beauty.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
#TEMP RECIPES

../temp/BLP_df.csv ../temp/BLP_df_beauty.csv:   BLP_data_preprocessing.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' BLP_data_preprocessing.R) | ../output ../temp run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
../input/menu_panel_df.csv ../input/menu_panel_df_beauty.csv: ../input/%: ../../menumoney_datacleaner/output/% | ../input
	ln -s $< $@
../input/incumbent_voteshare_df.csv: ../input/%: ../../elections_data_cleaning/output/% | ../input
	ln -s $< $@


include ../../generic.make