logbookentries := $(shell grep 'entries' logbook.tex | grep -v '^%' | grep -o 'entries/[A-Za-z0-9_]*\.tex')
img_inputs := $(shell grep '\\includegraphics' $(logbookentries) | grep -v '%.*\\includegraphics' | sed 's/^.*\\includegraphics\[.*\]{\([\./a-zA-Z0-9_]*\)}.*/\1/')
tex_inputs := $(shell grep --no-filename '\\input' $(logbookentries) | grep -v '^%' | grep -o 'input{[A-Za-z0-9_\/\.]*}'  | sed 's/input{//' | sed 's/}$$//')

all: logbook.pdf
clean_tex:
	rm *.log *.out *.toc *.aux

logbook.bbl: ../bib/machine.bib | logbook.tex #This will only rebuild logbook.bbl when the .bib file is edited; if .bib contains references that weren't used previously, must force this to build
	pdflatex -draftmode logbook.tex
	rm logbook.log logbook.out logbook.toc
	bibtex logbook.aux
	rm logbook.blg


logbook.pdf: logbook.tex $(logbookentries) $(img_inputs) $(tex_inputs) logbook.bbl
	pdflatex -draftmode -shell-escape $<
	pdflatex $<
	rm $(addprefix $(basename $<),.log .out .aux .toc)

minutes_log_%.pdf: entries/minutes_log_%.tex
	pdflatex -draftmode $<
	pdflatex $<

# INPUTS
input:
	mkdir $@
input/twfe_table_%.tex: ../tasks/model_estimate_did/output/twfe_table_%.tex | input
	cp $< $@
