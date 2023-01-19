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

list<-c('220','210','9','10','24','25','60','65','3')

i=1
links=matrix(0,1,8)
for (val in list)
{links[i]=paste('https://chicagoelections.gov/en/election-results.asp?election=',val, sep="")
i=i+1}
elections_data<- data.frame(matrix(ncol = 5, nrow = 0))
system("docker stop $(docker ps -q)")
system("docker pull selenium/standalone-chrome",wait=T)
Sys.sleep(2)
system("docker run -d -p 4445:4444 selenium/standalone-chrome",wait=T)
Sys.sleep(2)
#step 2: Execute webscraper for every link
remDr <- remoteDriver(port = 4445L,
                                 browserName = "chrome")
Sys.sleep(2)
remDr$open()
for (link in links){
  remDr$navigate(link)
  print(link)
  df_temp=chicago_elections_webscraper(link)
  elections_data<-rbind(elections_data,df_temp)
}

#step 3: Clean raw dataset
elections_data2<-elections_data %>%
  mutate(
    type=str_extract(Election, "Runoff|General|Special"),
    year=str_extract(Election, "[0-9][0-9][0-9][0-9]"),
    date=str_extract(Election,"[0-99]/[0-99]/[0-99][0-99]|[0-99]/[0-99][0-99]/[0-99][0-99]|[0-99][0-99]/[0-99][0-99]/[0-99][0-99]"),
    election=NULL
  )
write.csv(elections_data2,"../output/elections.csv", row.names = FALSE)