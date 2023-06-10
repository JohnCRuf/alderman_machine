library(tidyverse)
library(stringr)
library(readr)
library(assertr)
menu_df <- read_csv("../input/menu_df.csv")

# Step 1: Apply manually edit locations with weird acronyms and typos
# Define lookup tables for replacements
location_replacements <- c(
  "Southwest corner of" = "",
  "DMLKD" = "S Dr. Martin Luther King Drive",
  "N--N--N--N" = "N Oakley -- N Oakley -- N Oakley -- N Oakley", # from bug in data processing
  "Diversey Ave Bridge" = "W Diversey Ave & W Logan Blvd", # nearest intersection
  "Wabansia & Leavitt New Park Construction" = "W Wabansia Ave & N Leavitt St", # nearest intersection.
  "Wabansia & Leavitt Park" = "W Wabansia Ave & N Leavitt St", 
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
  "RICHMOND ST (2932 W)" = "ON W 35TH ST FROM S FRANCISCO AV (2900 W) TO S RICHMOND ST (2932 W)",
  "Ashland & 18th, 19th, 21st, Cullerton & Cermak" = "ON S ASHLAND AVENUE FROM W 18TH ST (1800 S) TO W CERMAK RD (2200 S)",
  "Ashland & 17th, 18th, 19th, 21st, 21st Pl, Cullerton St" = "ON S ASHLAND AVENUE FROM W 17TH ST (1700 S) TO W CERMAK RD (2200 S)", # standardizing format,
  "Jackson/Oakley/Leavitt,Hoyne/Seeley" = "ON W JACKSON BLVD FROM S OAKLEY BLVD (2300 W) TO S SEELEY AV (2100 W)",
  "W) TO N KOSTNER AVE (4399 W); ON N KILDARE AVE FROM W WASHINGTON BLVD (100 N) TO W WEST END AVE (200 N); ON N KEELER AVE FROM W WASHINGTON BLVD (100 N) TO WWEST END AVE (200 N); ON N KARLOV AVE FROM W WEST END AVE (200 N) TO W MAYPOLE" = "ON N KEYSTONE AVE FROM 241 N TO W WEST END AVE (200 N); ON N KEYSTONE AVE FROM 100 N TO W WEST END AVE (200 N); ON W WEST END AVE FROM N PULASKI RD (4000 W) TO N KOSTNER AVE (4399 W); ON N KILDARE AVE FROM W WASHINGTON BLVD (100 N) TO W WEST END AVE (200 N); ON N KEELER AVE FROM W WASHINGTON BLVD (100 N) TO W WEST END AVE (200 N); ON N KARLOV AVE FROM W WEST END AVE (200 N) TO W MAYPOLE AVE (250 N); ON N KARLOV AVE FROM W WASHINGTON BLVD (100 N) TO W WEST END AVE (200 N); ON N KOLIN AVE FROM W WEST END AVE (200 N) TO W MAYPOLE AVE (240 N); ON N KEELER AVE FROM W WEST END AVE (200 N) TO W MAYPOLE AVE (250 N)", #completing incomplete statements
"ON W MAYPOLE AVE FROM N PULASKI RD (4000 W) TO N KOSTNER AVE (4400 W); ON N KARLOV AVE FROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N); ON N KEELER AVEFROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N); ON N KILDARE AVE FROM W" = "ON W MAYPOLE AVE FROM N PULASKI RD (4000 W) TO N KOSTNER AVE (4400 W); ON N KARLOV AVE FROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N); ON N KEELER AVE FROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N); ON N KILDARE AVE FROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N)", # completing incomplete statements
"MAYPOLE AVE (250 N) TO W LAKE ST (300 N) 137 S WHIPPLE ST; 147 S WHIPPLE ST; 201 S WHIPPLE ST; ON S WHIPPLE ST FROM W FIFTHAVE (100 S) TO W JACKSON BLVD (300 S)" = "137 S WHIPPLE ST; 147 S WHIPPLE ST; 201 S WHIPPLE ST; ON S WHIPPLE ST FROM W FIFTH AVE (100 S) TO W JACKSON BLVD (300 S)",
"Division/Thomas/Menard/Massasoit" = "W DIVISION ST & N MASSASOIT ST & W THOMAS ST & N MENARD AVE",
"Madison/Adams/Mason/Mayfield" = "W MADISON ST & N MAYFIELD AVE & W ADAMS ST & N MASON AVE",
"Cicero/Lamon/George/Oakdale" = "N CICERO AVE & W OAKDALE AVE & N LAMON AVE & W GEORGE ST",
"Altgeld/Deming/Lavergne/Leclaire" = "W ALTGELD ST & N LAVERGNE AVE & W DEMING PL & N LECLAIRE AVE",
"Milwaukee/Barry/Springfield/Davlin" =  "N MILWAUKEE AVE & N DAVLIN CT & N SPRINGFIELD AVE & W BARRY AVE",
"S WELLS ST & W 29 TH ST & S WENTWORTH AVE & S DAN RYAN WENTWORTH AV XR" = "S WELLS ST & W 29TH ST & S WENTWORTH AVE & 28TH ST", #nearest intersection
"ON FROM N BROADWAY (800 W) TO W DEVON AV (1216 W)" = "ON W SHERIDAN RD FROM N BROADWAY (800 W) TO W DEVON AV (1216 W)" #obvious typo based on coordinates
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
  "Blackhawk and Hermosa Parks Tree Planting 2016 Menu" = "W Belden Ave & Cicero Ave", # approximate midpoint of Blackhawk and Hermosa Parks
  "Lincoln Park Conservatory Park - Benches" = "Lincoln Park Conservatory",
  "Printers Row Park - Lighting Improvements" = "Printers Row Park",
  "Mural - Cicero Avenue viaduct adjacent to the North Branch Trail" = "N Forest Glen Ave & Cicero Ave" # closest intersection to the mural
)
# For the anti-gun violence mural, see:
# https://www.artworkarchive.com/profile/andy-bellomo/artwork/tunnel-of-blessings-neftali-reyes-jr-memorial-mural
# https://chicago.suntimes.com/news/2021/7/14/22577773/neftali-reyes-dead-humboldt-park-mural-clemente-high-baseball-gun-violence-606-trial-bloomingdale'


