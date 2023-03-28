import requests
import pdfplumber
import pandas as pd
import sys 
input_file = sys.argv[1]
output_file = sys.argv[2]
print("something")
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
    #set all variables to empty strings
    [ward, location, type, CG_blks, SW_blks, blocks, humps, unitcount, estcost] = [""]*9
    for line in text.splitlines():
        if "Ward" in line:
            ward = line.split()[-1]
        if "EstCost" in line:
            gatherflag = True
            typeflag = True
        if "Printed" in line:
            gatherflag = False
        elif not any(char.isdigit() for char in line):
            gather = False   
        #if typeflag is true, then extract the text of the line into variable type
        if typeflag:
            type = line
            table_heading = line
            #remove the strings " CG_Blks" " SW Blks" from the type variable
            quantity_strings= [" CG_Blks", " SW Blks", " Humps", " Blocks", " UnitCount", " EstCost"]
            for string in quantity_strings:
                type = type.replace(string, "")

            typeflag = False
        #if gatherflag is true and line doesn't contain type, then extract the last number of the line into a variable estcost
        elif gatherflag and not type in line:
            #assert all variables are empty strings
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
                #if SW_blks contains a letter or a parenthesis
                if any(char.isalpha() for char in SW_blks)  or any(char == '(' for char in SW_blks):
                        #if SW_blks contains a letter, then it was blank
                        #if SW_blks >, then it was blank but accidentally read as a number
                    SW_blks = 'NA'
                if any(char.isalpha() for char in CG_blks) or any(char == '(' for char in CG_blks):
                    CG_blks = 'NA'
                humps = 'NA'
                blocks = 'NA'
                unitcount = 'NA'
            elif "Humps" in table_heading and "Blocks" in table_heading:
                #grab second to last string in line
                try: 
                    humps = line.split()[-3]
                except IndexError:
                    humps = 'NA'
                try:
                    blocks = line.split()[-2]
                except IndexError:
                    blocks = 'NA'
                #if humps contains a letter
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
            #set location equal to the line replacing all the variables with empty strings
            location = line
            #if location contains '0.04'
            variable_list = [CG_blks, SW_blks, humps, blocks, unitcount, estcost]
            for var in variable_list:
                location = location.replace(' '+var, '')
                
            #append the variables to the dataframe
            df = df.append({"ward": ward, "type": type, "location": location, "cg_blks": CG_blks, "sw_blks": SW_blks, "humps": humps, "blocks": blocks, "unitcount": unitcount, "estcost": estcost}, ignore_index=True)
            #reset all variables to empty strings
            [location, CG_blks, SW_blks, humps, blocks, unitcount, estcost] = [""]*7
    #return the dataframe
    return df

#for every page in page list, extract the menu data and save df into list
df_list = []
i = 0
for page in page_list:
    i += 1
    print('current page is: ', i)
    text = page.extract_text()
    df = extract_menu_data(text)
    df_list.append(df)
#concatenate all the dataframes in the list
df = pd.concat(df_list)
#write the dataframe to a csv
df.to_csv(output_file, index=False)
