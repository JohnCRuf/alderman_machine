#John Ruf 05/2022
#This code is intended to fit the DiD model and their
#diagnostics. 

library(tidyverse)
library(stringr)
library(did)
library(XML)
library(staggered)
source("did_fns.R")
menu_df<-read_csv("../input/menu_category_panel_df.csv")
close_runoff_df <- read_csv("../temp/close_runoff_wards.csv")
all_runoff_df <- read_csv("../temp/all_runoff_wards.csv")

posttreat_2011 <- c(2012,2013,2014)
posttreat_2015 <- c(2016,2017,2018)
posttreat_2019 <- c(2020,2021,2022)

close_runoff_wards_2011 <- select_wards(close_runoff_df,2011)
close_runoff_wards_2015 <- select_wards(close_runoff_df,2015)
close_runoff_wards_2019 <- select_wards(close_runoff_df,2019)

close_runoff_wards_treated_2011 <- select_treated_wards(close_runoff_df,2011)
close_runoff_wards_treated_2015 <- select_treated_wards(close_runoff_df,2015)
close_runoff_wards_treated_2019 <- select_treated_wards(close_runoff_df,2019)
#remove all wards listed in 2 or more close_runoff_wards_treated lists
close_runoff_treated_list <- did_remove_double_treat(close_runoff_wards_treated_2011, close_runoff_wards_treated_2015, close_runoff_wards_treated_2019)

close_runoff_2011_df <- apply_election_times(menu_df, posttreat_2011, close_runoff_wards_2011 , close_runoff_treated_list[1])
close_runoff_2015_df <- apply_election_times(menu_df, posttreat_2015, close_runoff_wards_2015, close_runoff_treated_list[2])
close_runoff_2019_df <- apply_election_times(menu_df, posttreat_2019, close_runoff_wards_2019, close_runoff_treated_list[3])
#append all dfs together
close_runoff_all_df <- rbind(close_runoff_2011_df,close_runoff_2015_df,close_runoff_2019_df) %>% 
    distinct() %>% 
    mutate(first_treat = case_when(ward %in% close_runoff_treated_list[1] ~ 2012,
                                   ward %in% close_runoff_treated_list[2] ~ 2016,
                                   ward %in% close_runoff_treated_list[3] ~ 2020,
                                   TRUE ~ 0))

did_all<-att_gt(yname="off_menu",tname="year",idname="ward", gname="first_treat", data=close_runoff_all_df,panel=F)
agg.simple <- aggte(did_all, type = "simple")
summary(agg.simple)
agg_dyn <- aggte(did_all, type = "dynamic")
ggdid(agg_dyn)


stargazer(DiD_all, omit = c("ward","year"))

stargazer(did_all)