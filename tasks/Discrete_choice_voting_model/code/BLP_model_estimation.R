#John Ruf BLP Estimation

library(tidyverse)
library(rvest)
library(stargazer)
library(stringr)
library(XML)
library("rstudioapi")


setwd(dirname(getActiveDocumentContext()$path)) 
BLP_df<-read_csv("../input/BLP_df.csv") %>%
  mutate(off_menu=off_menu/100000)

BLP_model<-lm(vs_paakes~off_menu+factor(Ward)+factor(year),data=BLP_df)
summary(BLP_model)

stargazer(BLP_model, omit = c("Ward","year"))