library(tidyverse)
library(sf)
args <- commandArgs(trailingOnly = TRUE)
args <- c(5)
menu_df <- read_rds("../input/ward_precinct_menu_panel_2012_2022.rds")
election_df <- read.csv("../input/incumbent_challenger_voteshare_df_precinct_level.csv")

# ward list
treatment_list <- list(c(14, 2023), c(34, 2023), c(11, 2022), 
                       c(22, 2019), c(25, 2019), c(20, 2019), c(23, 2018))
#Ed Burke,  Carrie Austin,  Ricardo Munoz,  
#Danny Solis,  Proco Joe Moreno,  Willie Cochran,  Michael Zalewski
# Youngest was elected in 2010
control_list <- c(9, 37, 27, 44, 26, 30, 12, 3, 5, 8, 21)
#all alders elected before 2010 that won in 2019

# Gather the list of ARGS[1] precincts in 2015 in each ward of the treatment
# and control groups that had the  largest `total_votes_percandidate`
# when inc=1.

# Split the data
inc_1_df <- election_df %>%
    filter(inc == 1) %>%
    select(ward,  precinct,  year, type,  votecount_inc = votecount)
inc_0_df <- election_df %>%
    filter(inc == 0) %>%
    select(ward,  precinct,  year, type,  votecount_not_inc = votecount)

# Join and compute inc_net_vote
combined_df <- inc_1_df %>%
  left_join(inc_0_df,  by = c("ward",  "precinct",  "year", "type")) %>%
  mutate(inc_net_vote = votecount_inc - votecount_not_inc) %>%
  select(ward,  precinct,  year, type,  inc_net_vote)

# Get largest inc_net_vote for each ward,  precinct,  year combination
supporting_precinct_list <- combined_df %>%
  group_by(ward,  year, type) %>%
  arrange(desc(inc_net_vote)) %>%
  slice(1:args[1]) %>%
  filter(year == 2015,  
  ward %in% control_list | ward %in% treatment_list,
  type == "General")

opposing_precinct_list  <- combined_df %>%
  group_by(ward,  year, type) %>%
  arrange(inc_net_vote) %>%
  slice(1:args[1]) %>%
  filter(year == 2015,
   ward %in% control_list | ward %in% treatment_list,
   type == "General")

  #remove invalid numbers from both lists
supporting_precinct_list <- supporting_precinct_list %>%
    filter(!is.na(inc_net_vote))
opposing_precinct_list <- opposing_precinct_list %>%
    filter(!is.na(inc_net_vote))

#create a dataframe with just ward, precinct, and net_inc_votes from supporting_precinct_list
top_precincts <- supporting_precinct_list %>%
    select(ward, precinct, inc_net_vote)
bottom_precincts <- opposing_precinct_list %>% 
    select(ward, precinct, inc_net_vote)

#create a dataframe with the list of wards, treatment year (if applicable), and treatment status from control and treatment list
# Combine the treatment and control lists into one vector
treatment_wards <- sapply(treatment_list, `[`, 1)
all_wards <- c(treatment_wards, control_list)

# Create a dataframe with the ward and treatment columns
treatment_df2 <- data.frame(ward = all_wards)

# Add the treatment indicator (1 for treatment, 0 for control)
treatment_df2$treatment <- ifelse(treatment_df2$ward %in% treatment_wards, 1, 0)


# Add the year_treat variable (NA for control, corresponding year for treatment)
treatment_df2$year_treat <- ifelse(treatment_df2$treatment == 1, 
                             sapply(treatment_df2$ward, function(x) {
                               if (x %in% treatment_wards) {
                                 years <- sapply(treatment_list, function(y) y[2])
                                 years[which(sapply(treatment_list, function(y) y[1]) == x)]
                               } else {
                                 NA
                               }
                             }),
                             NA)
