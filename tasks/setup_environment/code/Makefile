SHELL=bash
include ../../shell_functions.make

all: ../output/R_packages.txt ../output/python_packages.txt

../output/R_packages.txt: packages.R | ../output
	$(R) $<
../output/python_packages.txt: packages.py | ../output
	$(PYTHON) $<

include ../../generic.make