menu_df <- menu_df %>%
  mutate(
    # Use the lookup table for replacements in 'location'
    location = ifelse(location %in% names(location_replacements), location_replacements[location], location),
    # Use the lookup table for replacements based on 'type'
    location = ifelse(type %in% names(type_replacements), type_replacements[type], location),
    # remove "corner of" from location
    location = str_replace(location, ".*corner of", "")
  )
# remove any spacing issues
menu_df$location <- str_replace_all(menu_df$location, "([0-9])([A-Za-z])", "\\1 \\2")
# while a double space is in location, replace with single space
while (any(str_detect(menu_df$location, regex("  ", ignore_case = T)))) {
  menu_df$location <- str_replace_all(menu_df$location, "  ", " ")
}
# delete any set of characters in between "(TPC" and ")"
menu_df$location <- str_replace_all(menu_df$location, "\\(TPC.*\\)", "")
# filter out all data with est_cost of 0 and location that contains "not available"
menu_df <- menu_df %>%
  filter(est_cost != 0) %>%
  filter(!str_detect(location, regex("not available", ignore_case = T)))

# Step 2: Split location data into different standard formats and save to temp folder

# --------------------
# Location Data of Parks or Schools
# --------------------
school_park_df <- menu_df %>%
  filter(str_detect(location, regex("( school| park| field|Park;)", ignore_case = T))) %>% # filter out any "st" or "av
  filter(!str_detect(location, regex("( St| Dr.| rd| blvd| BV | av| AVE|Lake Park|Central Park|lincoln park w)", ignore_case = T))) %>% # filter out ON FROM TO
  filter(!str_detect(location, regex("( on | from | to |/)", ignore_case = T))) %>%
  filter(!str_detect(location, regex("(parkway|parkside|parking)", ignore_case = T)))

