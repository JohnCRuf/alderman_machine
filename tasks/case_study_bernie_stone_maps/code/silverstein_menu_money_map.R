library(sf)
library(tidyverse)
library(assertthat)
library(ggmap)
library(ggplot2)
library(viridis)
library(labeling)
ARGS<- commandArgs(trailingOnly = TRUE)
ARGS<- c(2011, "general")
#load the data
silverstein_data <- readRDS("../temp/silverstein_dataset.rds")

#filter silverstein data to include only data with year = ARGS[1] and type = ARGS[2]
silverstein_data <- silverstein_data %>%
  filter(year == ARGS[1], type == ARGS[2])
#filter to in=1
silverstein_data_inc <- silverstein_data %>%
  filter(inc == 1)
#convert to sf object
silverstein_data_inc <- st_as_sf(silverstein_data_inc)
#assert that there are 45 observations
assert_that(nrow(silverstein_data_inc) == 45)
#round the maximum spending to the nearest 100,000 and save as a scalar
max_spending <- 700000
breaks <- seq(0, max_spending, by = 100000)
colors <- viridis::viridis(length(breaks) - 1, direction = -1, option = "viridis")

figure <- ggplot() +
  geom_sf(data = silverstein_data_inc, aes(fill = total_spending)) +
  scale_fill_gradientn(name = "Menu Spending \n 2012-2015 \n(thousands of dollars)", 
                       colours = colors, 
                       breaks = breaks, 
                       limits = c(0, max_spending),  # Add this line to set the limits
                       labels = scales::comma_format(scale = 1/1000),
                       guide = guide_colorbar(ticks.colour = "black", ticks.linewidth = 0.5)) +
  theme_void() +
  labs(caption = "Source: FOIA request") +
  theme(
    plot.caption = element_text(hjust = 0.5, size = 12, margin = margin(t = 0, b = 0)),
    plot.margin = margin(0, 0, 0, 0),  # top, right, bottom, left margins set to zero
    legend.title = element_text(hjust = 0.5)  # horizontally center the legend title
  )



#save the map
png(filename = "../output/silverstein_menu_money_spending_map_2012_2015.png", width = 8, height = 8, units = "in", res = 300)
print(figure)
dev.off()

