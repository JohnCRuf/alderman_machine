#John Ruf 05/2022
#This code is intended to prepare the data for fitting the discrete choice BLP models and their
#diagnostics. 

library(tidyverse)
library(rvest)
library(stringr)
library(XML)
library("rstudioapi")


setwd(dirname(getActiveDocumentContext()$path)) 
menu_df<-read_csv("../input/menu_panel_df.csv")
inc_df<-read_csv("../input/incumbent_voteshare_df.csv")

inc_df<-inc_df %>%
  mutate(cycle=year) %>%
  filter(type!="General"|votepct>0.5, year!=2011)

menu_df<-menu_df %>%
  mutate(Ward=ward,
         ward=NULL) %>%
  filter(year==2014| year ==2018) %>%
  mutate(cycle=case_when(year==2014 ~ 2015,
                         year==2018 ~ 2019),
         year=NULL)

BLP_df<-left_join(inc_df, menu_df) %>%
  mutate(vs_paakes=log(votepct)-(log(1-votepct))) %>%
  filter(votepct!=1)

write_csv(BLP_df, file="../input/BLP_df.csv")