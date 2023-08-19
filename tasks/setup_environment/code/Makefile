SHELL=bash
CONDA_BIN?=conda
include ../../shell_functions.make

all: ../output/R_packages.txt ../output/conda_install_log.txt ../output/R_environ.txt
.PHONEY: R_environ

../output/R_packages.txt: packages.R | ../output
	$(R) $<

../output/conda_install_log.txt: python_environment.txt | ../output
	$(CONDA_BIN) create --name alderman_machine --file python_environment.txt --yes | tee ../output/conda_install_log.txt
	$(CONDA_BIN) activate alderman_machine

../output/R_environ.txt: set_R_environ.R | ../output
	$(R) $<

include ../../generic.make

