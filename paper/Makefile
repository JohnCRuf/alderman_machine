## DEFINITIONS
FOLDERS = input
PAPER_SECTIONS = $(shell grep '\\input' paper.tex  | grep -v '%.*\\input' | sed 's/^.*\\input{\(.*\.tex\)}.*/\1/')
PAPER_INPUTS_TEX = $(shell grep '\\input{' $(PAPER_SECTIONS) | grep -v '%.*\\input' | sed 's/^.*\\input{\(.*\.tex\)}.*/\1/')
PAPER_INPUTS_IMG = $(shell grep --no-filename '\\includegraphics' $(PAPER_SECTIONS) | grep -v '%.*\\includegraphics' | sed 's/^.*\\includegraphics\[.*\]{\(.*\)}.*/\1/')

## RECIPES

all: $(FOLDERS) $(PAPER_INPUTS_TEX) $(PAPER_INPUTS_IMG) paper.pdf

$(FOLDERS):
	mkdir $@

paper.pdf: paper.tex $(PAPER_INPUTS_TEX) $(PAPER_INPUTS_IMG)
	if command -v sbatch > /dev/null ; then module load texlive; fi
	pdflatex -draftmode paper.tex
	bibtex paper.aux
	pdflatex -draftmode paper.tex
	pdflatex paper.tex
	rm paper.log paper.aux paper.out
	rm paper.bbl paper.blg
## INPUTS
DiD_Results = $(foreach did_hist did_plot did_treatmenteffect_plot votershare_histogram, ../input/$(did_hist).png)
input/did_hist.png input/did_plot.png input/did_treatmenteffect_plot.png input/votershare_histogram.png : input/%: ../tasks/DiD_offmenuspending_results/output/%
	cp $< $@
$(addprefix input/, Full_IK_MSE_CER_Bandwidth_comparison_table.tex Full_IK_MSE_CER_Bandwidth_comparison_table_beauty.tex placebo_test_effects.png placebo_test_pvalue.png rdd_density.png RDD_plot.png RDD_statistics.tex off_menu_expenditures_histogram.png voteshare_histogram.png): input/%: ../tasks/estimate_RDD_model/output/%
	cp $< $@