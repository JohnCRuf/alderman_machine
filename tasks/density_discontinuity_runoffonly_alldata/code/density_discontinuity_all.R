#This code is intended to prepare the data for fitting the RDD models and their

library(tidyverse)
library(stringr)
library(ggplot2)
library(rdrobust)
library(stargazer)
library(rdd)
library(XML)
source("../input/RDD_functions.R")
inc_df<-read_csv("../input/incumbent_voteshare_df.csv")

inc_df<-inc_df %>%
  mutate(cycle=year,
  IW=ifelse(votepct>0.5,1,0),
  IVP=(votepct-0.5)*100) %>%
  filter(type=="Runoff")

myDCdensity(inc_df$IVP, 0, "../output/total_incumbent_density_discontinuity.png")