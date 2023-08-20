library(tidyverse)
library(stringr)
library(did)
library(XML)
source("did_fns.R")
menu_df <- read_csv("../input/menu_category_panel_df.csv")
inc_voteshare_df <- read.csv("../input/incumbent_voteshare_df.csv")

#extract wards whose type is runoff and whose votepct were in the range 45 to 55
close_runoff_wards<-inc_voteshare_df %>%
  filter(inc==1) %>%
  filter(type=="Runoff" & votepct>0.45 & votepct<0.55) %>%
  distinct() %>%
  mutate(treated = ifelse(votepct < 0.5, 1, 0)) %>%
  select(ward, year, votepct, treated)
#save in csv
write.csv(close_runoff_wards, "../temp/close_runoff_wards.csv", row.names = FALSE)


#Create a dataframe that documents all wards that have any change in alderman
#First, create a new variable 'prev_inc_candidate' to store the incumbent candidate of the previous year
temp <- inc_voteshare_df %>%
  arrange(ward, year) %>%
  group_by(ward) %>%
  mutate(prev_inc_candidate = ifelse(inc == 1, candidate, NA)) %>%
  mutate(prev_inc_candidate = lag(prev_inc_candidate, default = NA)) %>%
  ungroup()

# Now we create the 'treated' variable
all_treated_df <- temp %>%
  group_by(ward, year) %>%
  mutate(treated = case_when(
    (inc == 1 & candidate != prev_inc_candidate) | inc == 0 ~ 1,
    TRUE ~ 0
  )) %>%
  ungroup() %>%
  distinct()