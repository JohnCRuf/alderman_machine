library(sf)
library(tidyverse)
library(assertthat)
library(ggmap)
library(ggplot2)
library(viridis)
library(labeling)
library(RColorBrewer)
ARGS<- commandArgs(trailingOnly = TRUE)
output_file <- paste0("../output/stone_", ARGS[1], "_", ARGS[2], "_precinct_results.png")
#load the data
stone_data <- readRDS("../temp/stone_dataset.rds")

#filter stone data to include only data with year = ARGS[1] and type = ARGS[2]
stone_data <- stone_data %>%
  filter(year == ARGS[1], type == ARGS[2])
#add variable net which is -1 if inc 0 and 1 if inc = 1
stone_data <- stone_data %>%
  mutate(net = case_when(inc == 0 ~ -1,
                         inc == 1 ~ 1))
#group by precinct and calculate net votes by taking votes when inc = 1 and minus votes when inc = 0
stone_data_inc <- stone_data %>%
  group_by(precinct, geometry) %>%
  summarise(net_votes = sum(votecount*net)) %>%
  ungroup()
#convert to sf object
stone_data_inc <- st_as_sf(stone_data_inc)
#assert that there are 45 observations
assert_that(nrow(stone_data_inc) == 45)
#plot the map
#set anything above 200 to 200 and anything below -200 to -200
stone_data_inc$net_votes[stone_data_inc$net_votes > 200] <- 200
stone_data_inc$net_votes[stone_data_inc$net_votes < -200] <- -200

breaks <- seq(-200, 200, by = 50)
n_colors <- length(breaks) - 1
diverging_colors <- colorRampPalette(rev(brewer.pal(n = 11, name = "RdBu")))(n_colors)

figure <- ggplot() +
  geom_sf(data = stone_data_inc, aes(fill = net_votes)) +
  scale_fill_gradientn(name = "Net votes \n for Ald. Stone", 
                       colours = diverging_colors, 
                       breaks = breaks, 
                       limits = c(-200, 200),
                       guide = guide_colorbar(ticks.colour = "black", ticks.linewidth = 0.5)) +
  theme_void() +
  labs(caption = "Source: Chicago Board of Elections") +
  theme(
    plot.caption = element_text(hjust = 0.5, size = 12, margin = margin(t = 0, b = 0)),
    plot.margin = margin(0, 0, 0, 0),  # top, right, bottom, left margins set to zero
    legend.title = element_text(hjust = 0.5)  # horizontally center the legend title
  )

#save the map
png(filename = output_file, width = 8, height = 8, units = "in", res = 300)
print(figure)
dev.off()