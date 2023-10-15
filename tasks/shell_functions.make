FUNCTIONS = $(shell cat ../../shell_functions.sh)
STATA = @$(FUNCTIONS); stata_with_flag
JULIA = @$(FUNCTIONS); julia_pc_and_slurm
R = @$(FUNCTIONS); R_pc_and_slurm
PYTHON = @$(FUNCTIONS); python_pc_and_slurm
WIPECLEAN = @$(FUNCTIONS); clean_task

#If 'make -n' option is invoked
ifneq (,$(findstring n,$(MAKEFLAGS)))
STATA := STATA
JULIA := JULIA
R := R
PYTHON := PYTHON
WIPECLEAN := WIPECLEAN
endif

get_even_elements = $(foreach idx, $(shell seq 2 2 $(words $(1))), $(word $(idx),$(1)))
get_odd_elements = $(foreach idx, $(shell seq 1 2 $(words $(1))), $(word $(idx),$(1)))
