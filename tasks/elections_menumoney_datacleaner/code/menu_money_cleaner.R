#John Ruf 05/2022
#This script is meant to clean the menu money df

library(tidyverse)
library(stringr)
library(readr)
library(assertr)

menu_df_2005_2010<-read_csv("../input/menu_2005_2010.csv")
menu_df_2011_2015<-read_csv("../input/menu_2011_2015.csv")
menu_df_2016_2022<-read_csv("../input/menu_2016_2022.csv")
#removing irrelevant quantity columns
menu_df_2005_2010<-menu_df_2005_2010%>%
  select(-c(cg_blks,sw_blks,humps,blocks,unitcount))
menu_df_2011_2015<-menu_df_2011_2015%>%
  select(-c(blocks,unitcount))
menu_df_2005_2010 <- menu_df_2005_2010 %>% rename(est_cost = estcost)
menu_df_2011_2015 <- menu_df_2011_2015 %>% rename(est_cost = estcost)
menu_df_2016_2022 <- menu_df_2016_2022 %>% rename(est_cost = estcost)
#common words for on-menu projects
menu <- c("Streets/CDOT", "Lighting", "Cameras", "Menu", "Alley", "Sidewalk",
"Bollard", "street", "Street", "Pavement", "Pedestrian", "Guardrail", "Median",
"Traffic", "Viaduct", " Gutter", "Curb", "Bridge", "Pothole", "Parking", "Bus",
"Bike")
#common words for beauty projects
beauty <- c("Art", "Tree", "Park ", "Playground", "Graffiti", "Garden", "pool")
#set ward to character
menu_df_2005_2010$ward <- as.character(menu_df_2005_2010$ward)
menu_df_2011_2015$ward <- as.character(menu_df_2011_2015$ward)
menu_df_2016_2022$ward <- as.character(menu_df_2016_2022$ward)
#remove quotes " from est_cost
menu_df_2005_2010$est_cost <- as.numeric(str_remove_all(menu_df_2005_2010$est_cost, '"'))
menu_df_2011_2015$est_cost <- as.numeric(str_remove_all(menu_df_2011_2015$est_cost, '"'))
menu_df_2016_2022$est_cost <- as.numeric(str_remove_all(menu_df_2016_2022$est_cost, '"'))
#Set year to numeric
menu_df_2005_2010$year <- as.numeric(menu_df_2005_2010$year)
menu_df_2011_2015$year <- as.numeric(menu_df_2011_2015$year)
menu_df_2016_2022$year <- as.numeric(menu_df_2016_2022$year)
#set ward to numeric
menu_df_2005_2010$ward <- as.numeric(menu_df_2005_2010$ward)
menu_df_2011_2015$ward <- as.numeric(menu_df_2011_2015$ward)
menu_df_2016_2022$ward <- as.numeric(menu_df_2016_2022$ward)

#manually fixing glitched dataframes
menu_df_2005_2010 <- menu_df_2005_2010 %>%
  mutate(location = ifelse(is.na(location), "Not available", location))

menu_df_2011_2015 <- menu_df_2011_2015 %>%
  mutate(location = ifelse(is.na(location), "Not available", location),
        est_cost = ifelse(location == "Fireman's Park Restoration" & year == 2011, 1824, est_cost),
        est_cost = ifelse(location == "5216 W Lawrence" & year == 2011, 392, est_cost)
  )
menu_df_2016_2022 <- menu_df_2016_2022 %>%
  mutate(location = ifelse(is.na(location), "Not available", location),
        est_cost = ifelse(location == "2701 W FRANCIS PL" & year == 2019, 1800.00, est_cost),
        est_cost = ifelse(location == "5690 W GOODMAN ST:W GOODMAN ST & N PARKSIDE AVE:W GOODMAN ST" & year == 2019, 16237.57, est_cost)
        )
menu_df_2016_2022 <- menu_df_2016_2022[menu_df_2016_2022$location != "1264 N WOOD ST N WOOD ST & W OHIO ST",]
menu_df_2016_2022 <- menu_df_2016_2022[menu_df_2016_2022$location != "ON W BRYN MAWR AVE FROM N PARKSIDE AVE (5630 W) TO N MAJOR AVE (",]
#creating a new rows to replace glitched ones
row_1 <- data.frame(ward = 1,type = "Sidewalk Menu", location = "1264 N WOOD ST", est_cost = 2097.82, year = 2019)
row_2 <- data.frame(ward = 1,type = "POD Camera Relocation", location = "2536 W CORTLAND ST", est_cost = 1800, year = 2019)
row_3 <- data.frame(ward = 45,type = "Sidewalk Menu", location = "ON W BRYN MAWR AVE FROM N PARKSIDE AVE (5630 W) TO N MAJOR AVE (5700 W)", est_cost = 15256.82, year = 2019)
menu_df_2016_2022 <- bind_rows(menu_df_2016_2022, row_1, row_2, row_3)
menu_df <- bind_rows(menu_df_2005_2010, menu_df_2011_2015, menu_df_2016_2022)
#assert no est_cost is NA
menu_df <- menu_df %>%
  verify(nrow(menu_df[is.na(menu_df$est_cost),])==0)

write_csv(menu_df, "../output/menu_df.csv")


menu_df <- menu_df %>% #create dummy variable for on menu and beauty
  mutate(#create variable menu
    on_menu = ifelse(str_detect(type, paste(menu, collapse = "|")),
      "on_menu", "off_menu"),
    #create variable beauty
    beauty = ifelse(str_detect(type, paste(beauty, collapse = "|")),
      "beauty", "not_beauty"))

menu_panel_df_offmenu = menu_df %>%
  group_by(ward,year, on_menu) %>%
  summarise(expenditures = sum(est_cost)) %>%
  pivot_wider(names_from = on_menu,values_from = expenditures) %>%
  mutate(off_menu = ifelse(is.na(off_menu), 0, off_menu))


menu_panel_df_beauty = menu_df %>%
  group_by(ward,year, beauty) %>%
  summarise(expenditures = sum(est_cost)) %>%
  pivot_wider(names_from = beauty,values_from = expenditures) %>%
  mutate(beauty = ifelse(is.na(beauty), 0, beauty))

#merge the two dataframes
menu_panel_df = merge(menu_panel_df_offmenu, menu_panel_df_beauty,
  by = c("ward", "year"))
#assert no NAs
menu_panel_df <- menu_panel_df %>%
  verify(nrow(menu_panel_df[is.na(menu_panel_df),])==0)

write_csv(menu_panel_df, file = "../output/menu_panel_df.csv")
