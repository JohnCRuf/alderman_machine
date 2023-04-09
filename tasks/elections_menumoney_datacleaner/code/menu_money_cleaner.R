#This script is meant to clean the menu data extracted from expenditure PDFs.

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
  select(-c(blocks,unitcount,desc))
menu_df_list <- list(menu_df_2005_2010, menu_df_2011_2015, menu_df_2016_2022)


#manually fixing glitched data frames
menu_df_2011_2015 <- menu_df_2011_2015 %>%
  mutate(estcost = ifelse(location == "Fireman's Park Restoration" & year == 2011, 1824, estcost),
        estcost = ifelse(location == "5216 W Lawrence" & year == 2011, 392, estcost),
        location = ifelse(estcost == 35277, "Shabbona Park", location)
  )

menu_df_2016_2022 <- menu_df_2016_2022 %>%
  mutate(location = ifelse(is.na(location), "Not Available Currently", location),
        estcost = ifelse(location == "2701 W FRANCIS PL" & year == 2019, 1800.00, estcost),
        estcost = ifelse(location == "5690 W GOODMAN ST:W GOODMAN ST & N PARKSIDE AVE:W GOODMAN ST" & year == 2019, 16237.57, estcost)
        )
#deleting rows with un-correctable data
menu_df_2016_2022 <- menu_df_2016_2022[menu_df_2016_2022$location != "1264 N WOOD ST N WOOD ST & W OHIO ST",]
menu_df_2016_2022 <- menu_df_2016_2022[menu_df_2016_2022$location != "ON W BRYN MAWR AVE FROM N PARKSIDE AVE (5630 W) TO N MAJOR AVE (",]

#creating a new rows to replace un-correctable data
row_1 <- data.frame(ward = 1,type = "Sidewalk Menu",
                    location = "1264 N WOOD ST",
                    estcost = 2097.82, year = 2019)
row_2 <- data.frame(ward = 1,
                    type = "POD Camera Relocation",
                    location = "2536 W CORTLAND ST",
                    estcost = 1800,
                    year = 2019)
row_3 <- data.frame(ward = 45,
                    type = "Sidewalk Menu", 
                    location = "ON W BRYN MAWR AVE FROM N PARKSIDE AVE (5630 W) TO N MAJOR AVE (5700 W)",
                    estcost = 15256.82,
                    year = 2019)

menu_df_2005_2010$ward <- as.numeric(menu_df_2005_2010$ward)
menu_df_2016_2022 <- bind_rows(menu_df_2016_2022, row_1, row_2, row_3)
menu_df <- bind_rows(menu_df_2005_2010, menu_df_2011_2015, menu_df_2016_2022)

menu_df <- menu_df %>%
    mutate(location = ifelse(is.na(location), "Not available", location),
           est_cost = as.numeric(str_remove_all(estcost, '"')),
           ward = as.numeric(ward),
           year = as.numeric(year),
           estcost = NULL)

resurfacing_number <- nrow(menu_df[str_detect(menu_df$type, "Street Resurfac") & menu_df$year>2015,])
write(resurfacing_number, "../output/resurfacing_count_since_2015.tex")


write_csv(menu_df, "../output/menu_df.csv")

#Set of Common Words for on-menu projects
menu <- c("Streets/CDOT", "Lighting", "lighting", "Camera", "camera", "Menu", 
          "Alley", "Sidewalk", "sidewalk","Bollard", "bollard", "street", "Street", "Pavement", 
          "Pedestrian", "Guardrail", "Median",
          "Traffic", "Viaduct", " Gutter", "Curb", "Bridge", "Pothole", "Parking", "Bus",
          "Bike")
#Set of Common Words for off-menu projects
beauty <- c("Art", "Tree", "Park ", "Playground", "Graffiti", "Garden", "pool")

menu_df <- menu_df %>% 
  mutate(
    on_menu = ifelse(
      str_detect(type, regex(paste(menu, collapse = "|"), ignore_case = TRUE)), 
      "on_menu", "off_menu"),
    beauty = ifelse(str_detect(type, paste(beauty, collapse = "|")),
      "beauty", "not_beauty"))
#create dataframe of total spending by ward and year
menu_total_spending_panel <- menu_df %>%
  group_by(ward, year) %>%
  summarise(expenditures = sum(est_cost)) %>%
  mutate(
    expenditures = as.numeric(str_remove_all(expenditures, '"'))
  )

menu_panel_df_offmenu = menu_df %>%
  group_by(ward, year, on_menu) %>%
  summarise(expenditures = sum(est_cost)) %>% #next turn all expenditures to decimal numeric
  mutate(
    expenditures = as.numeric(str_remove_all(expenditures, '"'))
  ) %>%
  pivot_wider(names_from = on_menu,values_from = expenditures) %>%
  mutate(
    on_menu = ifelse(is.na(on_menu), 0, on_menu),
    off_menu = ifelse(is.na(off_menu), 0, off_menu)
  )


menu_panel_df_beauty = menu_df %>%
  group_by(ward,year, beauty) %>%
  summarise(expenditures = sum(est_cost)) %>%
  pivot_wider(names_from = beauty,values_from = expenditures) 

#merge the two dataframes
menu_panel_df = merge(menu_panel_df_offmenu, menu_panel_df_beauty,
  by = c("ward", "year"))
#assert no NAs
# menu_panel_df <- menu_panel_df %>%
#   verify(any(menu_panel_df[is.na(menu_panel_df),])==F)

write_csv(menu_panel_df, file = "../output/menu_panel_df.csv")
