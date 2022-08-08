#John Ruf BLP Estimation with beauty outcome variable

library(tidyverse)
library(rvest)
library(stargazer)
library(stringr)
library(XML)
library("rstudioapi")


setwd(dirname(getActiveDocumentContext()$path)) 
BLP_df<-read_csv("../input/BLP_df_beauty.csv") %>%
  mutate(beauty=beauty/100000,
         votepct=votepct*100) %>%
  filter(votepct!=100)

BLP_model<-lm(vs_paakes~beauty+factor(Ward)+factor(year),data=BLP_df)
summary(BLP_model)
OLS<-lm(votepct~beauty+factor(Ward)+factor(year),data=BLP_df)
summary(OLS)
EXP_OLS<-lm(votepct~beauty+exp+factor(Ward)+factor(year), data=BLP_df)
summary(EXP_OLS)
stargazer(BLP_model,OLS, EXP_OLS, omit = c("Ward","year"))