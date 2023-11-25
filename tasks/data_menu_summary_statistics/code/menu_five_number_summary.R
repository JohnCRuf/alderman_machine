library(tidyverse)
library(assertthat)
library(ggplot2)
library(sf)
library(knitr)
library(kableExtra)
library(stringr)
# Read and clean data
ARGS<- commandArgs(trailingOnly = TRUE) # nolint
menu_data <- readRDS(ARGS[1])
year_1 <- ARGS[2]
year_2 <- ARGS[3]
output_file <- ARGS[4]
text_year1_to_year2 <- paste0(year_1, "-", year_2)

#st_drop_geometry
menu_data <- menu_data %>%
  st_drop_geometry()  %>%
  select(-geometry)
#drop observations of menu data where year is greater than 2011 and ward != 50
menu_data <- menu_data %>%
  filter(year < year_2, year > year_1)

#create fraction of total spending by precinct
menu_data <- menu_data %>%
    group_by(ward_locate, year) %>%
    mutate(total_spending = sum(weighted_cost)) %>%
    ungroup() %>%
    mutate(fraction_spending = weighted_cost / total_spending*100)
#create a summary statistics table of the mean, median, standard deviation, lower and upper quartiles of fraction_spending by precinct
summary_stats <- menu_data %>%
    summarise(mean_fraction_spending = mean(fraction_spending),
              median_fraction_spending = median(fraction_spending),
              sd_fraction_spending = sd(fraction_spending),
              lower_quartile_fraction_spending = quantile(fraction_spending, 0.25),
              upper_quartile_fraction_spending = quantile(fraction_spending, 0.75)) 

# export summary statistics table as a latex table
summary_stats %>%
    select(mean = mean_fraction_spending, 
           median = median_fraction_spending, 
           sd = sd_fraction_spending, 
           `upper quartile` = upper_quartile_fraction_spending, 
           `lower quartile` = lower_quartile_fraction_spending) %>%
    kable(format = "latex", booktabs = TRUE, digits = 2, 
          caption = paste0("Summary statistics of fraction of total spending by precinct from ", year_1, " to ", year_2),
          align = 'c')