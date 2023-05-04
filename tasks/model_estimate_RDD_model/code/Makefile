SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUTS = $(addprefix ../output/, Full_IK_MSE_CER_Bandwidth_comparison_table.tex Full_IK_MSE_CER_Bandwidth_comparison_table_beauty.tex placebo_test_pvalue.png placebo_test_effectsize.png RDD_plot.png RDD_statistics.png off_menu_expenditures_histogram.png)
all: $(OUTPUTS)

#OUTPUT RECIPES

../output/Full_IK_MSE_CER_Bandwidth_comparison_table_beauty.tex: RDD_Model_beauty.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' RDD_Model_beauty.R) $(shell grep -o '../temp/[A-Za-z_0-9]*\.[a-z]*' RDD_Model_beauty.R) RDD_frunctions.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
../output/Full_IK_MSE_CER_Bandwidth_comparison_table.tex: RDD_Model.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' RDD_Model.R) $(shell grep -o '../temp/[A-Za-z_0-9]*\.[a-z]*' RDD_Model.R) RDD_frunctions.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
../output/placebo_test_pvalue.png ../output/placebo_test_effectsize.png: RDD_Diagnostics.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' RDD_Diagnostics.R) $(shell grep -o '../temp/[A-Za-z_0-9]*\.[a-z]*' RDD_Diagnostics.R) RDD_frunctions.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
../output/RDD_plot.png  ../output/RDD_statistics.png ../output/off_menu_expenditures_histogram.png: RDD_Plot.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' RDD_Plot.R) $(shell grep -o '../temp/[A-Za-z_0-9]*\.[a-z]*' RDD_Plot.R) RDD_frunctions.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
#TEMP RECIPES
../temp/RDD_df.csv ../temp/RDD_df_beauty.csv: RDD_data_preprocessing.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' RDD_data_preprocessing.R) | ../temp run.sbatch slurmlogs
	$(R) --no-job-name $<

#INPUT RECIPES
../input/menu_category_panel_df.csv ../input/menu_category_panel_df_beauty.csv: ../input/%: ../../elections_menumoney_datacleaner/output/% | ../input
	ln -s $< $@
../input/incumbent_voteshare_df.csv ../input/incumbents_list.RDS: ../input/%: ../../elections_data_cleaning/output/% | ../input
	ln -s $< $@



include ../../generic.make