#John Ruf Jun 5/2022
#This code is meant to scrape aldermanic election datafrom the chicago elections board website
#This code relies on a function script that processes data from scraped links

library(RSelenium)
library(tidyverse)
library(rvest)
library(stringr)
library(XML)
source("chicago_elections_webscraping_fn.R")
#step 1: Construct links to scrape
#this is a list of website link stubs to scrape
link_stub_list_list<-c('105','110','220','9','10','24','25','60','65','3','210')

i=1
links=matrix(0,1,length(link_stub_list_list))
for (val in link_stub_list_list) {
  links[i]=paste('https://chicagoelections.gov/en/election-results.asp?election=',val, sep="")
  i=i+1
  }
#initialize empty dataframe
elections_data<- data.frame(matrix(ncol = 5, nrow = 0))

#initialize docker
system("docker stop $(docker ps -q)")
system("docker pull selenium/standalone-chrome",wait=T)
Sys.sleep(2)
system("docker run -d -p 4445:4444 --shm-size 4g selenium/standalone-chrome:4.2.2",wait=T)
Sys.sleep(2)

#step 2: Execute webscraper for every link
remDr <- remoteDriver(port = 4445L,
                                 browserName = "chrome")
Sys.sleep(2)
remDr$open()
for (link in links){
  Sys.sleep(2)
  remDr$navigate(link)
  print(link)
  df_temp=chicago_elections_webscraper(link)
  elections_data<-rbind(elections_data,df_temp)
}

#step 3: Clean raw dataset
elections_data_clean<-elections_data %>%
  mutate(
    type=str_extract(Election, "Runoff|General|Special"),
    year=str_extract(Election, "[0-9][0-9][0-9][0-9]"),
    date=str_extract(Election,"[0-99]/[0-99]/[0-99][0-99]|[0-99]/[0-99][0-99]/[0-99][0-99]|[0-99][0-99]/[0-99][0-99]/[0-99][0-99]"),
    election=NULL
  )
write.csv(elections_data_clean,"../output/elections.csv", row.names = FALSE)