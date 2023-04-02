import requests
import pandas as pd
import sys 
import re
import warnings
warnings.filterwarnings("ignore")
exec(open('reading_functions.py').read())
input_file = sys.argv[1]
output_file = sys.argv[2]

#load the 2011 text file as text
with open(input_file, "r") as f:
    text = f.read()

def menu_df_from_text(text):
    df = pd.DataFrame(columns=["ward", "type", "location", "desc", "blocks", "unitcount", "estcost"])
    # set the variables to empty strings
    ward, type, location, desc, blocks, unitcount, estcost = [""] * 7
    gatherflag = False
    # Replace all commas between a $ and a number with nothing
    text = re.sub(r"\$(\d+),(\d+)", r"$\1\2", text)

    # for every line in the text
    for line in text.splitlines():
        # if the line contains the word "Ward"
        if "Ward:" in line:
            # set the ward variable to the last word in the line
            ward = line.split()[-1].replace(",", "")
            gatherflag = False
        # if the line contains the word "Est. Cost"
        elif "Est. Cost" in line:
            # set the gather flag to True
            gatherflag = True
            type = re.search(r"Program: (.+?),", line).group(1)
        elif "Total" in line:
            gatherflag = False
        if gatherflag and not "Program" in line:
            location, desc, blocks, unitcount, estcost = [""] * 5
            line_parts = [part.replace('"', "") for part in line.split(",")]
            location = location_street_filter(line_parts[0])
            location = location_parenthesis_filter(location)
            desc = line_parts[1]
            blocks = line_parts[2]
            unitcount = line_parts[3]
            estcost = line_parts[4].replace('"', "").replace("$", "")
            # filter out all "$" and """ from the estcost variable
            if estcost == "":
                for var in ["location", "desc", "blocks", "unitcount"]:
                    val = eval(var)
                    if val != "":
                        df[var].iloc[-1] = f"{df[var].iloc[-1]} {val}"
            else:
                df = df.append(
                    {
                        "ward": ward,
                        "type": type,
                        "location": location,
                        "desc": desc,
                        "blocks": blocks,
                        "unitcount": unitcount,
                        "estcost": estcost,
                    },
                    ignore_index=True,
                )
    return df

df = menu_df_from_text(text)
#write the dataframe to a csv
df.to_csv(output_file, index=False)
