library(tidyverse)
library(sf)
library(assertthat)
library(ggmap)
library(ggplot2)
library(stringr)
library(viridis)
library(labeling)
source("menu_title_mapper.R")
# Read and clean data
ARGS<- commandArgs(trailingOnly = TRUE) # nolint
menu_data <- readRDS(ARGS[1])
year_1 <- ARGS[2]
year_2 <- ARGS[3]
ward_select <- ARGS[4]
legend_setting <- ARGS[5]
color_setting <- ARGS[6]
break_size <- as.numeric(ARGS[7])
break_max <- as.numeric(ARGS[8])
output_file <- ARGS[9]

#drop observations of menu data where year is greater than 2011 and ward != 50
menu_data <- menu_data %>%
  filter(year < year_2, year > year_1, ward_locate == ward_select)

#take total spending by precinct
precinct_spending_df <- menu_data %>%
    group_by(ward_locate, precinct_locate, geometry) %>%
    summarize(precinct_spending = sum(weighted_cost)) %>%
    ungroup() %>%
    mutate(observed_spending_fraction = precinct_spending/sum(precinct_spending))

precinct_spending_map <- st_as_sf(precinct_spending_df)

arg_to_legend_list <- arg_to_legend(legend_setting, year_1, year_2, precinct_spending_map)
#breaks go from 0 to seq_max in increments of break_size
breaks <- seq(0, break_max, break_size)
colors <- arg_to_color(color_setting, breaks)
df <- arg_to_legend_list[[1]]
scale_name <- arg_to_legend_list[[2]]
label_name <- arg_to_legend_list[[3]]

figure <- ggplot() +
  geom_sf(data = df, aes(fill = precinct_spending)) +
  scale_fill_gradientn(name = scale_name, 
                       colours = colors, 
                       breaks = breaks, 
                       labels = label_name,
                       guide = guide_colorbar(ticks.colour = "black", ticks.linewidth = 0.5)) +
  theme_void() +
  labs(caption = "Source: FOIA request") +
  theme(
    plot.caption = element_text(hjust = 0.5, size = 12, margin = margin(t = 0, b = 0)),
    plot.margin = margin(0, 0, 0, 0),  # top, right, bottom, left margins set to zero
    legend.title = element_text(hjust = 0.5)  # horizontally center the legend title
  )

#save the map to output_file
png(filename = output_file, width = 8, height = 8, units = "in", res = 300)
print(figure)
dev.off()