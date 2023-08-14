SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUTS_shapes_lines_points = $(addprefix ../output/geomatched_, $(foreach geo, shapes lines points, $(foreach years, 2003_2011 2012_2022,  quad_$(years)_$(geo).csv pent_$(years)_$(geo).csv)))
OUTPUTS_lines_points = $(addprefix ../output/geomatched_, $(foreach geo, lines points, $(foreach years, 2003_2011 2012_2022, line_$(years)_$(geo).csv)))
OUTPUTS_points = $(addprefix ../output/geomatched_, $(foreach years , 2003_2011 2012_2022, \
  point_$(years)_points.csv))
OUTPUTS =  $(OUTPUTS_lines_points) $(OUTPUTS_points) $(OUTPUTS_shapes_lines_points)

INPUTS_csv = $(addprefix ../input/geocoded_, 3_ands_df.csv 2_ands_df.csv mult_ands_df.csv \
from_to_df.csv normal_address_df.csv and_dash_df.csv leftover_df_dash.csv double_dash_to_df.csv \
intersection_df.csv school_park_df.csv leftover_df.csv through_address_df.csv)
INPUTS_maps = $(addprefix ../input/, ward_precincts_2003_2011.zip \
ward_precincts_2012_2022.zip)

all: $(OUTPUTS)
points: $(OUTPUTS_points)
lines_points: $(OUTPUTS_lines_points)
shapes_lines_points: $(OUTPUTS_shapes_lines_points)

#OUTPUT RECIPES
.SECONDEXPANSION:
../output/geomatched_%_2003_2011_points.csv ../output/geomatched_%_2003_2011_lines.csv ../output/geomatched_%_2003_2011_shapes.csv: geomatch_%.R $$(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geomatch_$$*.R) $$(shell grep -o 'geomatch_[A-Za-z_0-9]*\.R' geomatch_$$*.R)  ../temp/ward_precincts_2003_2011 | ../output run.sbatch slurmlogs
	$(R) --no-job-name $< ../temp/ward_precincts_2003_2011/ward_precincts_2003_2011.shp ../output/geomatched_$*_2003_2011_points.csv ../output/geomatched_$*_2003_2011_lines.csv ../output/geomatched_$*_2003_2011_shapes.csv

.SECONDEXPANSION:
../output/geomatched_%_2012_2022_points.csv ../output/geomatched_%_2012_2022_lines.csv ../output/geomatched_%_2012_2022_shapes.csv: geomatch_%.R $$(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geomatch_$$*.R) $$(shell grep -o 'geomatch_[A-Za-z_0-9]*\.R' geomatch_$$*.R)  ../temp/ward_precincts_2012_2022 | ../output run.sbatch slurmlogs
	$(R) --no-job-name $< ../temp/ward_precincts_2012_2022/ward_precincts_2012_2022.shp ../output/geomatched_$*_2012_2022_points.csv ../output/geomatched_$*_2012_2022_lines.csv ../output/geomatched_$*_2012_2022_shapes.csv
#TEMP RECIPES
../temp/ward_precincts_%: ../input/ward_precincts_%.zip | ../temp
	unzip -o -d ../temp/ward_precincts_$* $<
	for file in ../temp/ward_precincts_$*/* ; do \
		mv $$file ../temp/ward_precincts_$*/ward_precincts_$*.`basename $$file | sed 's/.*\.//'`; \
	done
#INPUT RECIPES
../input/geocoded_%.csv: ../../data_geocode_menu/output/geocoded_%.csv | ../input
	ln -s $< $@
$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@
include ../../generic.make