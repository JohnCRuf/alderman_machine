library(tidyverse)
library(assertthat)
library(stringr)
ARGS<- commandArgs(trailingOnly = TRUE) 
menu_data <- readRDS(ARGS[1])
year_1 <- as.numeric(ARGS[2])
year_2 <- as.numeric(ARGS[3])
#remove geometry column
menu_data <- menu_data %>%
  select(-geometry) 
#generate a new variable called cycle that is 2007 if year < 2007, 2011 if year >= 2007 and year < 2011, and 2015 if year >= 2011 and year < 2015 and 2019 if year >= 2015
menu_data <- menu_data %>%
  mutate(cycle = case_when(year < 2007 ~ 2007,
                           year >= 2007 & year < 2011 ~ 2011,
                           year >= 2011 & year < 2015 ~ 2015,
                           year >= 2015 ~ 2019))
#for each ward year, calculate the total spending 
total_df <- menu_data %>%
  group_by(cycle, ward_locate) %>%
  summarise(total_spending = sum(weighted_cost)) %>%
  ungroup()
#join total spending to menu data
menu_data <- menu_data %>%
  left_join(total_df, by = c("cycle", "ward_locate")) %>%
  mutate(observed_spending_fraction = weighted_cost/total_spending)
# assert that total_spending is never NA
assert_that(all(!is.na(menu_data$total_spending)))
# remove all years that total spending is 0
menu_data <- menu_data %>%
  filter(total_spending != 0)
#compute HHI index for each ward year
hhi_df <- menu_data %>%
  group_by(cycle, ward_locate) %>%
  summarise(hhi = sum(observed_spending_fraction^2)*100) %>%
  ungroup()
#save to .csv
output_name <- paste0("../output/menu_cycle_hhi_", year_1, "_", year_2, ".csv")
write_csv(hhi_df, output_name)