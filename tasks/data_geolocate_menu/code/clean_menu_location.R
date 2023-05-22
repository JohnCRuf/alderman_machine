library(tidyverse)
library(stringr)
library(readr)
library(assertr)
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

#Step 2: Split location data into different standard formats and save to temp folder

# --------------------
# Location Data of Parks or Schools
# --------------------
school_park_df <- menu_df %>% 
    filter(str_detect(location, regex('school|park', ignore_case = T))) %>% #filter out any "st" or "av
    filter(!str_detect(location, regex('st|av|rd|blvd|Lake Park|Central Park|lincoln park w', ignore_case = T))) %>% #filter out ON FROM TO
    filter(!str_detect(location, regex('on|from|to', ignore_case = T))) %>%
    filter(!str_detect(location, regex('parkway', ignore_case = T)))

leftover_df <- menu_df %>%
    anti_join(school_park_df)

last_keyword_position <- function(x) {
  keyword_positions <- unlist(str_locate_all(tolower(x), "\\bschool\\b|\\bpark\\b|\\bcenter\\b|\\field \\b||\\bcenter\\b"))
  if (length(keyword_positions) == 0) return(as.integer(NA))
  max(keyword_positions)
}
#eliminate implicit lists in location:
school_park_df <- school_park_df %>%
  rowwise() %>%
  mutate(location_temp = strsplit(location, ",\\s*|\\s*&\\s*")) %>%
  mutate(num_elements = length(location_temp)) %>%
  unnest(location_temp) %>%
  group_by(location_temp) %>%
  mutate(est_cost =  est_cost / num_elements) %>%
  ungroup() %>%
  select(-num_elements)

#remove irrelevant information
school_park_df <- school_park_df %>%
        mutate(location_2 = str_replace_all(location_temp, "\\(.*?\\)", ""), #remove text in parentheses
               location_2 = str_replace(location_2, "(\\(TPC).*", ""), #remove TPC
               location_2 = str_replace(location_2, "(\\)TPC).*", ""), #remove typo TPC
               location_2 = str_replace(location_2, "Hih", "High"), #remove typo TPC
               location_2 = ifelse(str_detect(location_2, " Campus Park"),
                                   location_2, 
                                   str_replace(location_2, " -.*", "")),
               last_keyword_pos = map_int(location_2, last_keyword_position),
               school_park_name = map2_chr(location_2, last_keyword_pos, ~ifelse(is.na(.y), NA_character_, str_sub(.x, end = .y)))) %>% #extract text before "school" or "park"
#now we split the rows that contain multiple schools
        select(-location_2, -last_keyword_pos, -location_temp)

write.csv(school_park_df, "../temp/school_park_df.csv")
# --------------------
# Location Data of format "_ ST -- _ AV -to- _ ST"
# --------------------
double_dash_to_df<-leftover_df %>%
  filter(str_detect(location,"--")) %>%
  filter(str_detect(location,"-to-"))

leftover_df <- leftover_df %>% 
  anti_join(double_dash_to_df)

double_dash_to_df <- double_dash_to_df %>% 
        mutate(#removing chicago street coordinates that confuse geolocator API
                location_2 = str_replace_all(location, "\\(.*?\\)", ""),
                main_street = str_extract(location_2, ".*(?=--)"), 
                from_street = str_extract(location_2, "(?<=--).*(?=-to-)"), #extract text between "--" and "-to-", which is from street
                to_street = str_extract(location_2, "(?<=-to-).*$"), #extract text after "-to-", which is to street
                from_intersection = paste0(main_street, " and ", from_street), #paste to create intersections
                to_intersection = paste0(main_street, " and ", to_street)) %>%
        select(-location_2,-main_street, -from_street, -to_street)

write.csv(double_dash_to_df, "../temp/double_dash_to_df.csv")
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

generate_intersections <- function(streets){
  ns <- streets[substr(streets, 1, 1) %in% c("N", "S")]
  ew <- streets[substr(streets, 1, 1) %in% c("E", "W")]
  intersect_pairs <- expand.grid(ns, ew)
  intersect_pairs <- paste(intersect_pairs$Var1, intersect_pairs$Var2, sep=" & ")
  intersect_pairs
}

df_results<- df_with_3_ands %>%
  mutate(id = row_number(),
         location = str_split(location, " & ")) %>%
  rowwise() %>%
  mutate(location = list(generate_intersections(unlist(location)))) %>%
  unnest(location) %>%
  mutate(intersection_number = paste0("intersection_", ((row_number() - 1) %% 4) + 1)) %>%
  pivot_wider(names_from = intersection_number, values_from = location)
#add "id" column to df_with_3_ands
df_with_3_ands <- df_with_3_ands %>%
  mutate(id = row_number())
df_with_3_ands <- left_join(df_with_3_ands, df_results) %>%
  select(-id)
  

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

leftover_df <- leftover_df %>% 
  anti_join(normal_address_df)

normal_address_df <- normal_address_df  %>%
        mutate(address = str_replace_all(location, "\(.*?\)", ""))
write.csv(normal_address_df, "../temp/normal_address_df.csv")

#--------------------
# Location Data of format "ON _ AV from _ ST to _ ST"
#--------------------
from_to_df <- leftover_df %>% 
    filter(str_detect(location, regex('from', ignore_case = T))) %>%
    filter(str_detect(location, regex('to', ignore_case = T))) 

leftover_df <- leftover_df %>%
    anti_join(from_to_df)

from_to_df <- from_to_df %>%
    mutate(location_2 = str_replace_all(location, "\\(.*\\)", ""), #remove text in parentheses
           from_street = str_extract(location_2, "(?<=from ).*(?= to)"), #extract text between "from" and "to", which is from street
           to_street = str_extract(location_2, "(?<=to ).*$"),  #extract text after "to", which is to street
           ) %>%
    select(-location_2)

write.csv(from_to_df, "../temp/from_to_df.csv")

#--------------------
# Location Data of format "##-### street
#--------------------
through_address_df <- leftover_df %>% 
  filter(str_detect(location, regex('^[0-9]{2,5}-[0-9]{1,5}', ignore_case = T)))

leftover_df <- leftover_df %>% 
  anti_join(through_address_df)