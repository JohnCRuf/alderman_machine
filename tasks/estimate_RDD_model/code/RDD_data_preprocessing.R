#John Ruf 05/2022
#This code is intended to prepare the data for fitting the RDD models and their
#diagnostics. 

library(tidyverse)
library(rvest)
library(stringr)
library(XML)
library("rstudioapi") 
setwd(dirname(getActiveDocumentContext()$path)) 
menu_df<-read_csv("../input/menu_panel_df.csv")
beauty_df<-read_csv("../input/menu_panel_df_beauty.csv")
inc_df<-read_csv("../input/incumbent_voteshare_df.csv")

inc_df<-inc_df %>%
  mutate(cycle=year) %>%
  filter(type!="General"|votepct>0.5)

menu_df<-menu_df %>%
  mutate(Ward=ward,
         ward=NULL) %>%
  filter(year==2012| year==2016| year ==2020) %>%
  mutate(cycle=case_when(year==2012 ~ 2011,
                         year==2016 ~ 2015,
                         year==2020 ~ 2019),
         year=NULL)

RDD_df<-left_join(inc_df, menu_df)
RDD_df_beauty<-left_join(inc_df, beauty_df)

write_csv(RDD_df, file="../input/RDD_df.csv")
write_csv(RDD_df_beauty, file="../input/RDD_df_beauty.csv")
