SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/Full_IK_MSE_CER_Bandwidth_comparison_table.tex

#OUTPUT RECIPES

../output/Full_IK_MSE_CER_Bandwidth_comparison_table_beauty.tex: RDD_Model_beauty.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' RDD_Model_beauty.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
../output/Full_IK_MSE_CER_Bandwidth_comparison_table.tex: RDD_Model.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' RDD_Model.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
../output/placebo_test_pvalue.png ../output/placebo_test_effectsize.png: RDD_Diagnostics.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' RDD_Diagnostics.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
../output/RDD_plot.png  ../output/RDD_statistics.png ../output/off_menu_expenditures_histogram.png: RDD_plot.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' RDD_plot.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
#TEMP RECIPES
../temp/RDD_df.csv ../temp/RDD_df_beauty.csv: RDD_data_preprocessing.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' RDD_data_preprocessing.R) | ../temp run.sbatch slurmlogs
	$(R) --no-job-name $<

#INPUT RECIPES
../input/elections.csv: ../input/%: ../../webscrape_elections_data/output/% | ../input
	ln -s $< $@



include ../../generic.make