leftover_df <- menu_df %>%
  anti_join(school_park_df)

last_keyword_position <- function(x) {
  keyword_positions <- unlist(str_locate_all(tolower(x), "(\\bschool\\b|\\bpark\\b|\\bcenter\\b|\\bfield\\b)"))
  if (length(keyword_positions) == 0) {
    return(as.integer(NA))
  }
  max(keyword_positions)
}
# eliminate implicit lists in location:
school_park_df <- school_park_df %>% 
  mutate(location = str_replace_all(location, "Supera", "Supera Park")) %>%
  mutate(location = str_replace_all(location, "Swift and Pierce schools", "Swift Elementary School & Pierce Elementary School")) %>%
  mutate(location = str_replace_all(location, "Path Restoration at Lincoln Park Zoo", "Lincoln Park Zoo")) %>%
  mutate(location = str_replace_all(location, "Restoration of Door at the Alfred Lily Pool at the Lincoln Park Conserancy", "Lincoln park Conservatory")) %>% # typo
  mutate(location = str_replace_all(location, "Donoghue and Price Schools - murals", "Donoghue Elementary School and Price Elementary School")) %>%
  mutate(location = str_replace_all(location, "Piotrowsi Park - Addt'l lighting and equipment", "Piotrowski Park")) %>% # additional dash not needed
  mutate(location = ifelse(str_detect(location, "Ravenswood School"), "Ravenswood School", location)) %>% # additional dash not needed
  #iff location contains "Valley Forge Field House" rename to "Valley Forge Park"
  mutate(location = ifelse(location=="5861 N. Kostner (Sauganash Park)", "Sauganash Park", location)) %>%
  mutate(location = ifelse(location=="5100 N. Ridgeway - Eugene Field", "Eugene Field", location)) %>%
  mutate(location = ifelse(str_detect(location, "Valley Forge Field House"), "Valley Forge Park", location)) %>%
  mutate(location = ifelse(location =="Brooks Park- tennis cours surface and fence repair", "Brooks Park", location)) %>% # additional dash not needed
  mutate(location = ifelse(location == "Armitage-Larrabee Park (2009, 2008 Menu)", "Oz Park", location)) %>%
  mutate(location = ifelse(location == "Wiggly Field - (Park #425) - Schubert and Sheffield", "Wiggly Field", location)) %>%
  mutate(location = str_replace_all(location, " and ", " & ")) %>%
  rowwise() %>%
  mutate(location_temp = strsplit(location, ",\\s*|\\s*&\\s*|;\\s*")) %>%
  mutate(num_elements = length(location_temp)) %>%
  unnest(location_temp) %>%
  group_by(location_temp) %>%
  mutate(est_cost = est_cost / num_elements) %>%
  ungroup() %>%
  select(-num_elements)

# remove irrelevant information
school_park_df <- school_park_df %>%
  mutate(
    location_2 = str_replace_all(location_temp, "\\(.*?\\)", ""), # remove text in parentheses
    location_2 = str_replace_all(location_2, "\\(also .*?", ""), # remove text in parentheses
    location_2 = str_replace(location_2, "(\\(TPC).*", ""), # remove TPC
    location_2 = str_replace(location_2, "(\\)TPC).*", ""), # remove typo TPC
    location_2 = str_replace(location_2, "Hih", "High"), # remove typo 
    location_2 = ifelse(str_detect(location_2, " Campus Park"),
      location_2,
      str_replace(location_2, " -.*", "")
    ),
    last_keyword_pos = map_int(location_2, last_keyword_position),
    school_park_name = map2_chr(location_2, last_keyword_pos, ~ ifelse(is.na(.y), NA_character_, str_sub(.x, end = .y)))
  ) %>% # extract text before "school" or "park"
  # now we split the rows that contain multiple schools
  select(-location_2, -last_keyword_pos, -location_temp)

