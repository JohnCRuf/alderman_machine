library(tidyverse)
library(sf)
library(assertthat)
library(ggmap)
library(ggplot2)
library(stringr)
library(labeling)
source("menu_title_mapper.R")
# Read and clean data
ARGS<- commandArgs(trailingOnly = TRUE) # nolint
menu_data <- readRDS(ARGS[1])
year_1 <- ARGS[2]
year_2 <- ARGS[3]
legend_setting <- ARGS[4]
break_size <- as.numeric(ARGS[5])
break_max <- as.numeric(ARGS[6])
output_file <- ARGS[7]
text_year1_to_year2 <- paste0(year_1, "-", year_2)

#drop observations of menu data where year is greater than 2011 and ward != 50
menu_data <- menu_data %>%
  filter(year < year_2, year > year_1)

#take total spending by precinct
precinct_spending_df <- menu_data %>%
    group_by(ward_locate, precinct_locate, geometry) %>%
    summarize(precinct_spending = sum(weighted_cost)) %>%
    ungroup() %>%
    mutate(observed_spending_fraction = precinct_spending/sum(precinct_spending))

precinct_spending_map <- st_as_sf(precinct_spending_df)

ward_level_map <- precinct_spending_map %>%
  group_by(ward_locate) %>%
  summarize(
    total_spending = sum(precinct_spending, na.rm = TRUE),
    geometry = st_union(geometry)
  ) %>%
  ungroup()

arg_to_legend_list <- arg_to_legend(legend_setting, year_1, year_2, precinct_spending_map)
#breaks go from 0 to seq_max in increments of break_size
breaks <- seq(0, break_max, break_size)
df <- arg_to_legend_list[[1]]
scale_name <- arg_to_legend_list[[2]]
label_name <- arg_to_legend_list[[3]]
# Create the map
q_low <- quantile(precinct_spending_map$precinct_spending, probs = 0.05)
q_high <- quantile(precinct_spending_map$precinct_spending, probs = 0.95)

# winsorize the data to the 95th percentile
precinct_spending_map$precinct_spending <- ifelse(precinct_spending_map$precinct_spending > q_high, q_high, precinct_spending_map$precinct_spending)

heatmap <- ggplot() +
  geom_sf(data = precinct_spending_map, aes(fill = precinct_spending/1000), alpha = 0.7, color = NA) +
  geom_sf(data = ward_level_map, fill = NA, color = "black", size = 2) + # Overlay ward boundaries
  scale_fill_gradient(low = "skyblue", high = "red") +
  labs(fill = paste0("Precinct Spending (", text_year1_to_year2, ") \n Thousands of Dollars")) + # Label for the legend
  theme_void() + # Minimalist theme
  theme(
    legend.title = element_text(size = 14),  # Increase legend title size
    legend.text = element_text(size = 12),   # Increase legend text size
    legend.position = "bottom"               # Optionally change legend position
  )

# Print the heatmap
ggsave(output_file, heatmap, width = 8, height = 6)