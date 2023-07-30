SHELL=bash

all: ../../data/out/alder_results_incumbency.parquet ../../data/out/contracts_geocoded.geojson services

../../data/out/alder_results.parquet:
	python -c 'import create_incumbent_dataset; create_incumbent_dataset.scrape_elections()'

../../data/out/incumbents.parquet:
	python -c 'import create_incumbent_dataset; create_incumbent_dataset.scrape_incumbency()'

../../data/out/alder_results_incumbency.parquet: ../../data/out/alder_results.parquet ../../data/out/incumbents.parquet
	python match_incumbent_alders.py

../../data/temp/contracts.parquet:
	python -c 'import geocode_contracts; geocode_contracts.contracts_to_parquet()'

../../data/out/vendor_addresses.geojson: ../../data/temp/contracts.parquet
	python -c 'import geocode_contracts; geocode_contracts.geocode_contract_addresses()'

../../data/out/contracts_geocoded.geojson: ../../data/temp/contracts.parquet ../../data/out/vendor_addresses.geojson
	python -c 'import geocode_contracts; geocode_contracts.geocode_contracts()'

services: ../../data/out/potholes.parquet ../../data/out/rats.parquet ../../data/out/graffiti.parquet

../../data/temp/311.parquet:
	python -c 'import load_311_requests; load_311_requests.service_reqs_to_parquet()'

../../data/out/potholes.parquet: ../../data/temp/311.parquet
	python -c 'import load_311_requests; load_311_requests.load_potholes()'

../../data/out/rats.parquet: ../../data/temp/311.parquet
	python -c 'import load_311_requests; load_311_requests.load_rats()'

../../data/out/graffiti.parquet: ../../data/temp/311.parquet
	python -c 'import load_311_requests; load_311_requests.load_graffiti()'