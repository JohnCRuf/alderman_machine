link=links[1]

table_scraper<-function(){
  doc <- htmlParse(remDr$getPageSource()[[1]])
  table<-readHTMLTable(doc)[[2]]
  col_odd<-seq_len(ncol(table))%%2
  table2<-table[,col_odd==1]
  table2<-table2 %>%
    pivot_longer(!Precinct, names_to="Candidate", values_to="Votecount")
  table2<-table2 %>%
    mutate(candidate=str_trim(str_to_title(candidate),side="right"))
  return(table2)
}

chicago_elections_webscraper<-function(link) {
  remDr <- remoteDriver(port = 4445L)
  remDr$open()
  remDr$navigate(link)
  dropdown <- remDr$findElement(using = 'xpath','//*[@id="race"]') #identify dropdown menu
  dropdown_text<-dropdown$getElementText()[[1]] #get dropdown options
  dropdown_text_vector<-str_split(dropdown_text,'\n')[[1]]
  alderman_options=which(str_detect(dropdown_text_vector,"Alderman")==T)
  ward_list<-parse_number(dropdown_text_vector[alderman_options])
  data=data.frame(Precinct=integer(),Candidate=character(),Votecount=integer(),Ward=integer())
  for(i in length(ward_list)){
    xpath=paste0('//*[@id="race"]/option[',option[i],']')
    option<-remDr$findElement(using = 'xpath',xpath)
    option$clickElement()
    submit <-remDr$findElement(using= 'xpath', '//*[@id="page-wrap"]/div/div[4]/div[2]/form/table/tbody/tr[4]/td/input')
    submit$clickElement()
    data_table=table_scraper()
    data_table=data_table %>%
      mutate(Ward=ward_list[i])
    data<-rbind(data,data_table)
    remDr$navigate(link)
  }
remDr$close()
return(data)
}

