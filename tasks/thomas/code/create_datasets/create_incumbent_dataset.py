import pandas as pd
import janitor
import requests
from bs4 import BeautifulSoup
from time import sleep
from tqdm import tqdm
import regex as re

races = {
    '2023 Runoff': 242,
    '2023 General': 241,
    '2019 General': 210,
    '2019 Runoff': 220,
    '2015 General': 10,
    '2015 Runoff': 9,
    '2011 General': 25,
    '2011 Runoff': 24,
    '2007 General': 65,
    '2007 Runoff': 60,
    '2003 General': 110,
    '2003 Runoff': 105
}

raw_2007_list = '''
    Manuel Flores
    Madeline Haithcock
    Dorothy Tillman
    Toni Preckwinkle
    Leslie Hairston
    Freddrenna Lyle
    Darcel A. Beavers
    Michelle A. Harris
    Anthony Beale
    John Pope
    James Balcer
    George Cardenas
    Frank Olivo
    Ed Burke
    Theodore Thomas
    Shirley Coleman
    Latasha Thomas
    Lona Lane
    Virginia Rugai
    Arenda Troutman
    Howard Brookins Jr.
    Ricardo Muñoz
    Michael Zalewski
    Michael Chandler
    Daniel Solis
    Billy Ocasio
    Walter Burnett, Jr.
    Ed Smith
    Isaac Carothers
    Ariel Reboyras
    Ray Suarez
    Theodore Matlak
    Richard Mell
    Carrie Austin
    Rey Colón
    William Banks
    Emma Mitts
    Thomas Allen
    Margaret Laurino
    Patrick O'Connor
    Brian Doherty
    Burton Natarus
    Vi Daley
    Thomas M. Tunney
    Patrick Levar
    Helen Shiller
    Eugene Schulter
    Mary Ann Smith
    Joe Moore
    Bernard Stone
'''

elec_details_url = "https://chicagoelections.gov/en/election-results-specifics.asp"

headers = {
    'User-Agent': 'uchicago-research',
    'From': 'tmalthouse@uchicago.edu'  # This is another valid field
}

def get_race_type(x):
    x = x.lower().strip()
    
    if re.match(r"^mayor", x):
        return "citywide-mayoral"
    if re.match(r"^(clerk|treasurer|city clerk|city treasurer)", x):
        return "citywide-other"
    if re.match(r"^alderman", x):
        return "alderman"
    if re.match(r"^alderperson", x):
        return "alderman"
    if re.match(r"^(public policy|rent control|local option|cba ordinance|marijuana funds)", x):
        return "referendum"
    else:
        return "other"

def scrape_elections():
    dfs = []

    for elec_name, elec_num in races.items():
        print(elec_name)
        req = requests.get(f"https://chicagoelections.gov/en/election-results.asp?election={elec_num}", headers=headers)
        
        soup = BeautifulSoup(req.text)
        
        elecs = []
        
        for i in soup.find('table').find('select', id='race').find_all('option'):
            elecs.append([
                i['value'],
                i.text.strip()
            ])
        
        df = pd.DataFrame(elecs, columns=['race_num', 'race_name'])
        df['elec_name'] = elec_name
        df['elec_num'] = elec_num
        
        dfs.append(df)
        
        sleep(1)
    
    all_races = pd.concat(dfs, ignore_index=True).filter_on('race_num != ""').copy()

    all_races['elec_type'] = all_races.elec_name.str.lower().str.contains('general').replace({True: 'general', False: 'runoff'}).astype('category')

    all_races['race_type'] = all_races.race_name.apply(get_race_type).astype('category')

    all_races['elec_id'] = all_races.index

    all_races.to_parquet('../../data/out/all_races.parquet', index=False)

    d = {}

    dfs = []

    for n, row in tqdm(all_races.filter_on('race_type == "alderman"').reset_index(drop=True).iterrows()):
        d = {
            'election': f"{row.elec_num}",
            'race':     f"{row.race_num}",
            'ward':     "",
            'precinct': ""
        }
        
        req = requests.post(elec_details_url, d, headers = headers)

        tables = pd.read_html(req.text)
        tab1 = tables[1]
        tab1.columns = tab1.columns.droplevel()
        cols = tab1.columns
        t2 = (
            tab1[[c for c in cols if c != '%']]
            .melt(id_vars = ['Precinct', 'Votes'], var_name='candidate', value_name='votes')
            .rename({
                'Precinct': 'precinct',
                'Votes': 'total_votes'
            }, axis=1)
        )
        
        t2['race_num'] = row.race_num
        t2['race_name'] = row.race_name.strip()
        t2['elec_num'] = row.elec_num
        t2['elec_name'] = row.elec_name
        t2['elec_type'] = row.elec_type
        t2['elec_id'] = row.elec_id
        
        dfs.append(t2)
        
        sleep(1)
    
    alder_results = pd.concat(dfs, ignore_index=True)

    alder_results['ward'] = alder_results.race_name.str.extract(r'(\d+)').astype(int)
    alder_results['year'] = alder_results.elec_name.str.extract(r'(\d+)').astype(int)

    alder_results.to_parquet('../../data/out/alder_results.parquet')





