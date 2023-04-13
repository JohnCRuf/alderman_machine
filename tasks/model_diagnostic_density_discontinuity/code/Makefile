SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/total_incumbent_density_discontinuity.png ../output/incumbent_density_discontinuity_overtime.png

#OUTPUT RECIPES

 ../output/total_incumbent_density_discontinuity.png:   density_discontinuity_all.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[A-Z|a-z]*' density_discontinuity_all.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
../output/incumbent_density_discontinuity_overtime.png:  density_discontinuity_overtime.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[A-Z|a-z]*' density_discontinuity_overtime.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
../input/incumbent_voteshare_df.csv: ../input/%: ../../elections_data_cleaning/output/% | ../input
	ln -s $< $@
../input/RDD_functions.R: ../input/%: ../../estimate_RDD_model/code/% | ../input
	ln -s $< $@



include ../../generic.make