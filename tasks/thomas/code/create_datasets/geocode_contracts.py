import geopandas as gpd
import pandas as pd
import janitor
import geopy
from shapely.geometry import Point

from pathlib import Path

import regex as re
import numpy as np
import matplotlib.pyplot as plt
import nltk
from tqdm import tqdm

from utils import fixcols, classify_dates, fix_address

def contracts_to_parquet():
    fixcols(
        pd.read_csv('../../data/raw/data.cityofchicago.org/Contracts.csv')
    ).to_parquet('../../data/temp/contracts.parquet', index=False)

def geocode_contract_addresses():
    contracts = pd.read_parquet('../../data/temp/contracts.parquet')

    contracts['date'] = pd.to_datetime(contracts.approval_date)

    addresses = contracts[['address_1', 'address_2', 'city', 'state', 'zip']].drop_duplicates()
    addresses.address_1 = addresses.address_1.fillna('')
    addresses.address_2 = addresses.address_2.fillna('')
    addresses.city = addresses.city.fillna('CHICAGO')
    addresses.state = addresses.state.fillna("IL")
    addresses.zip = addresses.zip.fillna('')

    addresses['address'] = fix_address(addresses.address_1, addresses.address_2)

    with open(Path.home() / '.keys/mapbox_be.key', 'r') as infile:
        mapkey = infile.read().strip()

        # print(mapkey)

    locations = []

    with geopy.geocoders.MapBox(api_key = mapkey) as geocoder:
        for _, row in tqdm(addresses.iterrows()):
            locations.append(
                geocoder.geocode(
                    query = f'{row.address}, {row.city}, {row.state}, {row.zip}',
                    country='US',
                    exactly_one=True
                )
            )
    
    addresses_formerge = contracts[['address_1', 'address_2', 'city', 'state', 'zip']].drop_duplicates()

    addresses_formerge['geometry'] = locations

    addresses_formerge['point'] = addresses_formerge.geometry.apply(lambda x: str(x.point) if x is not None else None)

    xy = addresses_formerge.geometry.apply(lambda x: Point(x.longitude, x.latitude) if x is not None else None)

    addresses_gpd = gpd.GeoDataFrame(addresses_formerge, geometry=xy)

    addresses_gpd.to_file('../../data/out/vendor_addresses.geojson', driver='GeoJSON')

def geocode_contracts():
    addresses_gpd = gpd.read_file('../../data/out/vendor_addresses.geojson')
    contracts = pd.read_parquet('../../data/temp/contracts.parquet')

    print(addresses_gpd.columns)
    print(contracts.columns)

    contracts_gpd = addresses_gpd.merge(
        contracts,
        on=['address_1', 'address_2', 'city', 'state', 'zip'],
        how='right'
    )

    contracts_gpd.to_file('../../data/out/contracts_geocoded.geojson', driver='GeoJSON')

if __name__ == '__main__':
    contracts_to_parquet()
    geocode_contract_addresses()
    geocode_contracts()