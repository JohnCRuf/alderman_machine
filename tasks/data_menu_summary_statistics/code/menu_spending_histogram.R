library(tidyverse)
library(assertthat)
library(ggplot2)
library(sf)
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
  st_drop_geometry() 
#drop observations of menu data where year is greater than 2011 and ward != 50
menu_data <- menu_data %>%
  filter(year < year_2, year > year_1)

#take total spending by precinct
#print out "blergh" to blergh.txt
precinct_spending_df <- menu_data %>%
    group_by(ward_locate, precinct_locate) %>%
    summarize(precinct_spending = sum(weighted_cost)) %>%
    ungroup() %>%
    mutate(observed_spending_fraction = precinct_spending/sum(precinct_spending))
#winsorize by the 95th percentile
q_high <- quantile(precinct_spending_df$precinct_spending, probs = 0.99)
precinct_spending_df$precinct_spending <- ifelse(precinct_spending_df$precinct_spending > q_high, q_high, precinct_spending_df$precinct_spending)

#create a histogram of precinct-level spending
histogram <- ggplot(precinct_spending_df, aes(x = precinct_spending/1000)) +
  geom_histogram(binwidth = 25, fill = NA, color = "red", linewidth = 1.2) +
  labs(x = "Winsorized Precinct Spending (Thousands of Dollars)", y = "Number of Precincts") +
  theme_light()

ggsave(output_file, plot = histogram, width = 8, height = 6, units = "in", dpi = 300)
