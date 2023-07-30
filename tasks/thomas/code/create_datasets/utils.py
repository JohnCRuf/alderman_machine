import pandas as pd
import regex as re
import nltk

elections = {
	2019: {
		'general_date': '26feb2019',
		'runoff_date':  '02apr2019',
        'term_date': '20may2019'
	},
	2015: {
		'general_date': '24feb2015',
		'runoff_date':  '07apr2015',
        'term_date': '18may2015'
	},
	2011: {
		'general_date': '22feb2011',
		'runoff_date':  '05apr2011',
        'term_date': '16may2011'
	},
	2007: {
		'general_date': '27feb2007',
		'runoff_date':  '17apr2007',
        'term_date': '21may2007'
	},
	2003: {
		'general_date': '25feb2003',
		'runoff_date':  '01apr2003',
        'term_date': '19may2003'
	}
}

for k in elections.keys():
    elections[k]['general_date'] = pd.to_datetime(elections[k]['general_date'])
    elections[k]['runoff_date']  = pd.to_datetime(elections[k]['runoff_date'])
    
    elections[k]['preperiod_begin'] = elections[k]['runoff_date'] - pd.Timedelta(182, "D") # 6 mo
    elections[k]['postperiod_end']  = elections[k]['runoff_date'] + pd.Timedelta(182, "D")
    
#     elections[k]['control_begin']   = elections[k]['preperiod_begin'] - pd.Timedelta(730, 'D') # 2 yrs
#     elections[k]['control_end']     = elections[k]['postperiod_end']  - pd.Timedelta(730, 'D')

def classify_date_yr(dt, elections):
    for yr in elections.keys():
        dates = elections[yr]
        
        if (dt >= dates['runoff_date']) and (dt < dates['postperiod_end']):
            return [yr, 'post']

        if (dt >= dates['preperiod_begin']) and (dt < dates['runoff_date']):
            return [yr, 'pre']
    
    return [0, '']

def classify_dates(df, datecol, elections):
    df = df[['id', datecol]].copy()
    df['res'] = df[datecol].apply(lambda x: classify_date_yr(x, elections))
    
    return pd.DataFrame(df['res'].to_list(), columns=['election_year', 'election_timing'], index=df['id'])
    

def fixcols(df):
    def _fc(cols):
        return(
            cols.str.lower()
            .str.replace('%', 'pct')
            .str.replace(r'[^\w\s]', '', regex=True)
            .str.strip()
            .str.replace(r'\s', '_', regex=True)
        )
    
    df = df.copy()
    df.columns = _fc(df.columns)
    return df

def fix_address(s1, s2):
    def _fa(a,b):
        if b == '':
            return a
        
        if a == '':
            return b
        
        if re.match(r"^\D", a):
            return b
        
        if nltk.distance.jaro_winkler_similarity(a,b) > 0.9:
            return b
        
        return ' '.join([a,b])
    
    return [_fa(a,b) for a,b in zip(s1,s2)]


def load_ward_shapefiles():
    import geopandas as gpd
    print('Loading ward shapes...')
    wards_pre2012 = gpd.read_file('../data/raw/Boundaries - Wards (2003-2015).geojson').change_type('ward', int, ignore_exception='fillna').to_crs(epsg=3857)
    wards_pre2012 = wards_pre2012[wards_pre2012.ward.notna()]

    wards_post2012 = gpd.read_file('../data/raw/Boundaries - Wards (2015-2023).geojson').change_type('ward', int, ignore_exception='fillna').to_crs(epsg=3857)
    wards_post2012 = wards_post2012[wards_post2012.ward.notna()]

    return {
        'pre': wards_pre2012,
        'post': wards_post2012
    }