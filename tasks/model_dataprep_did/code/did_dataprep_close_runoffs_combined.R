library(tidyverse)
library(sf)
library(assertthat)
ARGS<- commandArgs(trailingOnly = TRUE)
menu_df <- read_rds("../input/ward_precinct_menu_panel_2012_2022.rds")
election_df <- read.csv("../input/incumbent_challenger_voteshare_df_precinct_level.csv")

#create a list of all wards that have a close runoff in year = ARGS[1]
#close is if voteshare is within ARGS[1] of 50%
#drop elections that do not have an inc=1 candidate
treatment_df <- election_df %>%
    filter(year == 2015 | year == 2019, type == "Runoff") %>%
    group_by(ward) %>%
    filter(sum(inc) > 0) %>%
    ungroup() %>%
    group_by(ward, year, inc) %>% #calculate the total ward-level voteshare for the canddidate where inc=1
    summarize(votecount_inc = sum(votecount*inc),
             votecount = sum(votecount)) %>%
    ungroup %>%
    group_by(ward, year) %>%
    summarize(voteshare = votecount_inc/sum(votecount)) %>%
    ungroup() %>%
    filter(voteshare > min(0.5 - as.numeric(ARGS[1]),0) & voteshare < min(0.5+as.numeric(ARGS[1]),1)) %>%
    filter(voteshare >0) %>%
    mutate(treatment = ifelse(voteshare >= 0.5, 0, 1)) %>%
    rename(year_treat = year)
#remove any ward that has a treatment in 2015 and 2019 from treatment_df
treatment_df <- treatment_df %>%
    group_by(ward) %>%
    filter(sum(treatment) < 2) %>%
    ungroup()
#assert ward_level_df is not empty
stopifnot(nrow(treatment_df) > 0)
ward_list <- treatment_df$ward
#filter election_df to only include wards in ward_list and inc =1 
precinct_level_df <- election_df %>%
    filter(ward %in% ward_list & year == 2015 | year == 2019, type == "Runoff") %>%
    mutate(votes_for_against_inc= ifelse(inc == 1, votecount, -votecount)) %>%
    group_by(ward, precinct) %>%
    summarize(net_inc_votes = sum(votes_for_against_inc)) %>%
    ungroup() 
#rank the precincts by net_inc_votes, break ties by first
precinct_level_df <- precinct_level_df %>%
    group_by(ward) %>%
    arrange(precinct, desc(net_inc_votes)) %>%
    mutate(rank = row_number()) %>%
    ungroup() 
#now group by ward and select only the top 5 precincts for each ward
top_precincts <- precinct_level_df %>%
    group_by(ward) %>%
    filter(rank <= as.numeric(ARGS[2])) %>%
    ungroup() %>%
    select(ward, precinct)
#now group by ward and select only the bottom 5 precincts for each ward
bottom_precincts <- precinct_level_df %>%
    group_by(ward) %>%
    filter(rank > (max(rank) - as.numeric(ARGS[2]))) %>%
    ungroup() %>%
    select(ward, precinct)
assert_that(nrow(top_precincts) == nrow(bottom_precincts))
#assert that there are more than args[2] precincts in each top and bottom list
assert_that(nrow(top_precincts) > as.numeric(ARGS[2]))
assert_that(nrow(bottom_precincts) > as.numeric(ARGS[2]))

#filter menu_df to only include wards in ward_list and year +/- 3 from ARGS[1]
menu_df <- menu_df %>%
  filter(ward_locate %in% ward_list & year >= 2012 & year <= 2022)
#rename ward_locate to ward and precinct_locate to precinct
menu_df <- menu_df %>%
  rename(ward = ward_locate, precinct = precinct_locate)

save(menu_df, top_precincts, bottom_precincts, treatment_df, file = "../output/close_runoffs_combined.rda")