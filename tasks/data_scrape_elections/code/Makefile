SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/elections.csv

#OUTPUT RECIPES

../output/elections.csv: elections_webscraping.R chicago_elections_webscraping_fn.R | ../output run.sbatch slurmlogs
	$(R) --no-job-name $<
#INPUT RECIPES
include ../../generic.make