SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
reports = $(addprefix ../report/, \
	incumbent_voteshare_df_ward_level.csv.log \
	incumbent_challenger_voteshare_df_precinct_level.csv.log)
all: ../output/incumbent_voteshare_df_ward_level.csv ../output/incumbent_challenger_voteshare_df_precinct_level.csv $(reports)

#OUTPUT RECIPES

../output/incumbent_voteshare_df_ward_level.csv: ward_level_elections_incumbent_cleaning.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' ward_level_elections_incumbent_cleaning.R) | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
../output/incumbent_challenger_voteshare_df_precinct_level.csv: precinct_level_elections_incumbent_cleaning.R $(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' precinct_level_elections_incumbent_cleaning.R) ../output/incumbent_voteshare_df_ward_level.csv | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
../input/elections.csv: ../input/%: ../../data_scrape_elections/output/% | ../input
	ln -s $< $@



include ../../generic.make