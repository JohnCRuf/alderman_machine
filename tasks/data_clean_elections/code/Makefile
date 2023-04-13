SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/incumbent_voteshare_df.csv ../output/incumbents_list.RDS ../output/incumbents_all.RDS ../output/aggregate_candidate_df.csv

#OUTPUT RECIPES

../output/incumbent_voteshare_df.csv ../output/incumbents_list.RDS ../output/incumbents_all.RDS ../output/aggregate_candidate_df.csv:   elections_incumbent_cleaning.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' elections_incumbent_cleaning.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
../input/elections.csv: ../input/%: ../../data_scrape_elections/output/% | ../input
	ln -s $< $@



include ../../generic.make