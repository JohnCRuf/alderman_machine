SHELL=bash
include ../../shell_functions.make

python_packages = requests pdfplumber pandas numpy 
all: ../output/R_packages.txt ../output/python_packages.txt ../output/R_environ.txt
.PHONEY: R_environ

../output/R_packages.txt: packages.R | ../output
	$(R) $<
#for each package in python_packages, run pipx install package --include-deps
../output/python_packages.txt: packages.py | ../output
	for package in $(python_packages); do \
		pipx install $$package --include-deps; \
	done
../output/R_environ.txt: set_R_environ.R | ../output
	$(R) $<

include ../../generic.make

