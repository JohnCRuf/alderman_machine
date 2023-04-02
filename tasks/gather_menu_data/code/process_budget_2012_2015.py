import requests
import pandas as pd
import sys 
import re
import warnings
warnings.filterwarnings("ignore") #ignore concatenation warnings
exec(open('reading_functions.py').read())

input_file = sys.argv[1]
output_file = sys.argv[2]

#load the 2011 text file as text
with open(input_file, "r") as f:
    text = f.read()

def menu_df_from_text(text):
    df = pd.DataFrame(columns=["ward", "type", "location", "desc", "blocks", "unitcount", "estcost"])
    ward, type, location, desc, blocks, unitcount, estcost = "", "", "", "", "", "", ""
    gatherflag = False
    text = re.sub(r"\$(\d+),(\d+)", r"$\1\2", text)

    for line in text.splitlines():
        if "Ward" in line:
            ward = line.replace(",", "").split(":")[-1].strip()
            gatherflag = False
        elif "Program" in line:
            type = line.replace(",", "").replace("Program ", "").replace(":", "").replace('"', "").strip()
            gatherflag = False
        elif "Est Cost" in line:
            gatherflag = True
        elif "Total" in line:
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
#write the dataframe to a csv
df.to_csv(output_file, index=False)
