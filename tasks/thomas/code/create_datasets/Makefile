SHELL=bash

all: dirs ../../data/out/alder_results_incumbency.parquet ../../data/out/contracts_geocoded.geojson services

../../data/out/alder_results.parquet: ../../data/raw/2003_alders_OCR.xlsx ../../data/raw/election_dates.csv
	python -c 'import create_incumbent_dataset; create_incumbent_dataset.scrape_elections()'

../../data/out/incumbents.parquet:
	python -c 'import create_incumbent_dataset; create_incumbent_dataset.scrape_incumbency()'

../../data/out/alder_results_incumbency.parquet: ../../data/out/alder_results.parquet ../../data/out/incumbents.parquet
	python match_incumbent_alders.py

../../data/temp/contracts.parquet: ../../data/raw/data.cityofchicago.org/Contracts.csv
	python -c 'import geocode_contracts; geocode_contracts.contracts_to_parquet()'

# This routine geocodes addresses---a costly operation we don't want to unnecessarily repeat.
# Uncomment the Python routine to get get it done
../../data/out/vendor_addresses.geojson: ../../data/temp/contracts.parquet mapbox_key
#	python -c 'import geocode_contracts; geocode_contracts.geocode_contract_addresses()'

../../data/out/contracts_geocoded.geojson: ../../data/temp/contracts.parquet ../../data/out/vendor_addresses.geojson
	python -c 'import geocode_contracts; geocode_contracts.geocode_contracts()'

services: ../../data/out/potholes.parquet ../../data/out/rats.parquet ../../data/out/graffiti.parquet

../../data/temp/311.parquet: ../../data/raw/data.cityofchicago.org/311_Service_Requests.csv
	python -c 'import load_311_requests; load_311_requests.service_reqs_to_parquet()'

../../data/out/potholes.parquet: ../../data/temp/311.parquet ../../data/raw/data.cityofchicago.org/311_Service_Requests_-_Pot_Holes_Reported_-_Historical.csv
	python -c 'import load_311_requests; load_311_requests.load_potholes()'

../../data/out/rats.parquet: ../../data/temp/311.parquet ../../data/raw/data.cityofchicago.org/311_Service_Requests_-_Rodent_Baiting_-_Historical.csv
	python -c 'import load_311_requests; load_311_requests.load_rats()'

../../data/out/graffiti.parquet: ../../data/temp/311.parquet ../../data/raw/data.cityofchicago.org/311_Service_Requests_-_Graffiti_Removal_-_Historical.csv
	python -c 'import load_311_requests; load_311_requests.load_graffiti()'

# Check that Mapbox key exists
mapbox_key:
	(ls ~/.keys/mapbox_be.key && echo OK) || exit -1

# Create data directories
dirs:
	mkdir -p ../../data
	mkdir -p ../../data/out
	mkdir -p ../../data/temp
	mkdir -p ../../data/raw
	mkdir -p ../../data/raw/data.cityofchicago.org

../../data/raw/data.cityofchicago.org/Contracts.csv:
	wget https://data.cityofchicago.org/api/views/rsxa-ify5/rows.csv -P ../../data/raw/data.cityofchicago.org/Contracts.csv

../../data/raw/data.cityofchicago.org/311_Service_Requests.csv:
	wget https://data.cityofchicago.org/api/views/v6vf-nfxy/rows.csv -P ../../data/raw/data.cityofchicago.org/311_Service_Requests.csv

../../data/raw/data.cityofchicago.org/311_Service_Requests_-_Graffiti_Removal_-_Historical.csv:
	wget https://data.cityofchicago.org/api/views/hec5-y4x5/rows.csv -P ../../data/raw/data.cityofchicago.org/311_Service_Requests_-_Graffiti_Removal_-_Historical.csv

../../data/raw/data.cityofchicago.org/311_Service_Requests_-_Pot_Holes_Reported_-_Historical.csv:
	wget https://data.cityofchicago.org/api/views/7as2-ds3y/rows.csv -P ../../data/raw/data.cityofchicago.org/311_Service_Requests_-_Pot_Holes_Reported_-_Historical.csv

../../data/raw/data.cityofchicago.org/311_Service_Requests_-_Rodent_Baiting_-_Historical.csv:
	wget https://data.cityofchicago.org/api/views/97t6-zrhs/rows.csv -P ../../data/raw/data.cityofchicago.org/311_Service_Requests_-_Rodent_Baiting_-_Historical.csv

../../data/raw/data.cityofchicago.org/ward_boundaries_2015_2023.geojson:
	wget https://data.cityofchicago.org/api/geospatial/sp34-6z76?method=export&format=GeoJSON -P ../../data/raw/data.cityofchicago.org/ward_boundaries_2015_2023.geojson

../../data/raw/data.cityofchicago.org/org/ward_boundaries_2003_2015.geojson:
	wget https://data.cityofchicago.org/api/geospatial/xt4z-bnwh?method=export&format=GeoJSON -P ../../data/raw/data.cityofchicago.orgward_boundaries_2003_2015.geojson

../../data/raw/2003_alders_OCR.xlsx:
	cp ../../handmade_data/2003_alders_OCR.xlsx ../../data/raw/2003_alders_OCR.xlsx

../../data/raw/election_dates.csv:
	cp ../../handmade_data/election_dates.csv ../../data/raw/election_dates.csv