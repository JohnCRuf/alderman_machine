SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/incumbent_voteshare_df.csv

#OUTPUT RECIPES

../output/incumbent_voteshare_df.csv ../output/incumbents_list.RDS:   elections_incumbent_cleaning.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' elections_incumbent_cleaning.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<

#INPUT RECIPES
../input/elections.csv: ../input/%: ../../webscrape_elections_data/output/% | ../input
	ln -s $< $@



include ../../generic.make