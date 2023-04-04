import requests
import pdfplumber
import pandas as pd
import sys
import warnings
warnings.filterwarnings("ignore") #ignore concatenation warnings
input_file = sys.argv[1]
output_file = sys.argv[2]
year = sys.argv[3]
# Get the PDF
with pdfplumber.open(input_file) as pdf:
    page_list = pdf.pages
    page = page_list[0]
    text = page.extract_text()
    


#define page extraction function
def extract_menu_data(text):
    df = pd.DataFrame(columns=["ward", "type", "location", "cg_blks", "sw_blks", "humps","blocks", "unitcount", "estcost"])
    gatherflag = False
    typeflag = False
    [ward, location, type, CG_blks, SW_blks, blocks, humps, unitcount, estcost] = [""]*9
    #remove all quotation marks
    text = text.replace('"', '')
    for line in text.splitlines():
        if "Ward" in line:
            ward = line.split()[-1]
        if "EstCost" in line:
            gatherflag = True
            typeflag = True
        if "Printed" in line or "Total" in line:
            gatherflag = False
        if typeflag:
            type = line
            table_heading = line
            quantity_strings= [" CG_Blks", " SW Blks", " Humps", " Blocks", " UnitCount", " EstCost"]
            for string in quantity_strings:
                type = type.replace(string, "")

            typeflag = False
        elif gatherflag and not type in line:
            variable_list = [CG_blks, SW_blks, humps, blocks, unitcount, estcost]
            assert all(var == "" for var in variable_list)
            assert location == ""
            estcost = line.split()[-1]
            if "CG_Blks" in table_heading and "SW Blks" in table_heading:
                try :
                    CG_blks = line.split()[-3]
                except IndexError:
                    CG_blks = 'NA'
                try:
                    SW_blks = line.split()[-2]
                except IndexError:
                    SW_blks = 'NA'
                #if SW_blks or CG_blks contain a letter or a parenthesis then it should be NA
                if any(char.isalpha() for char in SW_blks)  or any(char == '(' for char in SW_blks):
                    SW_blks = 'NA'
                if any(char.isalpha() for char in CG_blks) or any(char == '(' for char in CG_blks):
                    CG_blks = 'NA'
                humps = 'NA'
                blocks = 'NA'
                unitcount = 'NA'
            elif "Humps" in table_heading and "Blocks" in table_heading:
                try: 
                    humps = line.split()[-3]
                except IndexError:
                    humps = 'NA'
                try:
                    blocks = line.split()[-2]
                except IndexError:
                    blocks = 'NA'
                if any(char.isalpha() for char in humps) or any(char == '(' for char in humps):
                    humps = 'NA'
                if any(char.isalpha() for char in blocks) or any(char == '(' for char in blocks):
                    blocks = 'NA'
                unitcount = 'NA'
                CG_blks = 'NA'
                SW_blks = 'NA'
            elif "Humps" in table_heading:
                try:
                    humps = line.split()[-2]
                except IndexError:
                    humps = 'NA'
                if any(char.isalpha() for char in blocks) or any(char == '(' for char in blocks):
                    blocks = 'NA'
                unitcount = 'NA'
                CG_blks = 'NA'
                SW_blks = 'NA'
                blocks = 'NA'
            elif "Blocks" in table_heading:
                try:
                    blocks = line.split()[-2]
                except IndexError:
                    blocks = 'NA'
                if any(char.isalpha() for char in blocks) or any(char == '(' for char in blocks):
                    blocks = 'NA'
                unitcount = 'NA'
                CG_blks = 'NA'
                SW_blks = 'NA'
                humps = 'NA'
            elif "UnitCount" in table_heading:
                try:
                    unitcount = line.split()[-2]
                except IndexError:
                    unitcount = 'NA'
                if any(char.isalpha() for char in unitcount) or any(char == '(' for char in unitcount):
                    unitcount = 'NA'
                CG_blks = 'NA'
                SW_blks = 'NA'
                humps = 'NA'
                blocks = 'NA'
            location = line
            #estcost but remove "
            estcost = estcost.replace('"', '')
            variable_list = [CG_blks, SW_blks, humps, blocks, unitcount, estcost]
            for var in variable_list:
                location = location.replace(' '+var, '')
            df = df.append({"ward": ward, 
            "type": type,
            "location": location,
            "cg_blks": CG_blks,
            "sw_blks": SW_blks,
            "humps": humps,
            "blocks": blocks,
            "unitcount": unitcount,
            "estcost": estcost}, ignore_index=True)
            [location, CG_blks, SW_blks, humps, blocks, unitcount, estcost] = [""]*7
    return df

df_list = []
for page in page_list:
    text = page.extract_text()
    df = extract_menu_data(text)
    df_list.append(df)
df = pd.concat(df_list)
df["year"] = year
df.to_csv(output_file, index=False)
