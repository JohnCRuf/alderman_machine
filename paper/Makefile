tex_sections := $(shell grep -v '^%' paper.tex | grep -o 'input{[A-Za-z0-9_\/\.]*}' | sed 's/input{//' | sed 's/}$$//')
tex_inputs := $(shell grep -v '^%' $(tex_sections) | grep --no-filename -o 'input{[A-Za-z0-9_\/\.]*}' | sed 's/input{//' | sed 's/}$$//')
img_inputs := $(shell grep --no-filename '\\includegraphics' $(tex_sections) | grep -v '%.*\\includegraphics' | sed 's/^.*\\includegraphics{\([A-Za-z0-9_\/\.]*\)}.*/\1/' | sed 's/^.*\\includegraphics\[.*\]{\([A-Za-z0-9_\/\.]*\)}.*/\1/')

#RECIPES

all: paper.pdf

clean: 
	rm *.aux *.log *.out
	rm sections/*.log

Makefile_dropbox.make: Makefile
	sed 's/ln -s ..\//cp -p /' Makefile | sed 's/^..\/tasks\//#/' | sed '/Makefile_dropbox.make/,/Makefile_dropbox.make/d' | sed '/^# generic/,/notdir $@)/d' > Makefile_dropbox.make

paper.pdf: paper.tex $(tex_sections) $(tex_inputs) $(img_inputs)
	pdflatex -draftmode $<
	bibtex paper.aux
	pdflatex -draftmode $<
	pdflatex $<
	rm paper.aux paper.log paper.out
	rm paper.bbl paper.blg
## INPUTS
DiD_Results = $(foreach did_hist did_plot did_treatmenteffect_plot votershare_histogram, ../input/$(did_hist).png)
input/did_hist.png input/did_plot.png input/did_treatmenteffect_plot.png input/votershare_histogram.png : input/%: ../tasks/DiD_offmenuspending_results/output/%
	cp $< $@
$(addprefix input/, Full_IK_MSE_CER_Bandwidth_comparison_table.tex Full_IK_MSE_CER_Bandwidth_comparison_table_beauty.tex placebo_test_effects.png placebo_test_pvalue.png rdd_density.png RDD_plot.png RDD_statistics.tex off_menu_expenditures_histogram.png voteshare_histogram.png): input/%: ../tasks/estimate_RDD_model/output/%
	cp $< $@
input/spending_histogram%.png: ../tasks/data_menu_summary_statistics/output/spending_histogram%.png | input
	cp $< $@
input/whole_chicago_map%.png: ../tasks/produce_menu_maps/output/whole_chicago_map%.png | input
	cp $< $@
input/contribution_map%.png: ../tasks/produce_contribution_maps/output/contribution_map%.png | input
	cp $< $@
input/ward_50_2007_runoff%.png: ../tasks/produce_election_maps/output/ward_50_2007_runoff%.png | input
	cp $< $@
input/ward_50_menu_map_%.png: ../tasks/produce_menu_maps/output/ward_50_menu_map_%.png | input
	cp $< $@
input/ward_50_contribution_%_timeline.png: ../tasks/case_study_ward_50_eventstudy_exhibit/output/ward_50_contribution_%_timeline.png | input
	cp $< $@
input/hte_figure_%.png: ../tasks/model_estimate_did/output/hte_figure_%.png | input
	cp $< $@

input/%_over_time.png: ../tasks/model_exhibit_did/output/%_over_time.png | input
	cp $< $@
input/%_variation.png: ../tasks/model_exhibit_did/output/%_variation.png | input
	cp $< $@