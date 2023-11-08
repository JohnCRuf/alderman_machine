library(tidyverse)
library(sf)
library(assertthat)
library(ggmap)
library(ggplot2)
library(stringr)
library(viridis)
library(labeling)
source("contribution_title_mapper.R")
# Read and clean data
ARGS<- commandArgs(trailingOnly = TRUE) # nolint
contribution_data <- readRDS(ARGS[1])
ward_select <- ARGS[2]
year_1 <- ARGS[3]
year_2 <- ARGS[4]
legend_setting <- "total"
color_setting <- "magma"
output_file <- ARGS[5]

#drop observations of menu data where year is greater than 2011 and ward != 50
contribution_data <- contribution_data %>%
  filter(year < year_2, year > year_1, ward_locate == ward_select)

#take total spending by precinct
contribution_spending_df <- contribution_data %>%
    group_by(ward_locate, precinct_locate, geometry) %>%
    summarize(contribution_spending = sum(total_contribution)) %>%
    ungroup() %>%
    mutate(observed_spending_fraction = contribution_spending/sum(contribution_spending))

contribution_spending_map <- st_as_sf(contribution_spending_df)

arg_to_legend_list <- arg_to_legend(legend_setting, year_1, year_2, contribution_spending_map)
#breaks go from 0 to seq_max in increments of break_size
#break max is the max value of the variable rounded up the nearest 1000
break_max <- ceiling(max(contribution_spending_df$contribution_spending)/1000)*1000
#break size is 1/10 of break_max
break_size <- break_max/10
breaks <- seq(0, break_max, break_size)
colors <- arg_to_color(color_setting, breaks)
df <- arg_to_legend_list[[1]]
scale_name <- arg_to_legend_list[[2]]
label_name <- arg_to_legend_list[[3]]

figure <- ggplot() +
  geom_sf(data = df, aes(fill = contribution_spending)) +
  scale_fill_gradientn(name = scale_name, 
                       colours = colors, 
                       breaks = breaks, 
                       labels = label_name,
                       guide = guide_colorbar(ticks.colour = "black", ticks.linewidth = 0.5)) +
  theme_void() +
  labs(caption = "Source: Illinois State Board of Elections Website") +
  theme(
    plot.caption = element_text(hjust = 0.5, size = 12, margin = margin(t = 0, b = 0)),
    plot.margin = margin(0, 0, 0, 0),  # top, right, bottom, left margins set to zero
    legend.title = element_text(hjust = 0.5)  # horizontally center the legend title
  )

#save the map to output_file
png(filename = output_file, width = 8, height = 8, units = "in", res = 300)
print(figure)
dev.off()