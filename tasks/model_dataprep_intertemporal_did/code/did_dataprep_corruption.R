library(tidyverse)
library(sf)
library(assertthat)
menu_df <- read_rds("../input/ward_precinct_menu_panel_2012_2022.rds")
#convert ward_locate to double
menu_df <- menu_df %>%
  mutate(ward_locate = as.numeric(ward_locate),
         precinct_locate = as.numeric(precinct_locate))
support_df <- read.csv("../input/incumbent_contribution_supporting_opposing_precincts.csv") %>%
filter(map == "2012-2022")

# ward list
treatment_list <- list( c(22, 2019), c(25, 2019), c(20, 2019), c(23, 2018))
#Ed Burke,  Carrie Austin,  Ricardo Munoz,  
#Danny Solis,  Proco Joe Moreno,  Willie Cochran,  Michael Zalewski
# Youngest was elected in 2010
treatment_ward_list <- c(22, 25, 20)
control_ward_list <- c(9, 37, 27, 44, 26, 12, 3, 8, 14, 34) #need 26 12 3 5 8

#assert that all wards in control list and treatment list are in `supporting_df`
assert_that(all(control_ward_list %in% support_df$ward))
assert_that(all(treatment_ward_list %in% support_df$ward))
assert_that(all(control_ward_list %in% menu_df$ward_locate))
assert_that(all(treatment_ward_list %in% menu_df$ward_locate))


# rank precinct by contribution percentile per ward
support_df <- support_df %>%
  group_by(ward) %>%
  mutate(percentile = rank(total_contribution)/n()) %>%
  ungroup() %>%
  mutate(percentile = percentile*100)
#merge with menu_df
menu_df <- menu_df %>%
  left_join(support_df, by = c("ward_locate" = "ward", "precinct_locate"))


menu_df <- menu_df %>%
  mutate(treatment = ifelse(ward_locate %in% treatment_ward_list & year >= 2019, 1, 0))

#filter menu_df to only include wards in ward_list and years greater than 2012
menu_df <- menu_df %>%
  filter(ward_locate %in% c(treatment_ward_list, control_ward_list) & year >= 2012)
menu_df <- menu_df %>%
  rename(ward = ward_locate, precinct = precinct_locate)
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

#Remove geometry using st_drop_geometry
menu_df <- menu_df %>%
  st_drop_geometry() %>%
  select(-geometry)
#create unique ward_precinct id for each ward -precinct combo
menu_df <- menu_df %>%
  mutate(ward_precinct = paste0(ward, "_", precinct))
#assert that the number of observations is the same as unique ward_precincts times the number of years and print out the difference
assert_that(nrow(menu_df) == length(unique(menu_df$ward_precinct))*length(unique(menu_df$year)))
#write to csv
write_csv(menu_df, "../output/corruption_intertemporal_did_panel.csv")