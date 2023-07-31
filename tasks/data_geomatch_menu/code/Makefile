SHELL=bash
include ../../shell_functions.make

## DEFINITIONS
OUTPUTS = $(addprefix ../output/geomatched_, $(foreach geo, shapes lines points, 3_ands_df_$(geo).csv 2_ands_df_$(geo).csv \
and_dash_df_$(geo).csv mult_ands_df_$(geo).csv \
from_to_df_$(geo).csv normal_address_df_$(geo).csv double_dash_to_df_$(geo).csv \
intersection_df_$(geo).csv school_park_df_$(geo).csv leftover_df_$(geo).csv through_address_df_$(geo).csv))

INPUTS_csv = $(addprefix ../input/geocoded_, 3_ands_df.csv 2_ands_df.csv \
from_to_df.csv normal_address_df.csv double_dash_to_df.csv \
intersection_df.csv school_park_df.csv leftover_df.csv through_address_df.csv)
INPUTS_maps = $(addprefix ../input/, ward_precincts_2003_2011.zip \
ward_precincts_2012_2022.zip)
TEMP_maps_2003 = $(addprefix ../temp/ward_precincts_2003_2011/, \
$(foreach filestub, .shp .shx .sbn .sbx .dbf .prj, ward_precincts_2003_2011$(filestub)))
TEMP_maps_2012 = $(addprefix ../temp/ward_precincts_2012_2022/, \
$(foreach filestub, .shp .shx .dbf .prj, ward_precincts_2012_2022$(filestub)))
TEMP_maps = $(TEMP_maps_2003) $(TEMP_maps_2012)
all: $(OUTPUTS)
.INTERMEDIATE: $(TEMP_maps) ../temp/ward_precincts_2003_2011 ../temp/ward_precincts_2012_2022

#OUTPUT RECIPES
.SECONDEXPANSION:
../output/geomatched_%_df_shapes.csv ../output/geomatched_%_df_lines.csv ../output/geomatched_%_df_points.csv: geomatch_%.R $$(shell grep -o '../input/[A-Za-z_0-9]*\.[a-z]*' geomatch_$$*.R) $$(shell grep -o 'geomatch_[A-Za-z_0-9]*\.R' geomatch_$$*.R) $(TEMP_maps)  | ../output run.sbatch slurmlogs 
	$(R) --no-job-name $<

#TEMP RECIPES
$(TEMP_maps_2003): ../temp/ward_precincts_2003_2011/ward_precincts_2003_2011%: ../temp/ward_precincts_2003_2011
	mv ../temp/ward_precincts_2003_2011/WardPrecincts$* $@
$(TEMP_maps_2012): ../temp/ward_precincts_2012_2022/ward_precincts_2012_2022%: ../temp/ward_precincts_2012_2022
	mv ../temp/ward_precincts_2012_2022/geo_export_90b54a76-f42d-472d-bde6-5ca1377ae02a$* $@

../temp/ward_precincts_%: ../input/ward_precincts_%.zip | ../temp
	unzip -d ../temp/ward_precincts_$* $<


#INPUT RECIPES
$(INPUTS_csv): ../input/%.csv: ../../data_geocode_menu/output/%.csv | ../input
	ln -s $< $@

$(INPUTS_maps): ../input/%.zip: ../../initialdata/output/%.zip | ../input
	ln -s $< $@
include ../../generic.make