write.csv(school_park_df, "../temp/school_park_df.csv", row.names = F)
# --------------------
# Location Data of format "_ ST -- _ AV -to- _ ST"
# --------------------
double_dash_to_df <- leftover_df %>%
  filter(str_detect(location, "--")) %>%
  filter(str_detect(location, "-to-"))

leftover_df <- leftover_df %>%
  anti_join(double_dash_to_df)

double_dash_to_df <- double_dash_to_df %>%
  mutate( # removing chicago street coordinates that confuse geolocator API
    location_2 = str_replace_all(location, "\\s*\\([^\\)]*\\)\\s*\\d*", ""), #remove text in parentheses and any numbers after
    main_street = str_extract(location_2, ".*(?=--)"),
    from_street = str_extract(location_2, "(?<=--).*(?=-to-)"), # extract text between "--" and "-to-", which is from street
    to_street = str_extract(location_2, "(?<=-to-).*$"), # extract text after "-to-", which is to street
    from_intersection = paste0(main_street, " AND ", from_street), # paste to create intersections
    to_intersection = paste0(main_street, " AND ", to_street)
  ) %>%
  select(-location_2, -main_street, -from_street, -to_street)

write.csv(double_dash_to_df, "../temp/double_dash_to_df.csv", row.names = F)

# --------------------
# Location Data of format "# N/S/E/W road_1 & N/S/E/W road_2 & N/S/E/W road_3 & N/S/E/W road_4"
# --------------------
addition_df <- leftover_df %>%
  filter(str_detect(location, regex("(&|;|:|--|-and-|/|and)", ignore_case = T)))
addition_modified_df <- addition_df %>%
  mutate(location = str_replace_all(location, "(&|;|:|--|-and-|/|and)", " & "))
while (any(str_detect(addition_modified_df$location, regex("  ", ignore_case = T)))) {
  addition_modified_df$location <- str_replace_all(addition_modified_df$location, "  ", " ")
} # while a double space is in location, replace with single space
addition_modified_df$location <- str_replace_all(addition_modified_df$location, "([N|S|E|W])([1-9])", "\\1 \\2")
# remove any rows where location contains a dash of addresses (e.g. 1234-1236)
addition_modified_df <- addition_modified_df %>%
  filter(!str_detect(location, regex("[1-9]-[1-9]", ignore_case = T)))
# Remove any rows with the word "FROM" in the location
addition_modified_df <- addition_modified_df %>%
  filter(!str_detect(location, regex("from", ignore_case = T)))
# Remove any rows that have # N/S/E/W road_1 in location
addition_modified_df <- addition_modified_df %>%
  filter(!str_detect(location, regex("^[0-9]{2,5} [N|S|E|W]", ignore_case = T)))


df_with_3_ands <- addition_modified_df %>%
  filter(str_count(location, fixed("&")) == 3)

leftover_addition_df <- addition_modified_df  %>%
  anti_join(df_with_3_ands)
  
generate_intersections <- function(streets) {
  diag_streets <- c("N MILWAUKEE AV", "N MILWAUKEE AVE","S ARCHER AVE", "S BLUE ISLAND AV", "N CLYBOURN AVE")
  ns <- streets[substr(streets, 1, 1) %in% c("N", "S")]
  ew <- streets[substr(streets, 1, 1) %in% c("E", "W")]
  if (any(streets %in% diag_streets)) {
    diag_streets_used <- intersect(diag_streets, streets)
    ns <- c(ns, diag_streets_used)
    ew <- c(ew, diag_streets_used)
  }
  #remove repeat streets in ns ew
  ns <- unique(ns)
  ew <- unique(ew)
  intersect_pairs <- expand.grid(ns, ew)
  intersect_pairs <- paste(intersect_pairs$Var1, intersect_pairs$Var2, sep=" & ")
  #remove any pairs where the same street comes before and after the &
  intersect_pairs_split <- str_split_fixed(intersect_pairs, " & ", 2)
  intersect_pairs <- intersect_pairs[intersect_pairs_split[, 1] != intersect_pairs_split[, 2]]
  return(intersect_pairs)
}

