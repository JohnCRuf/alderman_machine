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
    not_gathering = ["Ward:", "Cost", "MENU BUDGET", "WARD COMMITTED", "BALANCE", "MenuPackage", " Projects as of"]
    for line in text.splitlines():
        if "Ward:" in line:
            ward = line.replace(",", "").split(":")[-1].strip()
        #if nothing in not_gathering is in the line
        elif not any(phrase in line for phrase in not_gathering):
            location, estcost = "", ""
            line_parts = [part.replace('"', "").strip() for part in line.split(",")]
            type = line_parts[0].replace('"', "").strip()
            location = line_parts[1]
            estcost = line_parts[-1].replace('"', "").replace("$", "").strip()
            if estcost == "" or type == "":
                #if estcost or type is blank, then next line is continuation of this line
                saver_flag = True
                saved_location = location
                saved_type = type
                saved_estcost = estcost
                #remove all alphabetical characters from estcost
                saved_estcost = re.sub(r"[a-zA-Z]", "", saved_estcost)
            elif saver_flag == True:
                #continuations only happen on the next line, so if saver_flag is true, then this is the next line
                location = f"{saved_location} {location}"
                type = f"{saved_type} {type}"
                estcost = f"{saved_estcost} {estcost}"
                location = location_parenthesis_filter(location_street_filter(location_ampersand_filter(location)))
                location = re.sub(r"\s+", " ", location).strip()
                saver_flag = False
            if estcost != "" and saver_flag == False:
                #if estcost contains the character "&", then take the last part of the string separated by "&"
                if "&" in estcost:
                    estcost = estcost.split("&")[-1]
                #filter all variables before entering into dataframe
                estcost = re.sub(r"[a-zA-Z:&]", "", estcost) #remove all alphabetical characters and "&" ":" from estcost
                type = re.sub(r"\(\d+\)", "", type).strip() #remove all (#) from type
                location = location_parenthesis_filter(location_street_filter(location_ampersand_filter(location))) #fix all reading mistakes
                location = re.sub(r"\s+", " ", location).strip() #remove all double spaces first time
                location = re.sub(r"\s+", " ", location).strip() #remove all double spaces second time, in case there were triple spaces
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
