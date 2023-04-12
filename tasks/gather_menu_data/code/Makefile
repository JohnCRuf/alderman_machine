#DEFINITIONS:
YEARS_URL = $(shell seq 2012 2022)
YEARS_FOIA = $(shell seq 2005 2011)
inputs_URL = $(foreach y, $(YEARS_URL),  ../input/$(y).pdf)
inputs_FOIA = $(foreach y, $(YEARS_FOIA),  ../input/$(y).pdf)
TEMP_2005_2010 = $(foreach y, $(shell seq 2005 2010), ../temp/$(y).csv)
TEMP_2012_2015 = $(foreach y, $(shell seq 2012 2015), ../temp/$(y).csv)
TEMP_2016_2022 = $(foreach y, $(shell seq 2016 2017) $(shell seq 2019 2022), ../temp/$(y).csv)
TEMP_totals_2005_2010 = $(foreach y, $(shell seq 2005 2010), ../temp/$(y)_totals.csv)
TEMP_totals_2011_2022 = $(foreach y, $(shell seq 2011 2022), ../temp/$(y)_totals.csv)

URL_2012 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/March2017Update/2012Menu.pdf
URL_2013 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/March2017Update/2013Menu.pdf
URL_2014 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/March2017Update/2014Menu.pdf
URL_2015 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/March2017Update/2015Menu.pdf
URL_2016 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/2016MenuUpdatedMay2018.pdf
URL_2017 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/2017OBMMenu50WardDetailsRpt3Dec2018.pdf
URL_2018 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/2018%20Menu%20Ward%20details%20Report%20as%20of%2013May2019.pdf
URL_2019 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/2019MenuWardReport23June2020.pdf
URL_2020 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/2020%20Menu%20Ward%20Report%20as%20of%2027July2020.pdf
URL_2021 = https://www.chicago.gov/content/dam/city/depts/obm/general/CIP/CIPDocs/AldermanicMenuPostings/2021%20Menu%20Posting%20-%2022-10-02.pdf
URL_2022 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/2022%20Menu%20-%202-9-23.pdf

PARAMS_2011 = -a 112,14,540,771 -c 350,570,630,711
PARAMS_2012 = -a 112,14,540,771 -c 290,523,623,711
PARAMS_2013 = -a 112,14,540,771 -c 290,523,623,711
PARAMS_2014 = -a 112,14,540,771 -c 290,523,623,711
PARAMS_2015 = -a 112,14,540,771 -c 290,560,623,711
PARAMS_2016 = -a 56,35,552,720 -c 255,606
PARAMS_2017 = -a 56,35,552,720 -c 258,616
PARAMS_2018_1 = -a 56,35,552,720 -c 258,616
PARAMS_2018_2 = -a 56,35,552,720 -c 258,570
PARAMS_2018_3 = -a 56,35,552,720 -c 258,616
PARAMS_2019 = -a 56,35,552,720 -c 258,616
PARAMS_2020 = -a 56,35,552,720 -c 258,616
PARAMS_2021 = -a 80,10,590,1000 -c 268,696
PARAMS_2022 = -a 80,10,590,1000 -c 268,696

#Notes on parameters, -a indicate portion of page to analyze, -c indicate columns to extract
.PHONY: all clean

.PRECIOUS: ../output/%.csv ../input/%.csv ../input/%.pdf tabula.jar

all: ../output/menu_2005_2010.csv ../output/menu_2011_2015.csv  ../output/menu_2016_2022.csv ../output/menu_totals.csv


#OUTPUTS
../output/menu_2016_2022.csv: $(foreach y, $(shell seq 2016 2022), ../temp/$(y).csv) | ../output
	csvstack $^ > $@
../output/menu_2011_2015.csv: $(foreach y, $(shell seq 2011 2015), ../temp/$(y).csv) | ../output
	csvstack $^ > $@
../output/menu_2005_2010.csv: $(TEMP_2005_2010) | ../output
	csvstack $^ > $@
../output/menu_totals.csv: $(TEMP_totals_2005_2010) $(TEMP_totals_2011_2022) | ../output
	csvstack $^ > $@
#TEMP
$(TEMP_totals_2005_2010): ../temp/%_totals.csv: ../input/%.pdf | ../temp
	python scrape_totals_2005_2010.py $< $@ $*
$(TEMP_totals_2011_2022): ../temp/%_totals.csv: ../input/%.text | ../temp
	python scrape_totals_2011_2022.py $< $@ $*
$(TEMP_2016_2022): ../temp/%.csv: ../input/%.text process_budget_2016_2022.py reading_functions.py | ../temp
	python process_budget_2016_2022.py $< $@ $*

$(TEMP_2012_2015): ../temp/%.csv: ../input/%.text process_budget_2012_2015.py reading_functions.py | ../temp
	python process_budget_2012_2015.py $< $@ $*

../temp/2011.csv: ../input/2011.text process_budget_2011.py reading_functions.py | ../temp
	python process_budget_2011.py $< $@ 2011

../temp/2018.csv: ../input/2018_1.text ../input/2018_2.text ../input/2018_3.text process_budget_2016_2022.py reading_functions.py | ../temp
	python process_budget_2016_2022.py $< $@ 2018 

$(TEMP_2005_2010): ../temp/%.csv: ../input/%.pdf process_budget_2005_2010.py | ../temp
	python process_budget_2005_2010.py $< $@ $*

#INPUTS
../input/%.text: ../input/%.pdf tabula.jar | ../input
	java -jar tabula.jar -p all -t $(PARAMS_$*) $< > $@
#special 2018 inputs to fix inconsistent formatting on pages 146-149
../input/2018_1.pdf: ../input/2018.pdf | ../input
	pdftk $< cat 1-145 output $@
../input/2018_2.pdf: ../input/2018.pdf | ../input 
	pdftk $< cat 146-149 output $@
../input/2018_3.pdf: ../input/2018.pdf | ../input
	pdftk $< cat 150-151 output $@
$(inputs_URL): ../input/%.pdf: | ../input
	wget -O $@ $(URL_$*)
$(inputs_FOIA): ../input/%.pdf: | ../input
	cp ../../initialdata/output/$*.pdf $@

tabula.jar:
	wget -O $@ https://github.com/tabulapdf/tabula-java/releases/download/v1.0.2/tabula-1.0.2-jar-with-dependencies.jar

include ../../generic.make