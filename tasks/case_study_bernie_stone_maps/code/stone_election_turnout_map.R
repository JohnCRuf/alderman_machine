library(sf)
library(tidyverse)
library(assertthat)
library(ggmap)
library(ggplot2)
library(viridis)
library(labeling)
library(RColorBrewer)
ARGS<- commandArgs(trailingOnly = TRUE)
output_file <- paste0("../output/stone_", ARGS[1], "_", ARGS[2], "_precinct_turnout.png")
#load the data
stone_data <- readRDS("../temp/stone_dataset.rds")
stone_data <- stone_data %>%
  filter(year == ARGS[1], type == ARGS[2])

#group by precinct and calculate net votes by taking votes when inc = 1 and minus votes when inc = 0
stone_data_inc <- stone_data %>%
  group_by(precinct, geometry) %>%
  summarise(total_votes = sum(votecount)) %>%
  ungroup()
#convert to sf object
stone_data_inc <- st_as_sf(stone_data_inc)
#assert that there are 45 observations
assert_that(nrow(stone_data_inc) == 45)
#plot the map
#set anything above 200 to 200 and anything below -200 to -200
stone_data_inc$total_votes[stone_data_inc$total_votes > 400] <- 400

breaks <- seq(0, 400, by = 50)
n_colors <- length(breaks) - 1
diverging_colors <- colorRampPalette(c("white", "#4B0082"))(n_colors)


#calculating central point for each precinct
stone_data_inc$centroid <- sf::st_centroid(stone_data_inc)
stone_data_inc$longitude <- sf::st_coordinates(stone_data_inc$centroid)[,1]
stone_data_inc$latitude <- sf::st_coordinates(stone_data_inc$centroid)[,2]

weighted_median <- function(values, weights) {
  sorted_indices <- order(values)
  sorted_weights <- weights[sorted_indices]
  sorted_values <- values[sorted_indices]
  cumulative_weights <- cumsum(sorted_weights)
  median_weight <- sum(weights) / 2
  median_index <- which.min(abs(cumulative_weights - median_weight))
  return(sorted_values[median_index])
}

median_longitude <- weighted_median(stone_data_inc$longitude, stone_data_inc$total_votes)
median_latitude <- weighted_median(stone_data_inc$latitude, stone_data_inc$total_votes)

median_location <- data.frame(longitude = median_longitude, latitude = median_latitude)

figure <- ggplot() +
  geom_sf(data = stone_data_inc, aes(fill = total_votes)) +
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
    plot.caption = element_text(hjust = 0.5, size = 12, margin = margin(t = 0, b = 0)),
    plot.margin = margin(0, 0, 0, 0),
    legend.title = element_text(hjust = 0.5)
  ) +
  guides(color = guide_legend(override.aes = list(fill = NA)))  # To display the color legend without a box fill


#save the map
png(filename = output_file, width = 8, height = 8, units = "in", res = 300)
print(figure)
dev.off()