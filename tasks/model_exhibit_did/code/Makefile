SHELL=bash
include ../../shell_functions.make

#DEFINITIONS:
support := top bottom
close_cutoff := 0.05 1.0 #cutoffs for "close" elections
precinct_count := $(shell seq 5 1 12)
triples = $(foreach sup, $(support), $(foreach count, $(precinct_count), $(foreach cutoff, $(close_cutoff), $(cutoff)_$(count)_$(sup))))
INPUT_files := $(foreach triple, $(triples), ../input/close_runoffs_combined_$(triple)_estimate_agg.txt)


all: ../output/close_elections_precinct_variation.png ../output/corruption_precinct_variation.png ../output/close_elections_top_8_over_time.png ../output/close_elections_bottom_8_over_time.png ../output/corruption_top_8_over_time.png ../output/corruption_bottom_8_over_time.png 




#Temp csv files to aggregate DiD results

../temp/did_agg_results_close.csv: $(INPUT_files) | ../temp
	echo "Filename,ATT,Std. Error,Lower CI,Upper CI" > $@; \
	for file in $(INPUT_files); do \
		line=$$(sed -n '10p' $$file); \
		att=$$(echo $$line | awk '{print $$1}'); \
		std_error=$$(echo $$line | awk '{print $$2}'); \
		lower_ci=$$(echo $$line | awk '{print $$3}'); \
		upper_ci=$$(echo $$line | awk '{print $$4}'); \
		filename=$$(basename $$file); \
		echo "$$filename,$$att,$$std_error,$$lower_ci,$$upper_ci" >> $@; \
	done

TEMP_CSV_EFFECTS := ../temp/dynamic_effects.csv

# Rule for creating the dynamic effects CSV
../temp/did_time_results_close.csv: $(INPUT_files) | ../temp
	echo "Filename,Event Time,Estimate,Std. Error,Lower CI,Upper CI" > $@; \
	for file in $(INPUT_files); do \
		filename=$$(basename $$file); \
		sed -n '15,28p' $$file | awk -v OFS=',' -v file="$$filename" '{print file, $$1, $$2, $$3, $$4, $$5}' >> $@; \
	done

$(INPUT_files): ../input/%: ../../model_estimate_did/output/% | ../input
	ln -s $< $@
include ../../generic.make