SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/off_menu_did.tex ../output/beauty_did.tex

#OUTPUT RECIPES

../output/did_menu.tex:   did_estimation.R $(shell grep -o '../type/[A-Za-z_0-9]*\.[a-z]*' did_estimation.R)  | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

../output/did_beauty.tex:   did_estimation_beauty.R $(shell grep -o '../\(temp\|input\)/[A-Za-z_0-9]*\.[a-z]*' did_estimation_beauty.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
#TEMP RECIPES

../temp/BLP_df.csv ../temp/BLP_df_beauty.csv:   BLP_data_preprocessing.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' BLP_data_preprocessing.R) | ../output ../temp run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
../input/menu_category_panel_df.csv: ../input/%: ../../data_clean_menu/output/% | ../input
	ln -s $< $@
../input/incumbent_voteshare_df.csv: ../input/%: ../../data_clean_elections/output/% | ../input
	ln -s $< $@


include ../../generic.make