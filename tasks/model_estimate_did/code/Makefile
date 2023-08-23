SHELL=bash
include ../../shell_functions.make
## DEFINITIONS
years := 2019 #years to include in the analysis
close_cutoff := 0.05 #cutoffs for "close" elections
precinct_count := 5 10 15 #number of "most-supporting" precincts to include in the analysis
close_election_triples = $(foreach year, $(years), $(foreach cutoff, $(close_cutoff), $(foreach precinct, $(precinct_count), year_$(year)_cutoff_$(cutoff)_count_$(precinct))))


OUTPUTS_close_TWFE = $(foreach triple, $(close_election_triples), ../output/twfe_table_$(triple).tex)
all: $(OUTPUTS_close_TWFE)

#OUTPUT RECIPES
../output/twfe_table_%.tex: estimate_twfe_did.R ../input/close_runoffs_%.rda | ../output run.sbatch slurmlogs
	$(R) $^ $*
#INPUT RECIPES
../input/%: ../../model_dataprep_did/output/% | ../input
	ln -s $< $@

include ../../generic.make