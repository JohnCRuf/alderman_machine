SHELL=bash
include ../../shell_functions.make

## DEFINITIONS

all: ../output/ward_precincts_2012_2022.zip ../output/ward_precincts_2003_2011.zip ../output/pot_holes_reported_2009_2018.csv ../output/pot_holes_reported_2009_2018.csv ../output/service_requests_2018_present.csv

#OUTPUT RECIPES

#shape file recipes
../output/ward_precincts_2012_2022.zip:
	wget "https://data.cityofchicago.org/api/geospatial/uvpq-qeeq?method=export&format=Shapefile" -O ../output/ward_precincts_2012_2022.zip
../output/ward_precincts_2003_2011.zip:
	wget "https://data.cityofchicago.org/download/sgsc-bb4n/application%2Fzip" -O ../output/ward_precincts_2003_2011.zip
../output/pot_holes_reported_2009_2018.csv:
	wget "https://data.cityofchicago.org/api/views/7as2-ds3y/rows.csv?accessType=DOWNLOAD" -O ../output/pot_holes_reported_2009_2018.csv
../output/service_requests_2018_present.csv:
	wget "https://data.cityofchicago.org/api/views/v6vf-nfxy/rows.csv?accessType=DOWNLOAD" -O ../output/service_requests_2018_present.csv

include ../../generic.make