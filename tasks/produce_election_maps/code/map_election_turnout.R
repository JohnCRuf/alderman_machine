library(sf)
library(tidyverse)
library(assertthat)
library(ggmap)
library(ggplot2)
library(viridis)
library(labeling)
library(RColorBrewer)
source("../input/map_data_prep_fn.R")
ARGS<- commandArgs(trailingOnly = TRUE)
output_file <- ARGS[6]

data <- read.csv("../input/incumbent_challenger_voteshare_df_precinct_level.csv") 
data <- data %>%
  mutate(type = case_when(type == "General" ~ "general",
                          type == "Runoff" ~ "runoff")) #to simplify arguments and ergo filenames
data <- data %>%
  filter(ward == as.numeric(ARGS[1]), year == ARGS[2], type == ARGS[3])
#load map based on year selection
if (as.numeric(ARGS[1]) < 2012) {
  map <- map_load("../temp/ward_precincts_2003_2011/ward_precincts_2003_2011.shp")
} else {
  map <- map_load("../temp/ward_precincts_2012_2022/ward_precincts_2012_2022.shp")
}
#clean map
map <- map %>%
  rename(ward = ward_locate,
         precinct = precinct_locate)

data <- data %>%
  left_join(map, by = c("ward", "precinct"))

#group by precinct and calculate net votes by taking votes when inc = 1 and minus votes when inc = 0
data_inc <- data %>%
  group_by(precinct, geometry) %>%
  summarise(total_votes = sum(votecount)) %>%
  ungroup()

#convert to sf object
data_inc <- st_as_sf(data_inc)

#map parameters
breakmax <- as.numeric(ARGS[4])
break_size <- as.numeric(ARGS[5])
data_inc$total_votes[data_inc$total_votes > breakmax] <- breakmax
breaks <- seq(-breakmax,breakmax , by = break_size)
n_colors <- length(breaks) - 1
diverging_colors <- colorRampPalette(c("white", "#4B0082"))(n_colors)


#calculating central point for each precinct
data_inc$centroid <- sf::st_centroid(data_inc)
data_inc$longitude <- sf::st_coordinates(data_inc$centroid)[,1]
data_inc$latitude <- sf::st_coordinates(data_inc$centroid)[,2]

#function to calculate median voter
weighted_median <- function(values, weights) {
  sorted_indices <- order(values)
  sorted_weights <- weights[sorted_indices]
  sorted_values <- values[sorted_indices]
  cumulative_weights <- cumsum(sorted_weights)
  median_weight <- sum(weights) / 2
  median_index <- which.min(abs(cumulative_weights - median_weight))
  return(sorted_values[median_index])
}

median_longitude <- weighted_median(data_inc$longitude, data_inc$total_votes)
median_latitude <- weighted_median(data_inc$latitude, data_inc$total_votes)

median_location <- data.frame(longitude = median_longitude, latitude = median_latitude)

figure <- ggplot() +
  geom_sf(data = data_inc, aes(fill = total_votes)) +
  scale_fill_gradientn(name = "Turnout", 
                       colours = diverging_colors, 
                       breaks = breaks, 
                       limits = c(0, 400),
                       guide = guide_colorbar(ticks.colour = "black", ticks.linewidth = 0.5)) +
  # Add the median point with an aesthetic for the legend
  geom_point(data = median_location, aes(x = longitude, y = latitude, color = "Median Voter"), size = 4) +
  scale_color_manual(name = "", values = c("Median Voter" = "red"), labels = "Median Voter") +
  theme_void() +
  labs(caption = "Source: Chicago Board of Elections") +
  theme(
    plot.caption = element_text(hjust = 0.5, size = 16, margin = margin(t = 0, b = 0)),
    plot.margin = margin(0, 0, 0, 0),  # top, right, bottom, left margins set to zero
    legend.title = element_text(hjust = 0.5, size = 14),  # Increase legend title size
    legend.text = element_text(size = 12),  # Increase legend text size
    legend.key.size = unit(1.5, "lines")   # Increase legend key size
  )+
  guides(color = guide_legend(override.aes = list(fill = NA)))  # To display the color legend without a box fill


#save the map
png(filename = output_file, width = 8, height = 8, units = "in", res = 300)
print(figure)
dev.off()