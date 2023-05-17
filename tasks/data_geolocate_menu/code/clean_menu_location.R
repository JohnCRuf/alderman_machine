library(tidyverse)
library(stringr)
library(readr)
library(assertr)
source("location_cleaning_fns.R")
menu_df<-read_csv("../input/menu_df.csv")

#Step 1: Apply manually edit locations with weird acronyms and typos
# Define lookup tables for replacements
location_replacements <- c(
  "Southwest corner of" = "",
  "DMLKD" = "Dr. Martin Luther King Drive",
  "N--N--N--N" = "N Oakley -- N Oakley -- N Oakley -- N Oakley",
  "Diversey Ave Bridge" = "W Diversey Ave & W Logan Blvd",
  "Wabansia & Leavitt New Park Construction" = "W Wabansia Ave & N Leavitt St",
  "Dean Park Basketball Court Ren." = "Dean Park",
  "Across Damen at Erie" = "N Damen Ave & W Erie St",
  "Fence at City-owned lot at 1421 N. Artesian" = "1421 N Artesian Ave",
  "Francis Pl & Stave" = "N Stave St & W Francis Pl",
  "W. Hoyne/ between Chicago Av. & first alley to the south" = "W Hoyne Ave & W Chicago Ave",
  "$123880.00" = "MONTROSE & CLARENDON; SE BROADWAY & W WILSON AVE; N HAZEL ST & W MONTROSE AVE; N BROADWAY & W SUNNYSIDE AVE",
  "1-290 overpass/ Loomis" = "S Loomis St & W Van Buren St",
  "1-290 overpass/Ashland" = "S Ashland Ave & W Van Buren St",
  "& E 84TH ST:S BUFFALO AVE & E 92ND ST:8437 S COMMERCIAL AVE:8404 S BAKER AVE:2938 E 89TH ST" = "S COMMERCIAL AVE & E 83RD ST:8850 S EXCHANGE AVE:8390 S BOND AVE:S BUFFALO AVE & E 84TH ST:11741 S TORRENCE AVE:S BURLEY AVE & E 84TH ST:S BUFFALO AVE & E 92ND ST:8437 S COMMERCIAL AVE:8404 S BAKER AVE:2938 E 89TH ST",
  "(1830 S)" = "ON S LOOMIS ST FROM W 18TH ST (1800 S) TO W 18TH PL (1830 S)",
  "(3132 W)" = "ON W 26TH ST FROM S ALBANY AV (3100 W) TO S TROY ST (3132 W)",
  "RICHMOND ST (2932 W)" = "ON W 35TH ST FROM S FRANCISCO AV (2900 W) TO S RICHMOND ST (2932 W)"
)

type_replacements <- c(
  "Lawler Park Turf Field" = "Lawler Park",
  "Loyola Park Exercise Equipment" = "Loyola Park",
  "Drinking Fountains at Mather; Green Briar" = "Green Briar Park",
  "Wentworth Park - Athletic Field Lighting - 2017 and 2018 Menu" = "Wentworth Park",
  "Drake Gardens Community Garden w/ NeighborSpace" = "Drake Garden",
  "Independence Park - Water feature/playground" = "Independence Park",
  "Lawndale Triangle Community Garden" = "Lawndale Triangle Community Garden",
  "Montrose Beach Fence for Dog Area" = "Montrose Beach",
  "Anti-Gun Violence Mural w/ DCASE" = "1800 N. Humboldt Blvd",
  "Blackhawk and Hermosa Parks Tree Planting 2016 Menu" = "W Belden Ave & Cicero Ave", #approximate midpoint of Blackhawk and Hermosa Parks
  "Lincoln Park Conservatory Park - Benches" = "Lincoln Park Conservatory",
  "Printers Row Park - Lighting Improvements" = "Printers Row Park",
  "Mural - Cicero Avenue viaduct adjacent to the North Branch Trail" = "N Forest Glen Ave & Cicero Ave" #closest intersection to the mural
)
#For the anti-gun violence mural, see: 
#https://www.artworkarchive.com/profile/andy-bellomo/artwork/tunnel-of-blessings-neftali-reyes-jr-memorial-mural
#https://chicago.suntimes.com/news/2021/7/14/22577773/neftali-reyes-dead-humboldt-park-mural-clemente-high-baseball-gun-violence-606-trial-bloomingdale'


menu_df <- menu_df %>%
  mutate(
    # Use the lookup table for replacements in 'location'
    location = str_replace_all(location, location_replacements),
    # Use the lookup table for replacements based on 'type'
    location = ifelse(type %in% names(type_replacements), type_replacements[type], location),
    #remove "corner of" from location
    location = str_replace(location, ".*corner of", "")
  )
