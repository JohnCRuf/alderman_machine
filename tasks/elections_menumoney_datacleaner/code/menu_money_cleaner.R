#John Ruf 05/2022
#This script is meant to clean the menu money df

library(tidyverse)
library(stringr)
library(readr)
library("rstudioapi") 
setwd(dirname(getActiveDocumentContext()$path)) 
menu_df<-read_csv("../input/menu.csv")
menu=c('Streets/CDOT','Lighting','Cameras')
beauty=c('Arts', 'Trees, Gardens', 'Parks', 'Misc', 'Other')
menu_df<-menu_df %>%
  mutate(
    est_cost=gsub("(5700 W)","",est_cost, fixed=TRUE),
    on_menu=ifelse(category %in% menu,"on_menu","off_menu"),
    beauty=ifelse(category %in% beauty, "beauty","non-Beauty"),
    est_cost=ifelse(desc %in% "Shabbona Park","$275,000.00",est_cost)
  )

#Fixing ward 49 year 2018

menu_w49_y2018<-menu_df%>%
  filter(year==2018, ward==49)%>%
  mutate(mergers=str_extract(location,"\\$(.*)"),
         est_cost=ifelse(is.na(mergers),est_cost,paste0(mergers,est_cost)),
         mergers=NULL)

menu_df<-menu_df %>%
  filter(year!=2018 | ward!=49)

menu_df<-rbind(menu_df, menu_w49_y2018) %>%
  mutate(est_cost=gsub('\\$',"",est_cost),
         est_cost=gsub(",","",est_cost),
         est_cost=as.numeric(est_cost),
         est_cost=ifelse(is.na(est_cost),0,est_cost))

menu_panel_df_offmenu=menu_df %>%
  group_by(ward,year,on_menu) %>%
  summarise(expenditures=sum(est_cost)) %>%
  pivot_wider(names_from = on_menu,values_from = expenditures) %>%
  mutate(off_menu=ifelse(is.na(off_menu),0,off_menu))

menu_panel_df_beauty=menu_df %>%
  group_by(ward,year,beauty) %>%
  summarise(expenditures=sum(est_cost)) %>%
  pivot_wider(names_from = beauty,values_from = expenditures) %>%
  mutate(beauty=ifelse(is.na(beauty),0,beauty))

write_csv(menu_panel_df_offmenu, file="../output/menu_panel_df.csv")
write_csv(menu_panel_df_beauty, file="../output/menu_panel_df_beauty.csv")


