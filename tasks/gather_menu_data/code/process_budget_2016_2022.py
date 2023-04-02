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
    df = pd.DataFrame(columns=["ward", "type", "location", "estcost"])
    ward, type, location, estcost = "", "", "", ""
    saver_flag = False
    text = re.sub(r"\$(\d+),(\d+)", r"$\1\2", text)
    text = text.replace(", ", "; ") #changing ", " to "; " to avoid splitting on commas in addresses
    text = text.replace("&,", "&") #removing commas after ampersands

    for line in text.splitlines():
        if "Ward:" in line:
            ward = line.replace(",", "").split(":")[-1].strip()
        elif not "Cost" in line and not "MENU BUDGET" in line and not "WARD COMMITTED" in line and not "BALANCE" in line:
            location, estcost = "", ""
            line_parts = [part.replace('"', "").strip() for part in line.split(",")]
            type = line_parts[0].replace('"', "").strip()
            #remove (#) from type
            type = re.sub(r"\(\d+\)", "", type).strip()
            location = location_parenthesis_filter(location_street_filter(location_ampersand_filter(line_parts[1])))
            location = re.sub(r"\s+", " ", location).strip()
            estcost = line_parts[-1].replace('"', "").replace("$", "").strip()
            if estcost == "" or type == "":
                #if estcost or type is blank, then next line is continuation of this line
                saver_flag = True
                saved_location = location
                saved_type = type
                saved_estcost = estcost
            elif saver_flag == True:
                #continuations only happen on the next line, so if saver_flag is true, then this is the next line
                location = f"{saved_location} {location}"
                type = f"{saved_type} {type}"
                estcost = f"{saved_estcost} {estcost}"
                location = location_parenthesis_filter(location_street_filter(location_ampersand_filter(location)))
                saver_flag = False
            if estcost != "" and saver_flag == False:
                df = df.append({
                    "ward": ward,
                    "type": type,
                    "location": location,
                    "estcost": estcost
                }, ignore_index=True)
    return df
df = menu_df_from_text(text)
#add year column always equal to year
df["year"] = year
#write the dataframe to a csv
df.to_csv(output_file, index=False)
