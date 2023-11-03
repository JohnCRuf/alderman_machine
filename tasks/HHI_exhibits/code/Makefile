SHELL=bash
include ../../shell_functions.make

## DEFINITIONS


all: ../output/hhi_annual_cycle_2003_2011.png ../output/hhi_annual_cycle_2012_2022.png

#OUTPUT RECIPES
../output/hhi_annual_cycle_2003_2011.png: hhi_time_series_2003_2011.R ../input/menu_annual_hhi_2003_2011.csv | ../output run.sbatch slurmlogs
	$(R) $<
../output/hhi_annual_cycle_2012_2022.png: hhi_time_series_2012_2022.R ../input/menu_annual_hhi_2012_2022.csv | ../output run.sbatch slurmlogs
	$(R) $<

#INPUT RECIPES
../input/menu_annual_hhi_%.csv: ../../hhi_prepare_data/output/menu_annual_hhi_%.csv | ../input
	ln -s $< $@

include ../../generic.make