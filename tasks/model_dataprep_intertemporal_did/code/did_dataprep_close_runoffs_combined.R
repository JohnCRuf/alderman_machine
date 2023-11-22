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
    mutate(treatment = ifelse(voteshare <= 0.5, 0, 1)) %>%
    rename(year_treat = year)
#remove any ward that has a treatment in 2015 and 2019 from treatment_df
treatment_df <- treatment_df %>%
    group_by(ward) %>%
    filter(sum(treatment) < 2) %>%
    ungroup()
#create list of wards treated in 2015
treatment_2015 <- treatment_df %>%
    filter(year_treat == 2015, treatment == 1) %>%
    select(ward)
#create list of wards treated in 2019
treatment_2019 <- treatment_df %>%
    filter(year_treat == 2019, treatment == 1) %>%
    select(ward)
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
precinct_level_df <- precinct_level_df %>%
    group_by(ward) %>%
    mutate(percentile = rank(net_inc_votes)/n()) %>%
    ungroup() %>%
    mutate(percentile = percentile*100)

#filter menu_df to only include wards in ward_list and year +/- 3 from ARGS[1]
menu_df <- menu_df %>%
  filter(ward_locate %in% ward_list & year >= 2012 & year <= 2022)
#rename ward_locate to ward and precinct_locate to precinct
menu_df <- menu_df %>%
  rename(ward = ward_locate, precinct = precinct_locate)
menu_df <- menu_df %>%
  mutate(ward = as.numeric(ward),
         precinct = as.numeric(precinct))
#merge menu_df and precinct_level_df
menu_df <- menu_df %>%
  left_join(precinct_level_df, by = c("ward", "precinct"))
#

menu_df <- menu_df %>%
  mutate(treatment = ifelse(ward %in% unique(treatment_2015$ward) & year > 2015, 1, 0)) %>%
  mutate(treatment = ifelse(ward %in% unique(treatment_2019$ward) & year > 2019, 1, treatment))
#assert that at least one ward has treatment = 1
stopifnot(sum(menu_df$treatment) > 0)
#strip geometry from menu_df using sf
menu_df <- st_drop_geometry(menu_df)
#drop geometry column
menu_df <- menu_df %>%
  select(-geometry)
#create unique ward-precinct identifier
menu_df <- menu_df %>%
  mutate(ward_precinct_locate = paste0(ward, "_", precinct))
#group by ward and year and calculate total observed spending per year
ward_totals <- menu_df %>%
  group_by(ward, year) %>%
  summarize(total_spending = sum(weighted_cost)) %>%
  ungroup()
#merge ward_totals with menu_df to create a new column called total_spending
menu_df <- menu_df %>%
  left_join(ward_totals, by = c("ward", "year"))
#create fraction of ward-year spending variable called "spending_fraction"
menu_df <- menu_df %>%
  mutate(spending_fraction = weighted_cost/total_spending*100)
#write menu_df to csv
write_csv(menu_df, "../output/close_runoffs_combined_intertemporal.csv")