#remove any spacing issues
menu_df$location <- str_replace_all(menu_df$location, "([0-9])([A-Za-z])", "\\1 \\2")
#while a double space is in location, replace with single space
while (any(str_detect(menu_df$location, regex('  ', ignore_case = T)))) {
  menu_df$location <- str_replace_all(menu_df$location, "  ", " ")
}
#delete any set of characters in between "(TPC" and ")"
menu_df$location <- str_replace_all(menu_df$location, "\\(TPC.*\\)", "")
#filter out all data with est_cost of 0 and location that contains "not available"
menu_df <- menu_df %>%
  filter(est_cost != 0) %>%
  filter(!str_detect(location, regex('not available', ignore_case = T)))

#Step 2: Split location data into different standard formats

# --------------------
# Location Data of Parks or Schools
# --------------------
school_park_df <- menu_df %>% 
    filter(str_detect(location, regex('school|park', ignore_case = T))) %>% #filter out any "st" or "av
    filter(!str_detect(location, regex('st|av|rd|blvd|Lake Park|Central Park|lincoln park w', ignore_case = T))) %>% #fuilter out ON FROM TO
    filter(!str_detect(location, regex('on|from|to', ignore_case = T))) %>%
    filter(!str_detect(location, regex('parkway', ignore_case = T)))
leftover_df <- menu_df %>%
    anti_join(school_park_df)

# --------------------
# Location Data of format "_ ST -- _ AV -to- _ ST"
# --------------------
double_dash_to_df<-leftover_df %>%
  filter(str_detect(location,"--")) %>%
  filter(str_detect(location,"-to-"))

leftover_df <- leftover_df %>% 
  anti_join(double_dash_to_df)
#double_dash_to_df <- double_dash_to_clean(double_dash_to_df)
# --------------------
# Location Data of format "# N/S/E/W road_1 & N/S/E/W road_2 & N/S/E/W road_3 & N/S/E/W road_4"
# --------------------
addition_df <- leftover_df  %>%
    filter(str_detect(location, regex('&|;|:|--|-and-|/|and', ignore_case = T)))
addition_modified_df <- addition_df %>%
    mutate(location = str_replace_all(location, ";|:|--", " & "))
while (any(str_detect(addition_modified_df$location, regex('  ', ignore_case = T)))) {
  addition_modified_df$location <- str_replace_all(addition_modified_df$location, "  ", " ")
}

  
df_with_3_ands <- addition_modified_df %>%
  filter(str_count(location, fixed("&")) == 3)

leftover_addition_df <- addition_modified_df %>%
  anti_join(df_with_3_ands)

#df_with_3_ands <- triple_and_clean(df_with_3_ands)
# --------------------
# Location Data of format "# N/S/E/W road_1 & N/S/E/W road_2 & N/S/E/W road_3"
# --------------------
df_with_2_ands <- leftover_addition_df %>%
  filter(str_count(location, fixed("&")) == 2)

leftover_addition_df <- leftover_addition_df %>%
  anti_join(df_with_2_ands)


# --------------------
# Location Data of format "# N/S/E/W road_1 (& or ; or :) N/S/E/W road_2
# --------------------
intersection_df <- leftover_addition_df %>%
  filter(str_count(location, fixed("&")) == 1)

leftover_addition_df <- leftover_addition_df %>%
  anti_join(intersection_df)

# --------------------
# Location Data of format with multiple "&'s
# --------------------
df_with_mult_ands <- addition_modified_df %>%
  filter(str_count(location, fixed("&")) > 3)

leftover_addition_df <- leftover_addition_df %>%
  anti_join(df_with_mult_ands)

leftover_df <- leftover_df %>%
  anti_join(addition_df)
rm(leftover_addition_df, addition_df, addition_modified_df)
# --------------------
# Location Data of format "# N/S/E/W _ ST"
# --------------------
normal_address_df <- leftover_df %>% 
  filter(!str_detect(location, "&|;|:|--|-and-|/")) %>%
  filter(str_detect(location,"^[0-9]{2,5} [N|S|E|W]"))
normal_address_df <- normal_address_clean(normal_address_df)

leftover_df <- leftover_df %>% 
  anti_join(normal_address_df)

#--------------------
# Location Data of format "ON _ AV from _ ST to _ ST"
#--------------------
from_to_df <- leftover_df %>% 
    filter(str_detect(location, regex('from', ignore_case = T))) %>%
    filter(str_detect(location, regex('to', ignore_case = T))) 

leftover_df <- leftover_df %>%
    anti_join(from_to_df)

ℓₖₙ_realized = ℓₖₙ ./ δ̄

#--------------------
# Location Data of format "##-### street
#--------------------
through_address_df <- leftover_df %>% 
  filter(str_detect(location, regex('^[0-9]{2,5}-[0-9]{1,5}', ignore_case = T)))

leftover_df <- leftover_df %>% 
  anti_join(through_address_df)