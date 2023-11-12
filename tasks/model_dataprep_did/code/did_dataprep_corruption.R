library(tidyverse)
library(sf)
library(assertthat)
args <- commandArgs(trailingOnly = TRUE)
n_precincts <- as.numeric(args[1])
menu_df <- read_rds("../input/ward_precinct_menu_panel_2012_2022.rds")
support_df <- read.csv("../input/incumbent_contribution_supporting_opposing_precincts.csv")

# ward list
treatment_list <- list( c(22, 2019), c(25, 2019), c(20, 2019), c(23, 2018))
#Ed Burke,  Carrie Austin,  Ricardo Munoz,  
#Danny Solis,  Proco Joe Moreno,  Willie Cochran,  Michael Zalewski
# Youngest was elected in 2010
treatment_ward_list <- c(22, 25, 20)
control_ward_list <- c(9, 37, 27, 44, 26, 30, 12, 3, 5, 8, 21, 14, 34) #need 26 12 3 5 8

#assert that all wards in control list and treatment list are in `supporting_df`
assert_that(all(control_ward_list %in% support_df$ward))
assert_that(all(treatment_ward_list %in% support_df$ward))
assert_that(all(control_ward_list %in% menu_df$ward_locate))
assert_that(all(treatment_ward_list %in% menu_df$ward_locate))


# Get largest inc_net_vote for each ward,  precinct,  year combination
supporting_precinct_list <- support_df %>%
  group_by(ward,  map) %>%
  arrange(desc(rank)) %>%
  slice(1:n_precincts) %>%
  filter(map == "2012-2022",  
  ward %in% control_ward_list | ward %in% treatment_ward_list)

opposing_precinct_list  <- support_df %>%
  group_by(ward, map) %>%
  arrange(rank) %>%
  slice(1:n_precincts) %>%
  filter(map == "2012-2022",
  ward %in% control_ward_list | ward %in% treatment_ward_list)

#create a dataframe with just ward, precinct, and net_inc_votes from supporting_precinct_list
top_precincts <- supporting_precinct_list %>%
    select(ward, precinct_locate, total_contribution)
bottom_precincts <- opposing_precinct_list %>% 
    select(ward, precinct_locate, total_contribution)
#rename precinct_locate to precinct in both
top_precincts <- top_precincts %>%
  rename(precinct = precinct_locate)
bottom_precincts <- bottom_precincts %>%
  rename(precinct = precinct_locate)

# create a dataframe called treatment_df with ward, yeartreat, and treatment
# treatment is 1 if ward is in treatment_list,  0 otherwise
# year_treat is the year of changeover in treatment_listed
#TODO: figure out a way to to do this without hardcoding
treatment_df <- tibble(ward = c(treatment_ward_list, control_ward_list), 
                       year_treat = 2019,
                       treatment = c(rep(1, 3), rep(0, 13)))

#filter menu_df to only include wards in ward_list and years greater than 2012
menu_df <- menu_df %>%
  filter(ward_locate %in% c(treatment_ward_list, control_ward_list) & year >= 2012)
menu_df <- menu_df %>%
  rename(ward = ward_locate, precinct = precinct_locate)

save(menu_df, top_precincts, bottom_precincts, treatment_df, file = paste0("../output/corruption_", args[1] ,"_precincts.rda"))