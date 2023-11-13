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
#load the data
data <- read.csv("../input/incumbent_challenger_voteshare_df_precinct_level.csv") 
data <- data %>%
  mutate(type = case_when(type == "General" ~ "general",
                          type == "Runoff" ~ "runoff"))
#filter stone data to include only data with year = ARGS[1] and type = ARGS[2]
data <- data %>%
  filter(ward == ARGS[1], year == as.numeric(ARGS[2]), type == ARGS[3])
#if ARGS[1] < 2012 load the 2012-2019 maps
if (as.numeric(ARGS[2]) < 2012) {
  map <- map_load("../temp/ward_precincts_2003_2011/ward_precincts_2003_2011.shp")
} else {
  map <- map_load("../temp/ward_precincts_2012_2022/ward_precincts_2012_2022.shp")
}
map <- map %>%
  rename(ward = ward_locate,
         precinct = precinct_locate)
#merge with data
data <- data %>%
  left_join(map, by = c("ward", "precinct"))
#add variable net which is -1 if inc 0 and 1 if inc = 1
data <- data %>%
  mutate(net = case_when(inc == 0 ~ -1,
                         inc == 1 ~ 1))
#group by precinct and calculate net votes by taking votes when inc = 1 and minus votes when inc = 0
data_inc <- data %>%
  group_by(precinct, geometry) %>%
  summarise(net_votes = sum(votecount*net)) %>%
  ungroup()
#convert to sf object
data_inc <- st_as_sf(data_inc)
#plot the map
#set anything above 200 to 200 and anything below breakmax to breakmax
breakmax <- as.numeric(ARGS[4])
break_size <- as.numeric(ARGS[5])
data_inc$net_votes[data_inc$net_votes > breakmax] <- breakmax
data_inc$net_votes[data_inc$net_votes < -breakmax] <- -breakmax

breaks <- seq(-breakmax,breakmax , by = break_size)
n_colors <- length(breaks) - 1
diverging_colors <- colorRampPalette(rev(brewer.pal(n = 11, name = "RdBu")))(n_colors)
name <- paste0("Net votes \n for Incumbent \n", ARGS[1], " ", ARGS[2], " election")
figure <- ggplot() +
  geom_sf(data = data_inc, aes(fill = net_votes)) +
  scale_fill_gradientn(name = "Net votes \n for Incumbent", 
                       colours = diverging_colors, 
                       breaks = breaks, 
                       limits = c(-breakmax, breakmax),
                       guide = guide_colorbar(ticks.colour = "black", ticks.linewidth = 0.5)) +
  theme_void() +
  labs(caption = "Source: Chicago Board of Elections") +
  theme(
    plot.caption = element_text(hjust = 0.5, size = 16, margin = margin(t = 0, b = 0)),
    plot.margin = margin(0, 0, 0, 0),  # top, right, bottom, left margins set to zero
    legend.title = element_text(hjust = 0.5, size = 14),  # Increase legend title size
    legend.text = element_text(size = 12),  # Increase legend text size
    legend.key.size = unit(1.5, "lines")   # Increase legend key size
  )

#save the map
png(filename = output_file, width = 8, height = 8, units = "in", res = 300)
print(figure)
dev.off()