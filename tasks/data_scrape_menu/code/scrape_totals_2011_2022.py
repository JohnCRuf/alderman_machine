import requests
import pdfplumber
import pandas as pd
import sys
import warnings
warnings.filterwarnings("ignore") #ignore concatenation warnings
input_file = sys.argv[1]
output_file = sys.argv[2]
year = int(sys.argv[3])


with open(input_file, "r") as f:
    text = f.read()
    


#define page extraction function
#define page extraction function
def extract_menu_totals(text):
    ward = ""
    total = ""
    totalflag = False
    df = pd.DataFrame({"ward":[],"total":[]})
    for line in text.splitlines():
        total_phrases = ["Ward Committed Total","WARD COMMITTED",]
        bug_phrases = ["Total", ":", ":,,,"]
        if "Ward:" in line:
            ward = line.split()[-1]
            ward = "".join([char for char in ward if char.isnumeric()])
        if any(phrase in line for phrase in total_phrases) or totalflag == True:
            if totalflag == True:
                total = line.split()[-1]
                totalflag = False
                total = "".join([char for char in total if char.isnumeric()])
            else:
                total = line.split()[-1]
            if any(phrase in total for phrase in bug_phrases):
                totalflag = True
                total = ""
                total = "".join([char for char in total if char.isnumeric()])
        if ward != "" and total != "":
            #append to df
            df = df.append({"ward":ward,"total":total}, ignore_index=True)
            ward = ""
            total = ""
    return df


df = extract_menu_totals(text)
df["year"] = year
df.to_csv(output_file, index=False)
