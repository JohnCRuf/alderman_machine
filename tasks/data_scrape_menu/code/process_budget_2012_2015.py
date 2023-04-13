import requests
import pandas as pd
import sys 
import re
import warnings
warnings.filterwarnings("ignore") #ignore concatenation warnings
exec(open('reading_functions.py').read())

input_file = sys.argv[1]
output_file = sys.argv[2]
year = sys.argv[3]
#load the 2011 text file as text
with open(input_file, "r") as f:
    text = f.read()

def menu_df_from_text(text):
    df = pd.DataFrame(columns=["ward", "type", "location", "desc", "blocks", "unitcount", "estcost"])
    ward, type, location, desc, blocks, unitcount, estcost = "", "", "", "", "", "", ""
    gatherflag = False
    text = re.sub(r"\$(\d+),(\d+)", r"$\1\2", text)
    # Replace all commas between quotes and text or numbers 
    text = re.sub(r'(")(\d+),(\d+)(")', r"\1\2\3", text)
    total_phrases = ["Program Total", "Menu Budget:", "Ward Committed Total:", "Ward Balance:", "Total:"]
    ward_phrases = ["Ward  :", "Ward:", "Ward :"]
    for line in text.splitlines():
        if any(phrase in line for phrase in ward_phrases):
            ward = line.replace(",", "").split(":")[-1].strip()
            gatherflag = False
        elif "Program" in line:
            type = line.replace(",", "").replace("Program ", "").replace(":", "").replace('"', "").strip()
            gatherflag = False
        elif "Est Cost" in line:
            gatherflag = True
        elif any(phrase in line for phrase in total_phrases):
            gatherflag = False
        if gatherflag and "Est Cost" not in line and '""",' not in line:
            location, desc, blocks, unitcount, estcost = "", "", "", "", ""
            line_parts = [part.replace('"', "").strip() for part in line.split(",")]
            location = location_parenthesis_filter(location_street_filter(line_parts[0]))
            desc = line_parts[1]
            blocks = line_parts[-3]
            unitcount = line_parts[-2]
            estcost = line_parts[-1].replace('"', "").replace("$", "").strip()
            if estcost == "":
                for var in ["location", "desc", "blocks", "unitcount"]:
                    val = eval(var)
                    if val != "":
                        df[var].iloc[-1] = f"{df[var].iloc[-1]} {val}"
            else:
                #remove commas from the estcost variable
                #if unitcount has a dollar sign
                if "$" in unitcount:
                    #remove last phrase from unitcount and add to estcost
                    estcost = f"{unitcount.split()[-1]} {estcost}"
                    unitcount = " ".join(unitcount.split()[:-1])
                df = df.append({
                    "ward": ward,
                    "type": type,
                    "location": location,
                    "desc": desc,
                    "blocks": blocks,
                    "unitcount": unitcount,
                    "estcost": estcost
                }, ignore_index=True)
    return df
df = menu_df_from_text(text)
#add year column always equal to year
df["year"] = year
#write the dataframe to a csv
df.to_csv(output_file, index=False)
