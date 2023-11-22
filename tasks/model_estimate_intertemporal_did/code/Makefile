SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/corruption_intertemporal.csv ../output/close_runoffs_combined_intertemporal.csv

#OUTPUT RECIPES
../output/intertemporal_runoff_estimates.txt: estimate_intertemporal_did_competitive.do ../input/close_runoffs_combined_intertemporal.csv | ../output run.sbatch slurmlogs
	$(STATA) $<
#INPUT RECIPES
../input/close_runoffs_combined_intertemporal.csv: ../../model_dataprep_intertemporal_did/output/close_runoffs_combined_intertemporal.csv | ../input
	ln -s $< $@
../input/corruption_intertemporal_did_panel.csv: ../../model_dataprep_intertemporal_did/output/corruption_intertemporal_did_panel.csv | ../input
	ln -s $< $@
include ../../generic.make