import requests
import pdfplumber
import pandas as pd
import sys
import warnings
warnings.filterwarnings("ignore") #ignore concatenation warnings
input_file = sys.argv[1]
output_file = sys.argv[2]
year = int(sys.argv[3])
with pdfplumber.open(input_file) as pdf:
    page_list = pdf.pages
    page = page_list[0]
    text = page.extract_text()
    


#define page extraction function
def extract_menu_totals(text):
    ward = ""
    total = ""
    df = pd.DataFrame({"ward":[],"total":[]})
    for line in text.splitlines():
        total_phrases = ["Ward Committed Total","WARD COMMITTED","MENU BUDGET"]
        if "Ward:" in line:
            ward = line.split()[-1]
        if any(phrase in line for phrase in total_phrases):
            total = line.split()[-1]
        if ward != "" and total != "":
            df = pd.DataFrame({"ward":[ward],"total":[total]})
            ward = ""
            total = ""
    return df

df_list = []

for page in page_list:
    text = page.extract_text()
    df = extract_menu_totals(text)
    df_list.append(df)

df = pd.concat(df_list)
df["year"] = year
df.to_csv(output_file, index=False)
