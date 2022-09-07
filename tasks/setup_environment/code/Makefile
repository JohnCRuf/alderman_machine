SHELL=bash
include ../../shell_functions.make

all: ../output/R_packages.txt

../output/R_packages.txt: packages.R | ../output
	$(R) $<

include ../../generic.make

