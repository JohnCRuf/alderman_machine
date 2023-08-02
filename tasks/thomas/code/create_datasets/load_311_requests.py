import pandas as pd
import janitor

def service_reqs_to_parquet():
    df = pd.read_csv('../../data/raw/data.cityofchicago.org/311_Service_Requests.csv', usecols=[
        'SR_NUMBER',
        'SR_TYPE',
        'SR_SHORT_CODE',
        'CREATED_DATE',
        'CLOSED_DATE',
        'WARD'
    ]).clean_names()

    df['created_date'] = pd.to_datetime(df.created_date)
    df['closed_date']  = pd.to_datetime(df.closed_date)

    print(df.columns)
    
    df.to_parquet('../../data/temp/311.parquet', index=False)

def load_service_request_type(
        name,
        sr_short_code,
        historical_fname
):
    requests = pd.read_parquet('../../data/temp/311.parquet').query(f'sr_short_code == "{sr_short_code}"')

    old_requests = pd.read_csv(f'../../data/raw/data.cityofchicago.org/{historical_fname}')

    old_requests = old_requests.clean_names()

    old_requests.creation_date = pd.to_datetime(old_requests.creation_date)
    old_requests.completion_date = pd.to_datetime(old_requests.completion_date)

    old_requests.service_request_number = 'SR'+old_requests.service_request_number

    old_requests = old_requests.sort_values('creation_date').drop_duplicates('service_request_number')

    all_requests = pd.concat([requests, old_requests.rename({
        'creation_date': 'created_date',
        'completion_date': 'closed_date',
        'service_request_number': 'sr_number'
    }, axis=1)])

    all_requests = all_requests.sort_values('created_date').drop_duplicates('sr_number').reset_index(drop=True)
    all_requests['duration'] = all_requests.closed_date - all_requests.created_date 

    all_requests.to_parquet(f'../../data/out/{name}.parquet', index=False)

def load_potholes():
    load_service_request_type(
        'potholes',
        'PHF',
        '311_Service_Requests_-_Pot_Holes_Reported_-_Historical.csv'
    )

def load_rats():
    load_service_request_type(
        'rats',
        'SGA',
        '311_Service_Requests_-_Rodent_Baiting_-_Historical.csv'
    )
    
def load_graffiti():
    load_service_request_type(
        'graffiti',
        'GRAF',
        '311_Service_Requests_-_Graffiti_Removal_-_Historical.csv'
    )