YEARS = 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022

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

PARAMS_2012 = -a 112,14,540,771 -c 290,523,623,711
PARAMS_2013 = -a 112,14,540,771 -c 290,523,623,711
PARAMS_2014 = -a 112,14,540,771 -c 290,523,623,711
PARAMS_2015 = -a 112,14,540,771 -c 290,523,623,711
PARAMS_2016 = -a 56,35,552,720 -c 247,606
PARAMS_2017 = -a 56,35,552,720 -c 258,616
PARAMS_2018 = -a 56,35,552,720 -c 247,606
PARAMS_2019 = -a 56,35,552,720 -c 247,606
PARAMS_2020 = -a 56,35,552,720 -c 247,606
PARAMS_2021 = -a 70,10,552,1900 -c 247,606
PARAMS_2022 = -a 56,30,552,720 -c 247,606

.PHONY: all clean

.PRECIOUS: ../output/%.csv ../input/%.csv ../input/%.pdf tabula.jar

all: ../output/menu.csv

clean:
	rm -f ../input/*.pdf ../input/*.csv ../output/*.csv

../output/menu.csv: $(foreach y, $(YEARS), ../output/$(y).csv) | ../output
	csvstack $^ > $@

../output/%.csv: ../input/%.csv | ../output
	cat $< | python process_budget.py $* > $@

../input/%.csv: ../input/%.pdf tabula.jar | ../input
	java -jar tabula.jar -p all -t $(PARAMS_$*) $< > $@

../input/%.pdf: | ../input
	wget -O $@ $(URL_$*)

tabula.jar:
	wget -O $@ https://github.com/tabulapdf/tabula-java/releases/download/v1.0.2/tabula-1.0.2-jar-with-dependencies.jar

include ../../generic.make