def scrape_incumbency():
    urls = {
        2023: 'https://en.wikipedia.org/w/index.php?title=Chicago_City_Council&oldid=1136773645',
        2019: 'https://en.wikipedia.org/w/index.php?title=Chicago_City_Council&oldid=876898822',
        2015: 'https://en.wikipedia.org/w/index.php?title=Chicago_City_Council&oldid=643374263',
        2011: 'https://en.wikipedia.org/w/index.php?title=Chicago_City_Council&oldid=408814146',
        2007: 'https://en.wikipedia.org/w/index.php?title=Chicago_City_Council&oldid=99426466'
    }

    def wiki_good(yr):
        tables = pd.read_html(urls[yr])
        for t in tables:
            print(t)
            print('\n')
        
        if yr in [2023, 2019]:
            x = 1
        else:
            x = 0
        
        tab = tables[x]
        tab = tab.rename({'Ward': 'ward', 'Name': 'name', 'First elected': 'Took Office'}, axis=1)
        tab.columns = tab.columns.str.lower()
        
        tab['year_in'] = tab['took office'].str.extract(r"(\d+)").astype('int')
        tab['appointed'] = tab['took office'].str.contains("\*")
        tab['appointed'] = tab.appointed & (tab.year_in > (yr - 4))
        tab['year'] = yr
        
        return tab[['year', 'ward', 'name', 'appointed']]

    table_no = {
        2023: 1,
        2019: 1,
        2015: 0,
        2011: 0
    }

    def fetch_2023():
        return wiki_good(2023)
    
    def fetch_2019():
        return wiki_good(2019)
    
    def fetch_2015():
        return wiki_good(2015)
    
    def fetch_2011():
        return wiki_good(2011)
    
    def fetch_2007():
        print('Using text-block list of alders from')
        print('https://en.wikipedia.org/w/index.php?title=Chicago_City_Council&oldid=99426466')
        proc2007 = [
            [n, x.strip()]
            for n,x
            in
            enumerate(raw_2007_list.split('\n'))
            if x != ''
        ]

        df07 = pd.DataFrame(proc2007, columns=['ward', 'name'])
        df07['year'] = 2007
        df07['appointed'] = False
        
        return df07
    
    def fetch_2003():
        df = pd.read_excel('../../data/raw/2003_alders_OCR.xlsx')
        print('Using OCRed list of alders from')
        print('https://web.archive.org/web/20020904050152/http://www.cityofchicago.org/CityCouncil/wardmaps/WardMap.pdf')
        df['year'] = 2003
        df['appointed'] = False
        df = df.rename({'Ward': 'ward', 'Alderman': 'name'}, axis=1)
        return df
    
    df23 = fetch_2023()
    df19 = fetch_2019()
    df15 = fetch_2015()
    df11 = fetch_2011()
    df07 = fetch_2007()
    df03 = fetch_2003()

    incumbent_alders = pd.concat([
        df23,
        df19,
        df15,
        df11,
        df07,
        df03
    ])

    incumbent_alders['name'] = incumbent_alders['name'].str.title()

    incumbent_alders.to_parquet('../../data/out/incumbents.parquet', index=False)

def main():
    scrape_elections()

    scrape_incumbency()

if __name__ == '__main__':
    main()

    



