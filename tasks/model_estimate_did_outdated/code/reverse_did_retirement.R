#John Ruf 06/22
#This code is meant to implement a reverse DiD on 

  library(tidyverse)
library(lmtest)
library(sandwich)
library(XML)
library("rstudioapi")


setwd(dirname(getActiveDocumentContext()$path)) 
menu_df<-read_csv("../input/menu_category_panel_df.csv")
treated_wards=c(2,7,11,15,17,18,24,29,31,35,36,41)
electorally_treated=c(7,10,15,18,29,31,35,36,41)
retire_2015=c(2,11,17,24,38)
retire_2019=c(20,22,25,39,47)

inverse_did_retirement_df<-menu_df %>%
  mutate(treated=case_when(ward %in% retire_2015 & year<2016~1,
                           ward %in% retire_2019 & year>2015 & year<2020~1,
                           TRUE~0),
         treated_1=case_when(ward %in% retire_2015 & year<2015~1,
                             ward %in% retire_2019 & year>2015 & year<2019~1,
                             TRUE~0),
         treated_2=case_when(ward %in% retire_2015 & year<2014~1,
                             ward %in% retire_2019 & year>2015 & year<2018~1,
                             TRUE~0),
         treated_3=case_when(ward %in% retire_2015 & year<2013~1,
                             ward %in% retire_2019 & year>2015 & year<2017~1,
                             TRUE~0)) %>%
  filter(year!=2020)

DiD_inverse<-lm(off_menu~treated+treated_1+treated_2+treated_3+factor(year)+factor(ward),data =inverse_did_retirement_df)
coeftest(DiD_inverse, vcov = vcovHC(DiD_inverse, type = "HC0"))