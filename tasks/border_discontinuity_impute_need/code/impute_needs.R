library(tidyverse)
library(sf)
library(units)
source("../input/map_data_prep_fn.R")
#load needs data
df <- read.csv("../input/oig_audit_needs.csv")
# load 2012-2015 map
map <- map_load("../temp/ward_precincts_2012_2022/ward_precincts_2012_2022.shp")

# take map and aggregate to the ward level and aggregate the geometry to the ward level
map_ward <- map %>%
  group_by(ward_locate) %>%
  summarize(geometry = st_union(geometry)) 
map_ward$area <- st_area(map_ward$geometry) %>% set_units(mi^2)
#remove units from area
map_ward$area <- as.numeric(map_ward$area)

df <- df %>% 
  select(ward, pct_of_needs) %>%
    mutate(pct_of_needs = as.numeric(gsub("%", "", pct_of_needs))) 

#join the map and df
map_ward <- map_ward %>% 
  left_join(df, by = c("ward_locate" = "ward")) %>%
  mutate(log_area = log(area),
        log_area_sq = log_area^2,
        log_area_cub = log_area^3)

#regress pct_of_needs on area
lm1 <- lm(pct_of_needs ~ log_area + log_area_sq + log_area_cub, data = map_ward)
summary(lm1)
r2 <- summary(lm1)$r.squared
a_r2 <- summary(lm1)$adj.r.squared
r2 <- round(r2, 2)
a_r2 <- round(a_r2, 2)
r2_text <- paste0("R^2 = ", r2, "\nAdj. R^2 = ", a_r2)
#generate a line of predicted values for Area from 0 to 15 square miles in units of 0.01
pred <- data.frame(area = seq(1.5, 20, 0.01)) %>%
    mutate(log_area = log(area),
            log_area_sq = log_area^2,
            log_area_cub = log_area^3) %>%
  mutate(pred = predict(lm1, newdata = .))

#create a scatterplot of pct_of_needs vs area with a line with the predicted values in the pred dataframe with a legend that indicates the predicted values in the top right corner
fig <- ggplot(map_ward, aes(x = area, y = pct_of_needs)) +
  geom_point(aes(color = "Observed"), size = 3) +  # Observed points
  geom_line(data = pred, aes(x = exp(log_area), y = pred, color = "Predicted"), size = 1) +  # Predicted line
  labs(x = "Area (square miles)", y = "Percent of Needs Met") +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) +
  scale_color_manual(values = c("Observed" = "black", "Predicted" = "red"),
                     labels = c("Observed", "Predicted"),
                     name = "Data Type")
#write to output png
ggsave("../output/area_vs_pct_of_needs.png", fig, width = 6, height = 4)

#now import 2003-2011 map
map_2003 <- map_load("../temp/ward_precincts_2003_2011/ward_precincts_2003_2011.shp")
#collapse to ward level
map_ward_2003 <- map_2003 %>%
  group_by(ward_locate) %>%
  summarize(geometry = st_union(geometry))
map_ward_2003$area <- st_area(map_ward_2003$geometry) %>% set_units(mi^2)
#remove units from area
map_ward_2003$area <- as.numeric(map_ward_2003$area)
#add log area and log area squared and log area cubed
map_ward_2003 <- map_ward_2003 %>%
  mutate(log_area = log(area),
        log_area_sq = log_area^2,
        log_area_cub = log_area^3)
#predict pct_of_needs for 2003-2011
map_ward_2003 <- map_ward_2003 %>%
  mutate(pct_of_needs = predict(lm1, newdata = .))

#add variable called "year range" to map_2003 that is always 2003-2011
map_2003$year_range <- "2003-2011"

#take map_ward, remove percent of needs, add predicted percent of needs, and add year range
map_ward <- map_ward %>%
  select(-pct_of_needs) %>%
  mutate(pct_of_needs = predict(lm1, newdata = .),
        year_range = "2012-2022")

#combine map_ward and map_ward_2003
map_ward <- bind_rows(map_ward, map_ward_2003)

#write to output rda file
saveRDS(map_ward, "../output/ward_pct_of_needs.rda")