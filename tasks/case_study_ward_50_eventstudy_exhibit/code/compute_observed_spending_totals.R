library(tidyverse)
library(sf)

menu_data <- readRDS("../input/ward_precinct_menu_panel_2003_2011.rds")
menu_data <- menu_data %>%
  filter(year >= 2005, year <= 2015, ward_locate == 50) 

total_spending <- menu_data %>%
  group_by(year) %>%
  summarise(total_spending = sum(weighted_cost)) %>%
  ungroup() 
#save as csv
write_csv(total_spending, "../output/stone_eventstudy_observed_spending_precincts.csv")
