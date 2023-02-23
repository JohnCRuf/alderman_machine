table_scraper<-function(remDr,election,ward){
  Sys.sleep(2)
  doc <- htmlParse(remDr$getPageSource()[[1]])
  table<-readHTMLTable(doc)[[2]]
  col_odd<-seq_len(ncol(table))%%2
  table2<-table[,col_odd==1]
  table2<-table2 %>%
    pivot_longer(!Precinct, names_to="Candidate", values_to="Votecount")
  table2<-table2 %>%
    mutate(Candidate=str_trim(str_to_title(Candidate),side="right"),
           Election=election,
           Ward=ward) %>%
    filter(Precinct!="Total")
  return(table2)
}

chicago_elections_webscraper<-function(link) {
  election_el<-remDr$findElement(using='xpath','//*[@id="page-wrap"]/div/div[4]/div[2]/form/table/tbody/tr[1]/td/b')
  election<-election_el$getElementText()[[1]]
  dropdown <- remDr$findElement(using = 'xpath','//*[@id="race"]') #identify dropdown menu
  dropdown_text<-dropdown$getElementText()[[1]] #get dropdown options
  dropdown_text_vector<-str_split(dropdown_text,'\n')[[1]]
  dropdown_text_vector <- str_replace(dropdown_text_vector, "-", "")
  alderman_options=which(str_detect(dropdown_text_vector,"Alderman|ALDERMAN")==T)
  ward_list<-parse_number(dropdown_text_vector[alderman_options])
  data=data.frame(Precinct=integer(),Candidate=character(),Votecount=integer(),Election=character(),Ward=integer())
  for(i in 1:length(ward_list)){
    Sys.sleep(3)
    xpath=paste0('//*[@id="race"]/option[',alderman_options[i],']')
    option<-remDr$findElement(using = 'xpath',xpath)
    option$clickElement()
    submit <-remDr$findElement(using= 'xpath', '//*[@id="page-wrap"]/div/div[4]/div[2]/form/table/tbody/tr[4]/td/input')
    submit$clickElement()
    data_table=table_scraper(remDr,election,ward_list[i])
    data<-rbind(data_table,data)
    remDr$navigate(link)
  }
return(data)
}

