SHELL=bash
include ../../shell_functions.make

all: ../output/R_packages.txt ../output/conda_install_log.txt ../output/R_environ.txt

../output/R_packages.txt: packages.R | ../output
	$(R) $<

../output/conda_install_log.txt: python_environment.txt | ../output
	conda config --add channels conda-forge
	conda create --name alderman_machine --file python_environment.txt --yes | tee ../output/conda_install_log.txt 

../output/R_environ.txt: set_R_environ.R | ../output
	$(R) $<

include ../../generic.make

