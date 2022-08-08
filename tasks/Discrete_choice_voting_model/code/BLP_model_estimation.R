#John Ruf BLP Estimation

library(tidyverse)
library(rvest)
library(stargazer)
library(aod)
library(stringr)
library(XML)
library("rstudioapi")


setwd(dirname(getActiveDocumentContext()$path)) 
BLP_df<-read_csv("../input/BLP_df.csv") %>%
  mutate(off_menu=off_menu/100000,
         votepct=votepct*100,
         exp2=exp^2)

BLP_model<-lm(vs_paakes~off_menu+factor(Ward)+factor(year),data=BLP_df)
summary(BLP_model)
OLS<-lm(votepct~off_menu+factor(Ward)+factor(year),data=BLP_df)
summary(OLS)
EXP_OLS<-lm(votepct~exp+factor(Ward)+factor(year), data=BLP_df)
summary(EXP_OLS)
stargazer(BLP_model,OLS, EXP_OLS, omit = c("Ward","year"))
stargazer(OLS, EXP_OLS, omit = c("Ward","year"))