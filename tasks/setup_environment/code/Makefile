SHELL=bash
include ../../shell_functions.make

all: ../output/R_packages.txt ../output/python_install_log.txt ../output/R_environ.txt

../output/R_packages.txt: packages.R | ../output
	$(R) $<

../output/python_install_log.txt: python_environment.txt | ../output
	rm -rf ../../../.venv
	python -m venv ../../../.venv
	source ../../../.venv/bin/activate
	python -m pip install -r python_environment.txt


../output/R_environ.txt: set_R_environ.R | ../output
	$(R) $<

include ../../generic.make