df_with_3_ands <- df_with_3_ands %>%
  mutate(location = str_replace_all(location, "ST3,611", "ST"),
         location = str_replace_all(location, "ST5,906", "ST"),
         location = str_replace_all(location, "\\b(\\d+) (ST|TH|RD|ND)\\b", "\\1\\2"), # remove spaces between numbers and ST, TH, RD, ND
         location = ifelse(location == "Damen & Division & Logan Blvd & Milwaukee-multiple locations", "N DAMEN AVE & W DIVISION ST & W LOGAN BLVD & N MILWAUKEE", location)) 


df_results <- df_with_3_ands %>%
  mutate(
    id = row_number(),
    location = str_split(location, " & ")
  ) %>%
  rowwise() %>%
  mutate(location = list(generate_intersections(unlist(location)))) %>%
  unnest(location) %>%
  mutate(intersection_number = paste0("intersection_", ((row_number() - 1) %% 4) + 1)) %>%
  pivot_wider(names_from = intersection_number, values_from = location)
# add "id" column to df_with_3_ands
df_with_3_ands <- df_with_3_ands %>%
  mutate(id = row_number())
df_with_3_ands <- left_join(df_with_3_ands, df_results) %>%
  select(-id)

#change intersection_1 from list to character
df_with_3_ands <- df_with_3_ands %>%
  mutate(intersection_1 = map_chr(intersection_1, ~ paste(.x, collapse = "; "))) %>%
  mutate(intersection_2 = map_chr(intersection_2, ~ paste(.x, collapse = "; "))) %>%
  mutate(intersection_3 = map_chr(intersection_3, ~ paste(.x, collapse = "; "))) %>%
  mutate(intersection_4 = map_chr(intersection_4, ~ paste(.x, collapse = "; ")))

while (any(str_detect(df_with_3_ands$location, regex("  ", ignore_case = T)))) {
  df_with_3_ands$location <- str_replace_all(df_with_3_ands$location, "  ", " ")
} # while a double space is in location, replace with single space

#if any intersectioin is empty, replace with NA
df_with_3_ands <- df_with_3_ands %>%
  mutate(intersection_1 = ifelse(intersection_1 == "", NA_character_, intersection_1)) %>%
  mutate(intersection_2 = ifelse(intersection_2 == "", NA_character_, intersection_2)) %>%
  mutate(intersection_3 = ifelse(intersection_3 == "", NA_character_, intersection_3)) %>%
  mutate(intersection_4 = ifelse(intersection_4 == "", NA_character_, intersection_4))

write.csv(df_with_3_ands, "../temp/df_with_3_ands.csv", row.names = F)

# --------------------
# Location Data of format "# N/S/E/W road_1 & N/S/E/W road_2 & N/S/E/W road_3"
# --------------------
df_with_2_ands <- leftover_addition_df %>%
  filter(str_count(location, fixed("&")) == 2)

leftover_addition_df <- leftover_addition_df %>%
  anti_join(df_with_2_ands)

write.csv(df_with_2_ands, "../temp/df_with_2_ands.csv", row.names = F)

# --------------------
# Location Data of format "# N/S/E/W road_1 (& or ; or :) N/S/E/W road_2
# --------------------
intersection_df <- leftover_addition_df %>%
  filter(str_count(location, fixed("&")) == 1)

leftover_addition_df <- leftover_addition_df %>%
  anti_join(intersection_df)

write.csv(intersection_df, "../temp/intersection_df.csv", row.names = F)

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
  filter(str_detect(location, "^[0-9]{2,5} [N|S|E|W]"))

leftover_df <- leftover_df %>%
  anti_join(normal_address_df)

normal_address_df <- normal_address_df %>%
  mutate(address = str_replace_all(location, "\\(.*?\\)", ""))
write.csv(normal_address_df, "../temp/normal_address_df.csv", row.names = F)

