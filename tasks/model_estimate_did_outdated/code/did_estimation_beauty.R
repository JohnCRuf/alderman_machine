#John Ruf 05/2022
#This code is intended to fit the DiD model and their
#diagnostics. 

library(tidyverse)
library(stringr)
library(did)
library(XML)
library("rstudioapi")


setwd(dirname(getActiveDocumentContext()$path)) 
menu_df<-read_csv("../input/menu_category_panel_df_beauty.csv")
treated_wards=c(2,7,11,15,17,18,24,29,31,35,36,41)
electorally_treated=c(7,10,18,29,31,35,36,41)
retirement_treated=c(2,11,17,24,38)
redistrcted_treated=c(15)

DiD_all_df<-menu_df %>%
  mutate(treated=ifelse(ward %in% treated_wards & year>2015,1,0),
         treated_1=ifelse(ward %in% treated_wards & year>2016,1,0),
         treated_2=ifelse(ward %in% treated_wards & year>2017,1,0),
         treated_3=ifelse(ward %in% treated_wards & year>2018,1,0),
         treated_4=ifelse(ward %in% treated_wards & year>2019,1,0),
         first_treat=ifelse(ward %in% treated_wards,2016,0))

DiD_elected_df<-menu_df %>%
  mutate(treated=ifelse(ward %in% electorally_treated & year>2015,1,0),
         treated_1=ifelse(ward %in% electorally_treated & year>2016,1,0),
         treated_2=ifelse(ward %in% electorally_treated & year>2017,1,0),
         treated_3=ifelse(ward %in% electorally_treated & year>2018,1,0),
         treated_4=ifelse(ward %in% electorally_treated & year>2019,1,0)) %>%
  filter(ward %in% retirement_treated==F)


DiD_retired_df<-menu_df %>%
  mutate(treated=ifelse(ward %in% retirement_treated & year>2015,1,0),
         treated_1=ifelse(ward %in% retirement_treated & year>2016,1,0),
         treated_2=ifelse(ward %in% retirement_treated & year>2017,1,0),
         treated_3=ifelse(ward %in% retirement_treated & year>2018,1,0),
         treated_4=ifelse(ward %in% retirement_treated & year>2019,1,0),)%>%
  filter(ward %in% electorally_treated==F)

DiD_all<-lm(beauty~treated+treated_1+treated_2+treated_3+treated_4+factor(year)+factor(ward),data = DiD_all_df)
summary(DiD_all)
DiD_elected<-lm(beauty~treated+treated_1+treated_2+treated_3+treated_4+factor(year)+(ward),data = DiD_elected_df)
summary(DiD_elected)
DiD_retired<-lm(beauty~treated+treated_1+treated_2+treated_3+treated_4+factor(year)+factor(ward),data = DiD_retired_df)
summary(DiD_retired)

stargazer(DiD_all,DiD_elected,DiD_retired, omit = c("ward","year"))

did_attgt<-att_gt(yname="beauty",tname="year",idname="ward", gname="first_treat", data=DiD_all_df,panel=F)
ggdid(did_all)

stargazer(DiD_all)