library(tidyverse)
library(ggplot2)
library(scales)
ARGS<- commandArgs(trailingOnly = TRUE)
df <- readRDS(paste0("../temp/stone_eventstudy_", ARGS[1], "_precincts.rds"))
output_file <- paste0("../output/stone_eventstudy_", ARGS[1], "_precinct_timeline.png")
#group by year and calculate the mean of the top and bottom precincts

df <- df %>%
  group_by(year, lab) %>%
  summarise(total_spending = sum(weighted_cost)) %>%
  ungroup() 


#create a line chart of the mean spending of the top and bottom precincts
figure <- ggplot(df, aes(x = as.factor(year))) + 
  geom_line(aes(y = total_spending, color = lab, linetype = lab, group = lab)) + 
  geom_vline(aes(xintercept = "2011"), linetype="dashed", color = "grey50") + 
  labs(x = "Year", y = "Total spending (in $K)") +  
  scale_y_continuous(labels = comma_format(scale = 1/1000)) +  
  scale_x_discrete(breaks = unique(df$year)[seq(1, length(unique(df$year)), by = 2)]) +
  theme_bw() +
  theme(
    plot.caption = element_text(hjust = 0.5, size = 12, margin = margin(t = 0, b = 0)),
    plot.margin = margin(0, 0, 0, 0),  # top, right, bottom, left margins set to zero
    legend.title = element_text(hjust = 0.5)  # horizontally center the legend title
  )
#save the figure as a png
png(filename = output_file, width = 6, height = 4, units = "in", res = 300)
print(figure)
dev.off()