#--------------------
# Location Data of format "ON _ AV from _ ST to _ ST"
#--------------------
from_to_df <- leftover_df %>%
  filter(str_detect(location, regex(" FROM ", ignore_case = T))) %>%
  filter(str_detect(location, regex(" TO ", ignore_case = T))) %>%
  filter(str_detect(location, regex("^ON ", ignore_case = T))) %>%
  filter(!str_detect(location, regex(" from .* from ", ignore_case = T))) %>%
  filter(!str_detect(location, regex(" to .* to ", ignore_case = T))) %>%
  filter(!str_detect(location, "Relocate"))

leftover_df <- leftover_df %>%
  anti_join(from_to_df)

from_to_df <- from_to_df %>%
  mutate(
    main_street = str_extract(location, "(?i)(?<=on).*(?= from)"),
    from_street = str_extract(location, "(?i)(?<=from).*(?= to)"), # extract text between "from" and "to", which is from street
    to_street = str_extract(location, "(?i)(?<=to ).*$"), # extract text after "to", which is to street
  ) %>% # if from_street contains "Dead End" replace with just the numbers in the string
  mutate(from_street = ifelse(str_detect(from_street, "Dead End"),
                              str_extract(from_street, "(?<=\\()[^()]+(?=\\))"),
                              from_street),
         to_street = ifelse(str_detect(to_street, "Dead End"),
                            str_extract(to_street, "(?<=\\()[^()]+(?=\\))"),
                            to_street)) %>%
  mutate( # remove all characters between ( and )
    from_street = str_replace_all(from_street, "\\(.*?\\)", ""),
    to_street = str_replace_all(to_street, "\\(.*?\\)", "")
  ) %>%
  mutate(main_street = case_when( # add ST and similar to end of main_street if it doesn't already exist
    str_detect(main_street, "[0-9]+$") ~ paste0("E ", main_street,
      case_when(
        str_detect(main_street, "1$") & !str_detect(main_street, "11$") ~ "ST ST",
        str_detect(main_street, "2$") & !str_detect(main_street, "12$") ~ "ND ST",
        str_detect(main_street, "3$") & !str_detect(main_street, "13$") ~ "RD ST",
        TRUE ~ "th ST"
      )
    ),
    TRUE ~ main_street
  )) %>% #remove any spaces in front of main_street, from_street, and to_street
  mutate(main_street = str_replace_all(main_street, "^\\s+", ""),
         from_street = str_replace_all(from_street, "^\\s+", ""),
         to_street = str_replace_all(to_street, "^\\s+", "")) %>%
  mutate(from_intersection = ifelse(str_detect(from_street, "^[0-9]+ [NSEW]"),
                                     paste(str_extract(from_street, "[0-9]+"), main_street),
                                     paste(main_street, "and", from_street))) %>%
  mutate(to_intersection = ifelse(str_detect(to_street, "^[0-9]+ [NSEW]"),
                                     paste(str_extract(to_street, "[0-9]+"), main_street),
                                     paste(main_street, "and", to_street)))
#print from_street of row 1 in from_to_df
print(from_to_df$from_street[1])

write.csv(from_to_df, "../temp/from_to_df.csv", row.names = F)

#--------------------
# Location Data of format "##-### street
#--------------------
through_address_df <- leftover_df %>%
  filter(str_detect(location, regex("^[0-9]{2,5}-[0-9]{1,5}", ignore_case = T)))

leftover_df <- leftover_df %>%
  anti_join(through_address_df)

write.csv(through_address_df, "../temp/through_address_df.csv", row.names = F)

#--------------------
# Location data of format ON _ FROM _ TO _ ; ON _ FROM _ TO _, ...
#--------------------
on_from_to_multiple_df <- leftover_df %>%
  filter(str_detect(location, regex("ON", ignore_case = T))) %>%
  filter(str_detect(location, regex("FROM", ignore_case = T))) %>%
  filter(str_detect(location, regex("TO", ignore_case = T))) 

leftover_df <- leftover_df %>%
  anti_join(on_from_to_multiple_df)

write.csv(on_from_to_multiple_df, "../temp/on_from_to_multiple_df.csv", row.names = F)

# write leftover_df to csv
write.csv(leftover_df, "../temp/leftover_df.csv", row.names = F)