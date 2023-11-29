SHELL=bash
include ../../shell_functions.make

#DEFINITIONS:
support := top bottom
close_cutoff := 0.05
precinct_count := $(shell seq 6 1 12)
triples = $(foreach sup, $(support), $(foreach count, $(precinct_count), $(foreach cutoff, $(close_cutoff), $(cutoff)_$(count)_$(sup))))
INPUT_files_close := $(foreach triple, $(triples), ../input/close_runoffs_combined_$(triple)_estimate_agg.txt)
INPUT_files_corruption := $(foreach precinct, $(precinct_count), $(foreach support, $(support), ../input/corruption_$(precinct)_precincts_$(support)_estimate_agg.txt))


all: ../output/close_elections_precinct_variation.png ../output/corruption_precinct_variation.png ../output/close_elections_8_top_over_time.png ../output/close_elections_8_bottom_over_time.png ../output/corruption_8_top_over_time.png ../output/corruption_8_bottom_over_time.png 
temp: ../temp/did_agg_results_close.csv ../temp/did_agg_results_corrupt.csv ../temp/did_time_results_close.csv ../temp/did_time_results_corrupt.csv
precinct_var: ../output/close_elections_precinct_variation.png ../output/corruption_precinct_variation.png

#OUTPUT RECIPES
../output/close_elections_precinct_variation.png: exhibit_precinct_variation.R ../temp/did_agg_results_close.csv | ../output run.sbatch slurmlogs
	$(R) $^ $@

../output/corruption_precinct_variation.png: exhibit_precinct_variation.R ../temp/did_agg_results_corrupt.csv | ../output run.sbatch slurmlogs
	$(R) $^ $@

../output/close_elections_8_top_over_time.png ../output/close_elections_8_bottom_over_time.png: exhibit_over_time_close.R ../temp/did_time_results_close.csv | ../output run.sbatch slurmlogs
	$(R) $^ $@

../output/corruption_8_top_over_time.png ../output/corruption_8_bottom_over_time.png: exhibit_over_time_corrupt.R ../temp/did_time_results_corrupt.csv | ../output run.sbatch slurmlogs
	$(R) $^ $@


#Temp csv files to aggregate DiD results
../temp/did_agg_results_close.csv: $(INPUT_files_close) | ../temp
	echo "filename,att,std_error,lower_ci,upper_ci" > $@; \
	for file in $(INPUT_files_close); do \
		line=$$(sed -n '10p' $$file); \
		att=$$(echo $$line | awk '{print $$1}'); \
		std_error=$$(echo $$line | awk '{print $$2}'); \
		lower_ci=$$(echo $$line | awk '{print $$3}'); \
		upper_ci=$$(echo $$line | awk '{print $$4}'); \
		filename=$$(basename $$file); \
		echo "$$filename,$$att,$$std_error,$$lower_ci,$$upper_ci" >> $@; \
	done

../temp/did_agg_results_corrupt.csv: $(INPUT_files_corruption) | ../temp
	echo "filename,att,std_error,lower_ci,upper_ci" > $@; \
	for file in $(INPUT_files_corruption); do \
		line=$$(sed -n '10p' $$file); \
		att=$$(echo $$line | awk '{print $$1}'); \
		std_error=$$(echo $$line | awk '{print $$2}'); \
		lower_ci=$$(echo $$line | awk '{print $$3}'); \
		upper_ci=$$(echo $$line | awk '{print $$4}'); \
		filename=$$(basename $$file); \
		echo "$$filename,$$att,$$std_error,$$lower_ci,$$upper_ci" >> $@; \
	done

../temp/did_time_results_close.csv: $(INPUT_files_close) | ../temp
	echo "filename,event_time,estimate,std_error,lower_ci,upper_ci" > $@; \
	for file in $(INPUT_files_close); do \
		filename=$$(basename $$file); \
		sed -n '15,28p' $$file | awk -v OFS=',' -v file="$$filename" '{print file, $$1, $$2, $$3, $$4, $$5}' >> $@; \
	done

../temp/did_time_results_corrupt.csv: $(INPUT_files_corruption) | ../temp
	echo "filename,event_time,estimate,std_error,lower_ci,upper_ci" > $@; \
	for file in $(INPUT_files_corruption); do \
		filename=$$(basename $$file); \
		sed -n '15,24p' $$file | awk -v OFS=',' -v file="$$filename" '{print file, $$1, $$2, $$3, $$4, $$5}' >> $@; \
	done

$(INPUT_files_close): ../input/%: ../../model_estimate_did/output/% | ../input
	ln -s $< $@
$(INPUT_files_corruption): ../input/%: ../../model_estimate_did/output/% | ../input
	ln -s $< $@
include ../../generic.make