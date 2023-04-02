#DEFINITIONS:
YEARS_URL = $(shell seq 2012 2022)
YEARS_FOIA = $(shell seq 2005 2011)
inputs_URL = $(foreach y, $(YEARS_URL),  ../input/$(y).pdf)
inputs_FOIA = $(foreach y, $(YEARS_FOIA),  ../input/$(y).pdf)
TEMP_2005_2010 = $(foreach y, $(shell seq 2005 2010), ../temp/$(y).csv)
TEMP_2012_2015 = $(foreach y, $(shell seq 2012 2015), ../temp/$(y).csv)
TEMP_2016_2022 = $(foreach y, $(shell seq 2016 2022), ../temp/$(y).csv)

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
URL_2022 = https://www.chicago.gov/content/dam/city/depts/obm/supp_info/CIP_Archive/Aldermanic%20Menu/2020%20Menu%20Ward%20Report%20as%20of%2027July2020.pdf

PARAMS_2011 = -a 112,14,540,771 -c 350,570,630,711
PARAMS_2012 = -a 112,14,540,771 -c 290,523,623,711
PARAMS_2013 = -a 112,14,540,771 -c 290,523,623,711
PARAMS_2014 = -a 112,14,540,771 -c 290,523,623,711
PARAMS_2015 = -a 112,14,540,771 -c 290,560,623,711
PARAMS_2016 = -a 56,35,552,720 -c 255,606
PARAMS_2017 = -a 56,35,552,720 -c 258,616
PARAMS_2018 = -a 56,35,552,720 -c 258,616
PARAMS_2019 = -a 56,35,552,720 -c 258,616
PARAMS_2020 = -a 56,35,552,720 -c 258,616
PARAMS_2021 = -a 80,10,590,1000 -c 268,696
PARAMS_2021 = -a 80,10,590,1000 -c 268,696

#Notes on parameters, -a indicate portion of page to analyze, -c indicate columns to extract
.PHONY: all clean

.PRECIOUS: ../output/%.csv ../input/%.csv ../input/%.pdf tabula.jar

all: ../output/menu_2005_2010.csv ../output/menu_2011_2015.csv  ../output/menu_2016_2022.csv

clean:
	rm -f ../input/*.pdf ../input/*.text ../output/*.csv ../temp/*.csv 

#OUTPUTS
../output/menu_2016_2022.csv: $(foreach y, $(shell seq 2016 2022), ../temp/$(y).csv) | ../output
	csvstack $^ > $@
../output/menu_2011_2015.csv: $(foreach y, $(shell seq 2011 2015), ../temp/$(y).csv) | ../output
	csvstack $^ > $@
../output/menu_2005_2010.csv: $(TEMP_2005_2010) | ../output
	csvstack $^ > $@
#TEMP
$(TEMP_2016_2022): ../temp/%.csv: ../input/%.text process_budget_2016_2022.py reading_functions.py | ../temp
	python process_budget_2016_2022.py $< $@ $*

$(TEMP_2012_2015): ../temp/%.csv: ../input/%.text process_budget_2012_2015.py reading_functions.py | ../temp
	python process_budget_2012_2015.py $< $@ $*

../temp/2011.csv: ../input/2011.text process_budget_2011.py reading_functions.py | ../temp
	python process_budget_2011.py $< $@ 2011

$(TEMP_2005_2010): ../temp/%.csv: ../input/%.pdf process_budget_2005_2010.py | ../temp
	python process_budget_2005_2010.py $< $@ $*

#INPUTS
../input/%.text: ../input/%.pdf tabula.jar | ../input
	java -jar tabula.jar -p all -t $(PARAMS_$*) $< > $@
$(inputs_URL): ../input/%.pdf: | ../input
	wget -O $@ $(URL_$*)
$(inputs_FOIA): ../input/%.pdf: | ../input
	cp ../../initialdata/output/$*.pdf $@

tabula.jar:
	wget -O $@ https://github.com/tabulapdf/tabula-java/releases/download/v1.0.2/tabula-1.0.2-jar-with-dependencies.jar

include ../../generic.make