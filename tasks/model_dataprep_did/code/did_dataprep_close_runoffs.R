library(tidyverse)
library(sf)
ARGS<- commandArgs(trailingOnly = TRUE)
menu_df <- read_rds("../input/ward_precinct_menu_panel_2012_2022.rds")
election_df <- read.csv("../input/incumbent_challenger_voteshare_df_precinct_level.csv")

#create a list of all wards that have a close runoff in year = ARGS[1]
#close is if voteshare is within ARGS[2] of 50%
treatment_df <- election_df %>%
    filter(year == as.numeric(ARGS[1]), type == "Runoff") %>%
    group_by(ward, year, inc) %>% #calculate the total ward-level voteshare for the canddidate where inc=1
    summarize(votecount_inc = sum(votecount*inc),
             votecount = sum(votecount)) %>%
    ungroup %>%
    group_by(ward, year) %>%
    summarize(voteshare = votecount_inc/sum(votecount)) %>%
    ungroup() %>%
    filter(voteshare >= 0.5 - as.numeric(ARGS[2]) & voteshare <= 0.5 + as.numeric(ARGS[2])) %>%
    mutate(treatment = ifelse(voteshare >= 0.5, 0, 1)) 
#assert ward_level_df is not empty
stopifnot(nrow(treatment_df) > 0)
ward_list <- treatment_df$ward
#filter election_df to only include wards in ward_list and inc =1 
precinct_level_df <- election_df %>%
    filter(ward %in% ward_list & year == as.numeric(ARGS[1]), type == "Runoff") %>%
    mutate(votes_for_against_inc= ifelse(inc == 1, votecount, -votecount)) %>%
    group_by(ward, precinct) %>%
    summarize(net_inc_votes = sum(votes_for_against_inc)) %>%
    ungroup() 
#find the top ARGS[3] precincts by ward
top_precincts <- precinct_level_df %>%
    group_by(ward) %>%
    slice_max(order_by = net_inc_votes, n = as.numeric(ARGS[3])) %>%
    ungroup() %>%
    select(ward, precinct)

#filter menu_df to only include wards in ward_list and year +/- 3 from ARGS[1]
menu_df <- menu_df %>%
  filter(ward_locate %in% ward_list & year >= as.numeric(ARGS[1]) - 3 & year <= as.numeric(ARGS[1]) + 3)

save(menu_df, top_precincts, treatment_df, file = paste0("../output/close_runoffs_year_", ARGS[1], "_cutoff_", ARGS[2],"_count_",ARGS[3],".rda"))