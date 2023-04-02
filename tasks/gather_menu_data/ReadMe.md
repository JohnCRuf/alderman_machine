# Gather Menu Data
    This task scrapes the expenditure data from the Aldermanic Menu Program's website and FOIA'd PDFs and processes them into a set of CSVs.

## Output
* `menu_2005_2010.csv`: A CSV of menu expenditures by alderman for the years 2005-2010
* `menu_2011_2015.csv`: A CSV of menu expenditures by alderman for the years 2012-2015
* `menu_2016_2022.csv`: A CSV of menu expenditures by alderman for the years 2016-2022
## Input
* `year.pdf`: PDFs of the Aldermanic Menu Program's expenditure data for a given year
* `year.text`: Tabula-read text file of year.pdf 
## Code
* `process_budget_2005_2010.py`: Processes year.text for the years 2005-2010 using pdfplumber and pandas
* `process_budget_2011.py`: Processes year.text for the year 2011 using tabula-py and pandas
* `process_budget_2012_2015.py`: Processes year.text for the years 2011-2015 using tabula-py and pandas
* `process_budget_2016_2022.py`: Processes year.text for the years 2016-2018 using tabula-py pandas
* `process_budget.py`: Legacy script from the city bureau
* `reading_functions.py`: A set of filtering functions for processing the text files
* `tabular.jar`: A Java file for processing PDF tables. 

This code borrows heavily from the City Bureau's aldermanic menu money repo, available here:
https://github.com/City-Bureau/aldermanic-menu-money