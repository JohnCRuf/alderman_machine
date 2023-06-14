SHELL=bash
include ../../shell_functions.make

all: ../output/R_packages.txt ../output/python_packages.txt ../output/R_environ.txt
.PHONEY: R_environ

../output/R_packages.txt: packages.R | ../output
	$(R) $<
../output/python_packages.txt: packages.py | ../output
	python $<
../output/R_environ.txt: set_R_environ.R | ../output
	$(R) $<

include ../../generic.make

