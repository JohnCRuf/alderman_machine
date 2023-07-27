library(tidyverse)
library(stringr)
library(stringi)
library(gsubfn)
library(readr)
library(assertthat)
source("intersection_generation_fn.R")
source("keyword_fn.R")
source("ordinal_indicator_fn.R")
menu_df <- read_csv("../input/menu_df.csv")

# Step 1: Apply manually edit locations with weird acronyms and typos
# Define lookup tables for replacements
location_replacements <- c(
  "N--N--N--N" = "N Oakley -- N Oakley -- N Oakley -- N Oakley", # from bug in data processing
  "Diversey Ave Bridge" = "W Diversey Ave & W Logan Blvd", # nearest intersection
  "Wabansia & Leavitt New Park Construction" = "W Wabansia Ave & N Leavitt St", # nearest intersection.
  "Wabansia & Leavitt Park" = "W Wabansia Ave & N Leavitt St", 
  "Dean Park Basketball Court Ren." = "Dean Park",
  "Across Damen at Erie" = "N Damen Ave & W Erie St",
  "Fence at City-owned lot at 1421 N. Artesian" = "1421 N Artesian Ave",
  "Francis Pl & Stave" = "N Stave St & W Francis Pl",
  "W. Hoyne/ between Chicago Av. & first alley to the south" = "W Hoyne Ave & W Chicago Ave",
  "$123880.00" = "MONTROSE & CLARENDON; SE BROADWAY & W WILSON AVE; N HAZEL ST & W MONTROSE AVE; N BROADWAY & W SUNNYSIDE AVE", # from bug in data processing
  "1-290 overpass/ Loomis" = "S Loomis St & W Van Buren St",
  "1-290 overpass/Ashland" = "S Ashland Ave & W Van Buren St",
  "& E 84TH ST:S BUFFALO AVE & E 92ND ST:8437 S COMMERCIAL AVE:8404 S BAKER AVE:2938 E 89TH ST" = "S COMMERCIAL AVE & E 83RD ST:8850 S EXCHANGE AVE:8390 S BOND AVE:S BUFFALO AVE & E 84TH ST:11741 S TORRENCE AVE:S BURLEY AVE & E 84TH ST:S BUFFALO AVE & E 92ND ST:8437 S COMMERCIAL AVE:8404 S BAKER AVE:2938 E 89TH ST",
  "(1830 S)" = "ON S LOOMIS ST FROM W 18TH ST (1800 S) TO W 18TH PL (1830 S)",
  "(3132 W)" = "ON W 26TH ST FROM S ALBANY AV (3100 W) TO S TROY ST (3132 W)",
  "RICHMOND ST (2932 W)" = "ON W 35TH ST FROM S FRANCISCO AV (2900 W) TO S RICHMOND ST (2932 W)",
  "Ashland & 18th, 19th, 21st, Cullerton & Cermak" = "ON S ASHLAND AVENUE FROM W 18TH ST (1800 S) TO W CERMAK RD (2200 S)",
  "Ashland & 17th, 18th, 19th, 21st, 21st Pl, Cullerton St" = "ON S ASHLAND AVENUE FROM W 17TH ST (1700 S) TO W CERMAK RD (2200 S)", # standardizing format,
  "Jackson/Oakley/Leavitt,Hoyne/Seeley" = "ON W JACKSON BLVD FROM S OAKLEY BLVD (2300 W) TO S SEELEY AV (2100 W)",
  "Jackson/Adams/Laflin/Ashland" = "W JACKSON BLVD & S ASHLAND AVE & W ADAMS ST & S LAFLIN ST",
  "W) TO N KOSTNER AVE (4399 W); ON N KILDARE AVE FROM W WASHINGTON BLVD (100 N) TO W WEST END AVE (200 N); ON N KEELER AVE FROM W WASHINGTON BLVD (100 N) TO WWEST END AVE (200 N); ON N KARLOV AVE FROM W WEST END AVE (200 N) TO W MAYPOLE" = "ON N KEYSTONE AVE FROM 241 N TO W WEST END AVE (200 N); ON N KEYSTONE AVE FROM 100 N TO W WEST END AVE (200 N); ON W WEST END AVE FROM N PULASKI RD (4000 W) TO N KOSTNER AVE (4399 W); ON N KILDARE AVE FROM W WASHINGTON BLVD (100 N) TO W WEST END AVE (200 N); ON N KEELER AVE FROM W WASHINGTON BLVD (100 N) TO W WEST END AVE (200 N); ON N KARLOV AVE FROM W WEST END AVE (200 N) TO W MAYPOLE AVE (250 N); ON N KARLOV AVE FROM W WASHINGTON BLVD (100 N) TO W WEST END AVE (200 N); ON N KOLIN AVE FROM W WEST END AVE (200 N) TO W MAYPOLE AVE (240 N); ON N KEELER AVE FROM W WEST END AVE (200 N) TO W MAYPOLE AVE (250 N)", #completing incomplete statements
"ON W MAYPOLE AVE FROM N PULASKI RD (4000 W) TO N KOSTNER AVE (4400 W); ON N KARLOV AVE FROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N); ON N KEELER AVEFROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N); ON N KILDARE AVE FROM W" = "ON W MAYPOLE AVE FROM N PULASKI RD (4000 W) TO N KOSTNER AVE (4400 W); ON N KARLOV AVE FROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N); ON N KEELER AVE FROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N); ON N KILDARE AVE FROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N)", # completing incomplete statements
"MAYPOLE AVE (250 N) TO W LAKE ST (300 N) 137 S WHIPPLE ST; 147 S WHIPPLE ST; 201 S WHIPPLE ST; ON S WHIPPLE ST FROM W FIFTHAVE (100 S) TO W JACKSON BLVD (300 S)" = "137 S WHIPPLE ST; 147 S WHIPPLE ST; 201 S WHIPPLE ST; ON S WHIPPLE ST FROM W FIFTH AVE (100 S) TO W JACKSON BLVD (300 S)",
"Division/Thomas/Menard/Massasoit" = "W DIVISION ST & N MASSASOIT ST & W THOMAS ST & N MENARD AVE",
"Madison/Adams/Mason/Mayfield" = "W MADISON ST & N MAYFIELD AVE & W ADAMS ST & N MASON AVE",
"Cicero/Lamon/George/Oakdale" = "N CICERO AVE & W OAKDALE AVE & N LAMON AVE & W GEORGE ST",
"Altgeld/Deming/Lavergne/Leclaire" = "W ALTGELD ST & N LAVERGNE AVE & W DEMING PL & N LECLAIRE AVE",
"Milwaukee/Barry/Springfield/Davlin" =  "N MILWAUKEE AVE & N DAVLIN CT & N SPRINGFIELD AVE & W BARRY AVE",
"S WELLS ST & W 29TH ST & S WENTWORTH AVE & S DAN RYAN WENTWORTH AV XR" = "S WELLS ST & W 29TH ST & S WENTWORTH AVE & 28TH ST", #nearest intersection
"ON FROM N BROADWAY (800 W) TO W DEVON AV (1216 W)" = "ON W SHERIDAN RD FROM N BROADWAY (800 W) TO W DEVON AV (1216 W)", #obvious typo based on coordinates
"1501 W. Adams & about 1541-1600" = "1501-1600 W Adams ST", # appropriate format
"AVE:6527 S MARSHFIELD AVE:6531 S MARSHFIELD AVE:6542 S MARSHFIELD AVE" = "6510-6542 S MARSHFIELD AVE", # appropriate format
"Rhodes & 67th & 67th & S. Chicago" = "S RHODES AVE & E 67TH ST & E 67TH ST & S SOUTH CHICAGO AVE", 
"19th & Allport; 17th & Loomis" = "S Loomis St & W 17th St, S Allport St & W 19th St", 
"18th St / Blue Island & Loomis" = "18th ST & S LOOMIS ST", #triple intersection
"18th ST/ 18th PL/Hoyne/Leavitt" = "W 18th ST & S HOYNE AVE & S LEAVITT ST & W 18th PL", # box of 4 intersections
"18th Pl/18th St/Hoyne/Leavitt" = "W 18th ST & S HOYNE AVE & S LEAVITT ST & W 18th PL", # box of 4 intersections
"Lockwood & Palmer; LaVergine & Chicago" = "N Lockwood Ave & W Palmer St, N Lavergne Ave & W Chicago Ave", # 2 intersections
"Irving Park Rd/Keeler & I 90/94" = "IRVING PARK RD & N KEELER AVE", #nearest intersection
"Albion / Clark / Ashland - Alley Return" = "ON W ALBION AVE FROM N CLARK ST (1000 W) TO N ASHLAND AVE (1600 W)", # appropriate format
"Hobart/Hurlbut/New Hampshire/Newcastle" = "W HOBART AVE & N HURLBUT ST & W NEW HAMPSHIRE ST & N NEWCASTLE AVE", # box of 4 intersections
"Dearborn/Chesnut and Mies Der Rohde & Pearson" = "N DEARBORN ST & W CHESTNUT ST, N MIES VAN DER ROHE WAY & E PEARSON ST", # 2 intersections
"Maplewood / Diversey/ Chicago & Northern Railroad" = "ON W DIVERSEY AVE FROM N MAPLEWOOD AVE TO N WOLCOTT AVE", # Northern Railroad refers to north freight railroad on diversey.
"Clinton / Kinzie / Washington / Dearborn" = "NORTH CLINTON STREET & WEST KINZIE STREET & WEST WASHINGTON STREET & NORTH DEARBORN STREET", # box of 4 intersections
"Grand & Illinois between Orleans & LSD" = "ON W GRAND AVE FROM N ORLEANS ST TO N LAKE SHORE DR", # appropriate format
"N Greenview/N Ashland/N Byron St" = "ON W BYRON ST FROM N GREENVIEW AVE TO N ASHLAND AVE", # appropriate format
"IBeach access ramp & boardwalk-Jarvis & Lake &" = "MARION MAHONY GRIFFIN BEACH PARK", # nearest park, beach access map visible on google maps
"78th/79th/Ridgeland/Creiger" = "E 78th ST & S RIDGELAND AVE & E 79th ST & S CREIGER AVE", # box of 4 intersections
"Rogers/Kercheval to Caldwell/Kercheval/Kerbs to Rogers" = "ON N ROGERS AVE FROM N KERSCHEVAL AVE TO N CALDWELL AV ; ON N KERCHEVAL FROM N KERBS TO N ROGERS", # appropriate format
"Wabash-Ohio & Onatrio;Dearborn Randolph & Lake" = "ON N WABASH AVE FROM E OHIO ST TO E ONTARIO ST; ON N DEARBORN ST FROM W RANDOLPH ST TO W LAKE ST", # 2 stretches of road
"8001 Francisco" = "8001 S Francisco Ave",
"Valley Forge" = "Valley Forge Park",
"Armitage,Clark,Cortland.Fullerton,Halsted" = "W ARMITAGE AVE & N CLARK ST & W CORTLAND ST & N HALSTED ST & W FULLERTON AVE",
"Mural - Cicero Avenue viaduct adjacent to the North Branch Trail" = "N Forest Glen Ave & Cicero Ave", # closest intersection to the mural\
"2728", "2728-2890 S State", # from bug in data processing
"S SHORE DR 79TH TO 80TH" = "ON S SHORE DR FROM E 79TH ST TO E 80TH ST",
"Luella E. 82nd to E. 83rd" = "ON S LUELLA AVE FROM E 82ND ST TO E 83RD ST",
"E107 Ewing to 1 st alley east" = "ON E 107TH ST FROM S EWING AVE TO S AVE J",
"100th St / from Ewing / Indianapolis" = "ON E 100TH ST FROM S EWING AVE TO S INDIANAPOLIS AVE",
"Baltimore / from Brainard (13460 Baltimore)" = "13460 S Baltimore Ave",
"13245 S GREEN BAY AVE:ON S GREEN BAY AVE FROM E 132ND ST" = "13245 S GREEN BAY AVE",
"Jackson Blvd to Kilpatrick Av" = "Jackson Blvd & Kilpatrick Ave",
"Mural at Sauganash Tr on Peterson Av" = "Saughnash Park", # nearest park
"47th Street Viaduct- mural" = "47th and S Lake Park Ave", # nearest intersection
"Viaduct Art Panel (Hyde Park) at 51st St." = "E Hyde Park Blvd & S Lake Park Ave", # nearest intersection
"Dog Park across from Clarendon Park" = "Clarendon Dog Friendly Area",
"Division, 2400 - 3200 Festival Lights" = "ON W DIVISION ST FROM N WESTERN AVE TO N KEDZIE AVE", #appropriate intersections for 2400 and 3200 addresses
"ST (8400 S)" = "ON S WOLCOTT AVE FROM W 83RD ST (8300 S) TO W 84TH ST (8400 S)",
"ROSCOE ST (3400 N)" = "ON N OCONTO AVE FROM W SCHOOL ST (3300 N) TO W ROSCOE ST (3400 N)",
"AUGUSTA BLVD (1000 N)" = "ON N ST LOUIS AVE FROM W IOWA ST (900 N) TO W AUGUSTA BLVD (1000 N)",
"NEWCASTLE AVE (6800 W)" = "ON W RASCHER AVE FROM W TALCOTT AVE (6740 W) TO N NEWCASTLE AVE (6800 W)",
"HAMILTON AVE (2130 W)" = "ON W CORNELIA AVE FROM N HOYNE AVE (2100 W) TO N HAMILTON AVE (2130 W)",
"S MORGAN ST (1000 W)" = "ON W MAXWELL ST FROM S BLUE ISLAND AVE (1133 W) TO S MORGAN ST (1000 W)",
"KILDARE AV (4300 W)" = "ON W TAYLOR ST FROM S KEELER AV (4200 W) TO S KILDARE AV (4300 W)",
"W AGATITE AVE (4430 N)" = "ON N KENTON AVE FROM W SUNNYSIDE AVE (4500 N) TO W AGATITE AVE (4430 N)",
"RIDGE AV (5970 N)" = "ON N PAULINA ST FROM W THORNDALE AV (5840 N) TO W RIDGE AV (5970 N)",  
"PALATINE AV (6243 N)" = "ON N NEWCASTLE AVE FROM W RAVEN ST (6142 N) TO W PALATINE AV (6243 N)",
"N BROADWAY\n W ARDMORE AV (5800 N)" = "N BROADWAY & W ARDMORE AVE",
"Pratt from 1000 west to Ridge" = "ON W PRATT BLVD FROM 1000 W TO N RIDGE BLVD",
"43rd to 47th along Drexel Blvd" = "ON S DREXEL BLVD FROM E 43RD ST TO E 47TH ST",
"18th St at Wolcott" = "W 18th ST & S WOLCOTT AVE",
"69TH ST 224 E 86TH ST" = "224 E 86TH ST", #borrowed from previous entry
"PINE GROVE AVE" = "N BROADWAY & W LELAND AVE; W WILSON AVE & N CLARENDON AVE; W ADDISON ST & N PINE GROVE AVE",
"2-100 E CHICAGO AVE" = "ON E CHICAGO AVE FROM N STATE ST TO N RUSH ST", #closest intersections
"s 176 E CHESTNUT ST" = "176 E CHESTNUT ST",
"r 2861 N CLARK ST" = "2861 N CLARK ST", 
"2225 - 2225 - SWABASHAVE" = "ON S WABASH AVE FROM E 22ND ST TO E 23RD ST",
"Street Resurfacing - N. Sheridan (Devon)" = "N SHERIDAN RD & W DEVON AVE",
"2728" = "ON S STATE ST FROM 2728 S TO 2890 S",
"Chicago Ave @ Hoyne Ave. (cost shared with 1st ward)" = "Chicago Ave & Hoyne Ave",
"Chicago Ave @ Hoyne Ave. (cost shared with 32nd ward)" = "Chicago Ave & Hoyne Ave",
"Chicago Ave. at Hoyne Ave. (Crosswalk)" = "Chicago Ave & Hoyne Ave",
"Clark St at Germania Pl" = "N Clark St & W Germania Pl",
"E107 Ewing to 1 st alley east" = "ON E 107TH ST FROM S EWING AVE TO S AVE J", #closest intersection
"63rd St (Wentworth - State)" = "ON W 63RD ST FROM S WENTWORTH AVE TO S STATE ST",
"Division St., 2400 - 3200 Festival Lights" = "ON W DIVISION ST FROM N WESTERN AVE TO N KEDZIE AVE",
"Altgeld-Fullerton-Springfield-Harding" = "W ALTGELD ST & N SPRINGFIELD AVE & W FULLERTON AVE & N HARDING AVE",
"Pylmouth/Roosevelt N&S of viaduct" = "Plymouth Pedestrian Tunnel",
"Pulaski and Argyle - SE Corner" = "N Pulaski Rd & W Argyle St",
"Randolph & Harbor Dr." = "E Randolph St & N Harbor Dr",
"Paulina and Schubert" = "N Paulina St & W Schubert Ave",
"Paulina - Moorman to Division" = "ON N PAULINA ST FROM W MOORMAN ST TO W DIVISION ST",
"Path Restoration at Lincoln Park Zoo" = "Lincoln Park Zoo",
"Parkside and Wellington" = "N Parkside Ave & W Wellington Ave",
"Oakley and Race" =  "N OAKLEY BLVD & W RACE AVE",
"Oak St./Michigan Av/ Rush St." = "ON E OAK ST FROM N MICHIGAN AVE TO N RUSH ST",
"Rhodes & 67 th/ 67 th/S. Chicago" = "ON S RHODES AVE FROM E 67TH ST TO S CHICAAGO AVE",
"Richmond & Walton" = "N RICHMOND ST & W WALTON ST",
"Roscoe St & Campbell Ave between Belmont Ave & Wes" = "W ROSCOE ST & N CAMPBELL AVE",
"Throop/18" = "S THROOP ST & W 18TH ST",
"Touhy at RR (1600 W)" = "1600 W Touhy Ave",
"SW corner of Argyle and N. Troy" = "N Troy St & W Argyle St",
"Sacremento/Washington" = "N SACRAMENTO BLVD & W WASHINGTON BLVD",
"Seminary & Maud" = "N SEMINARY AVE & W MAUD AVE",
"Sheil Park - 3505 N. Southport" = "3505 N Southport Ave",
"Sherdian-Belmont to Diversey" = "ON N SHERIDAN RD FROM W BELMONT AVE TO W DIVERSEY PKWY",
"Sheridan Rd @ Castlewood Terrace" = "N Sheridan Rd & W Castlewood Ter",
"Site Acquisition for community garden - 4228 W. Ogden" = "4228 W Ogden Ave",
"Southwest corner of DMLKD & 31 st S" = "ON S DR MARTIN LUTHER KING JR DR FROM E 31ST ST TO E 31ST ST",
"Springfield & Hirsch" = "N SPRINGFIELD AVE & W HIRSCH ST",
"Springfield and Schubert" = "N SPRINGFIELD AVE & W SCHUBERT AVE",
"St. Louis & McLean (SW corner)" = "N ST LOUIS AVE & W MCLEAN AVE",
"St. Louis and Wabansia (SW corner)" = "N ST LOUIS AVE & W WABANSIA AVE",
"State & Pearson" = "N STATE ST & E PEARSON ST",
"State St. / North Ave. / Astor St." = "ON E NORTH BLVD FROM N STATE PKWY TO N ASTOR ST", #obvious typo, Astor street doesn't intersect with State st. 
"State/North/Astor" = "ON E NORTH BLVD FROM N STATE PKWY TO N ASTOR ST",
"Street Sign at 87 th & Damen/North Beverly Civic Assoc" = "E 87th ST & S Damen Ave",
"THORNDALE AVE & N KENMORE AVE 6149 N GLENWOOD AVE" = "THORNDALE AVE & N KENMORE AVE",
"Taylor Street-Western to Ogden" = "ON W TAYLOR ST FROM S WESTERN AVE TO W OGDEN AVE",
"Taylor-Western to Ogden" = "ON W TAYLOR ST FROM S WESTERN AVE TO W OGDEN AVE",
"Viaduct art Panel at 53 rd and 55 th St" = "ON S LAKE PARK AVE FROM E 53RD ST TO E 55TH ST", #close enough
"Victoria/Spaulding & 6123 Ravenswood" = "6123 N Ravenswood Ave",
"Von Humboldt/Duprey - 2620 W. Hirsch St." = "2620 W Hirsch St",
"W. 71 st St. / S. Ada" = "W 71st ST & S ADA ST",
"W. Lawrence and North Troy" = "W LAWRENCE AVE & N TROY ST",
"W. Wisconsin / Mohawk / Larrabee" = "ON W WISCONSIN ST FROM N MOHAWK ST TO N LARRABEE ST",
"W57 ST/S Francisco-S Richmond" = "ON W 57TH ST FROM S FRANCISCO AVE TO S RICHMOND ST",
"WPA-33 rd/Racine to Throop"  = " ON W 33RD ST FROM S RACINE AVE TO S THROOP ST",
"Wabansia / Hoyne" = "W WABANSIA AVE & N HOYNE AVE",
"Wacker Dr. near Field Blvd." = "E WACKER DR & S FIELD BLVD",
"Walnut & St. Louis" = "N WALNUT ST & W ST LOUIS AVE",
"Washington and Sacramento" = "W WASHINGTON BLVD & N SACRAMENTO BLVD",
"Washtenaw & LeMoyne" = "N WASHTENAW AVE & W LEMOYNE ST",
"Washtenaw & Warren" = "N WASHTENAW AVE & W WARREN BLVD",
"Wellington & Kilpatrick 2011 menu is $5250" = "W WELLINGTON AVE & N KILPATRICK AVE",
"Wellington & Kilpatrick 2012 menu" = "W WELLINGTON AVE & N KILPATRICK AVE",
"West Bell Plaine/LaVergne" = "W BELL PL & N LAVERGNE AVE",
"West End & Kildare" = "W WEST END AVE & N KILDARE AVE",
"West End & Laramie" = "W WEST END AVE & N LARAMIE AVE",
"Western & Flournoy - NE corner" = "N WESTERN AVE & W FLOURNOY ST",
"Western Ave & Congress Parkway" = "N WESTERN AVE & W CONGRESS PKWY",
"Wilcox and Francisco" = "W WILCOX ST & N FRANCISCO AVE",
"Winthrop & Winona" = "N WINTHROP AVE & W WINONA ST",
"Wolcott/22" = "S WOLCOTT AVE & W 22ND ST",
"from 51 st & Ashland to 63 rd & Peoria" = "ON S ASHLAND AVE FROM W 51ST ST TO W 63RD ST", #close enough
"106 th/Ewing - 4 corners" = "E 106th ST & S EWING AVE",
"108 th/Buffalo" = "E 108th ST & S BUFFALO AVE",
"112 th/Ewing - 4 corners" = "E 112th ST & S EWING AVE",
"117 th St - 117 th Pl - Lowe - Wallace" = "E 117th ST & S LOWE AVE & E 117th PL & S WALLACE ST"
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
  "3 POD Cameras: Belmont & Central; Laramie & Addison Cicero & Addison" = "W Belmont Ave & N Central Ave; N Laramie Ave & W Addison St; N Cicero Ave & W Addison St"
)
# For the anti-gun violence mural, see:
# https://www.artworkarchive.com/profile/andy-bellomo/artwork/tunnel-of-blessings-neftali-reyes-jr-memorial-mural
# https://chicago.suntimes.com/news/2021/7/14/22577773/neftali-reyes-dead-humboldt-park-mural-clemente-high-baseball-gun-violence-606-trial-bloomingdale'

#eliminate \n in location
while (any(str_detect(menu_df$location, "\n"))) {
  menu_df$location <- str_replace_all(menu_df$location, "\n", "")
}
while (any(str_detect(menu_df$location, regex("  ", ignore_case = T)))) {
  menu_df$location <- str_replace_all(menu_df$location, "  ", " ")
}
#apply replacement lists
menu_df <- menu_df %>%
  mutate(
    # Use the lookup table for replacements in 'location'
    location = ifelse(location %in% names(location_replacements), location_replacements[location], location),
    # Use the lookup table for replacements based on 'type'
    location = ifelse(type %in% names(type_replacements), type_replacements[type], location),
    # reformat POD camera relocations
    location = str_replace(location, "Relocate (.*) to (.*)", "\\2"),
    #get rid of POD camera at . or POD Camera - ignore case
    location = str_replace(location, regex("POD Camera.*", ignore_case = T), "")
  )

# remove any spacing issues, but don't replace ordinal indicators and dashes between numbers
menu_df$location <- str_replace_all(menu_df$location, "(\\d)(?!(?:ST|ND|RD|TH|-))(\\D)", "\\1 \\2")
# while a double space is in location, replace with single space, again
while (any(str_detect(menu_df$location, regex("  ", ignore_case = T)))) {
  menu_df$location <- str_replace_all(menu_df$location, "  ", " ")
}
# delete any set of characters in between "(TPC" and ")"
menu_df$location <- str_replace_all(menu_df$location, "\\(TPC.*\\)", "")
# filter out all data with est_cost of 0 and location that contains "not available"
menu_df <- menu_df %>%
  filter(est_cost != 0) %>%
  filter(!str_detect(location, regex("not available", ignore_case = T)))

#colons typically indicate multiple locations, so we will split these into separate rows
colon_df <- menu_df %>% 
  filter(str_detect(location, regex(":|;", ignore_case = T))) 
#remove colon df from menu_df
menu_df <- menu_df %>%
  anti_join(colon_df)
# split location into multiple rows by : or ; and divide est_cost equally among non-empty rows
colon_df <- colon_df %>%
  mutate(
    location_temp = strsplit(location, regex(":|;", ignore_case = T)),
    num_elements = map_int(location_temp, length),
    num_elements = num_elements - map_int(location_temp, ~ sum(.x == "")),
    est_cost = est_cost / num_elements
  ) %>%
  unnest(location_temp) %>%
  filter(location_temp != "") %>%
  mutate(location = location_temp) %>%
  select(-location_temp, -num_elements)
#add "fixed" colon_df back to menu_df
menu_df <- menu_df %>%
  bind_rows(colon_df)
#replace "WEVERGREEN" with "W EVERGREEN" and "NPULASKI" with "N PULASKI" and so on
menu_df <- menu_df %>%
  mutate(location = str_replace(location, "WEVERGREEN", "W EVERGREEN"),
        location = str_replace(location, "NPULASKI", "N PULASKI"),
        location = str_replace(location, "NPARKSIDE" , "N PARKSIDE"))

# Step 2: Split location data into different standard formats and save to temp folder


# --------------------
# Location Data of Parks or Schools
# --------------------
school_park_df <- menu_df %>%
  filter(str_detect(location, regex("( garden| school| playground|play lot| playlot| park| field|Park;|Beach)", ignore_case = T))) %>% # filter out any "st" or "av
  filter(!str_detect(location, regex("( St| Dr.| rd| blvd| BV | av| AVE|Lake Park Av|Central Park|lincoln park w)", ignore_case = T))) %>% # filter out ON FROM TO
  filter(!str_detect(location, regex("( on | from | to |/)", ignore_case = T))) %>%
  filter(!str_detect(location, regex("(parkway|parkside|parking)", ignore_case = T)))
school_park_df_sum <- sum(school_park_df$est_cost) #saving for later assertion

leftover_df <- menu_df %>%
  anti_join(school_park_df)

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
  mutate(location = ifelse(str_detect(location, "Edna White Garden"), "Edna White Community Garden", location)) %>%
  mutate(location = ifelse(str_detect(location, "Kathy Osterman Beach House"), "Kathy Osterman Beach House", location)) %>%
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

school_park_df_sum2 <- sum(school_park_df$est_cost)
assert_that(school_park_df_sum == school_park_df_sum2) 

write.csv(school_park_df, "../output/school_park_df.csv", row.names = F)
# --------------------
# Location Data of format "_ ST -- _ AV -to- _ ST"
# --------------------
double_dash_to_df <- leftover_df %>%
  filter(str_detect(location, "--")) %>%
  filter(str_detect(location, "-to-"))

double_dash_to_df_sum <- sum(double_dash_to_df$est_cost)

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

double_dash_to_df_sum2 <- sum(double_dash_to_df$est_cost)

write.csv(double_dash_to_df, "../output/double_dash_to_df.csv", row.names = F)


#--------------------
# Location Data of format "##-### street
#--------------------
through_address_df <- leftover_df %>%
  filter(str_detect(location, regex("^[0-9]{2,5}-[0-9]{1,5}", ignore_case = T)))
#count total sum of est_cost for df
through_address_sum1 <- sum(through_address_df$est_cost)
 leftover_df <- leftover_df %>%
   anti_join(through_address_df)
#create new df where location does not contain -
through_address_leftover <- through_address_df %>%
  filter(!str_detect(location, "-"))
through_address_df <- through_address_df %>%
  anti_join(through_address_leftover)
through_address_sum2 <- sum(through_address_leftover$est_cost)
#append to leftover_df
leftover_df <- leftover_df %>%
  bind_rows(through_address_leftover)

# now to create start and end addresses for the through addresses
through_address_df <- through_address_df %>%
  mutate(
    N1 = str_extract(location, "^[0-9]{2,5}"), 
    N2 = str_extract(location, "(?<=-)[0-9]{1,5}"),
    street = str_extract(location, "[A-Z].*")
  )

through_address_df <- through_address_df %>%
  mutate(
    N2 = ifelse(str_length(N1) > str_length(N2), paste0(substr(N1, 1, str_length(N1)-str_length(N2)), N2), N2),
    start_address = ifelse(str_length(N1) == str_length(N2), paste0(N1, " ", street), NA_character_),
    end_address = ifelse(str_length(N1) == str_length(N2), paste0(N2, " ", street), NA_character_)
  ) %>%
  select(-N1, -N2, -street)

#assert that the sum of est_cost is within 0.0001 beginning
through_address_sum3 <- sum(through_address_df$est_cost)
assert_that(through_address_sum1 - through_address_sum2 - through_address_sum3 < 0.0001) #not exact due to computational error
write.csv(through_address_df, "../output/through_address_df.csv", row.names = F)
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
write.csv(normal_address_df, "../output/normal_address_df.csv", row.names = F)


#--------------------
# Location Data of format "ON _ AV from _ ST to _ ST"
#--------------------
on_from_to_replacements <- c("24 TH PL FROM S ROCKWELL ST (2600 W) TO S WASHTENAW AVE (2700 W)" = "ON W 24th PL FROM S ROCKWELL ST (2600 W) TO S WASHTENAW AVE (2700 W)",
"GREENVIEW-JARVIS TO HOWARD" = "ON N GREENVIEW AVE FROM W JARVIS AVE TO W HOWARD ST",
"N MCCLURG CT FROM E NORTH WATER ST (430 N) TO E RIVER DR (404 N)" = "ON N MCCLURG CT FROM E NORTH WATER ST (430 N) TO E RIVER DR (404 N)",
"N W PRATT BLVD FROM 1051 W TO N SHERIDAN RD (1200 )" = "ON W PRATT BLVD FROM 1051 W TO N SHERIDAN RD (1200 W)",
"N W SHERWIN AVE FROM 1200 W TO N SHERIDAN RD (1300 )" = "ON N SHERWIN AVE FROM 1200 W TO N SHERIDAN RD (1300 W)",
"N W JARVIS AVE FROM N BELL AVE (2200 W) TO N OAKLEY VE (2300 W)" = "ON N JARVIS AVE FROM N BELL AVE (2200 W) TO N OAKLEY AVE (2300 W)",
"Sherdian-Belmont to Diversey" = "ON N SHERIDAN RD FROM W BELMONT AVE TO W DIVERSEY PKWY",
"S SHORE DR 79 TH TO 80 TH" = "ON S SHORE DR FROM E 79TH ST TO E 80TH ST",
"N N WOLCOTT AVE FROM W CHASE AVE (7300 N) TO N OGERS AVE (7340 N)" = "ON N WOLCOTT AVE FROM W CHASE AVE (7300 N) TO N ROGERS AVE (7340 N)",
"9500 to 9800 S. Emerald" = "ON S EMERALD AVE FROM W 95TH ST TO W 98TH ST",
"9300 to 9500 S. Loomis" = "ON S LOOMIS ST FROM W 93RD ST TO W 95TH ST",
"47 th Place - Western to Oakley" = "ON W 47TH PL FROM S WESTERN AVE TO S OAKLEY AVE",
"Blue Island from 15 th St. / 16 th St. Bike Lane" = "ON W 15TH ST FROM S BLUE ISLAND AVE TO S 16TH ST",
"Austin - Gunnison to Lawrence" = "ON N AUSTIN AVE FROM W GUNNISON ST TO W LAWRENCE AVE",
"MILWAUKEE-DAMEN TO WESTERN" = "ON N MILWAUKEE AVE FROM N DAMEN AVE TO N WESTERN AVE",
"INNER LAKESHORE-DIVISION(1200 N) to NORTH AVE (1600 N)" = "ON N LAKE SHORE DR FROM W DIVISION ST (1200 N) TO W NORTH AVE (1600 N)",
"8600 to 8700 S. Justin" = "ON S JUSTINE ST FROM W 86TH ST TO W 87TH ST",
"Randolph St. from Michigan Ave. to Field Blvd." = "ON E RANDOLPH ST FROM N MICHIGAN AVE TO N FIELD BLVD",
"N. SPRINGFIELD-W. BLOOMINGDALE TO W. ARMITAGE" = "ON N SPRINGFIELD AVE FROM W BLOOMINGDALE AVE TO W ARMITAGE AVE",
"N. HARDING-BLOOMINGDALE TO ARMITAGE" = "ON N HARDING AVE FROM W BLOOMINGDALE AVE TO W ARMITAGE AVE",
"Luella E. 82 nd to E. 83 rd" = "ON S LUELLA AVE FROM E 82ND ST TO E 83RD ST",
"Paulina - Moorman to Division" = "ON N PAULINA ST FROM W MOORMAN ST TO W DIVISION ST",
"N W SHERWIN AVE FROM 1200 W TO N SHERIDAN RD (1300 )" = "ON N SHERWIN AVE FROM 1200 W TO N SHERIDAN RD (1300 W)",
"Belden - Normandy to Private Drive" = "ON W BELDEN AVE FROM N NORMANDY AVE TO 6440 W Belden Ave", #closest to private drive
"Belden - Normandy to Private Dr" = "ON W BELDEN AVE FROM N NORMANDY AVE TO 6440 W Belden Ave", #closest to private drive
"Belden - Normandy to Private Dr." = "ON W BELDEN AVE FROM N NORMANDY AVE TO 6440 W Belden Ave", #closest to private drive
"W PATTERSON AVEDead End (4652 W)Dead End (4521 W)" = "ON W PATTERSON AVE FROM DEAD END (4652 W) TO DEAD END (4521 W)",
"137 - 141 E 114th Place (parkway)" = "ON E 114TH PL FROM S MICHIGAN AVE TO S INDIANA AVE",
"Kostner - 47 th to 51 st" = "ON S KOSTNER AVE FROM W 47TH ST TO W 51ST ST",
"W CARMEN AVE FROM N RAVENSWOOD AVE (1800 W) TO N ASHLAND AVE (1600 W)" = "ON W CARMEN AVE FROM N RAVENSWOOD AVE (1800 W) TO N ASHLAND AVE (1600 W)",
"Taylor Street-Western to Ogden" = "ON W TAYLOR ST FROM S WESTERN AVE TO S OGDEN AVE",
"Taylor-Western to Ogden" = "ON W TAYLOR ST FROM S WESTERN AVE TO S OGDEN AVE",
"Cottage Grove, 39 th to 51 st" = "ON S COTTAGE GROVE AVE FROM E 39TH ST TO E 51ST ST",
"GREENVIEW-HOWARD TO JONQUIL TERRACE" = "ON N GREENVIEW AVE FROM W HOWARD ST TO W JONQUIL TER",
"100 th St / from Ewing / Indianapolis" = "ON E 100TH ST FROM S EWING AVE TO S INDIANAPOLIS AVE",
"Baltimore / from Brainard (13460 Baltimore)" = "ON S BALTIMORE AVE FROM W BRAINARD AVE TO 13460 S BALTIMORE AVE",
"N N GREENVIEW AVE FROM W ALBION AVE (6600 N) TO W RATT BLVD (6800 N)" = "ON N GREENVIEW AVE FROM W ALBION AVE (6600 N) TO W PRATT BLVD (6800 N)",
"ON E 69TH ST FROM SDORCHESTER AVE (1400 E) TO S DANTE AVE (1440 E)" = "ON E 69TH ST FROM S DORCHESTER AVE (1400 E) TO S DANTE AVE (1440 E)",
"N N WOLCOTT AVE FROM W CHASE AVE (7300 N) TO N OGERS AVE (7340 N)" = "ON N WOLCOTT AVE FROM W CHASE AVE (7300 N) TO N ROGERS AVE (7340 N)",
"ON N KILDARE AVE FROM W MAYPOLE AVE (250 N) TO W LAKE ST (300 N)")

#repeatedly remove \n from location until none remain
# while (any(str_detect(leftover_df$location, "\n"))) {
#   leftover_df$location <- str_replace_all(leftover_df$location, "\n", "")
# }
leftover_df <- leftover_df %>%
  mutate(location = ifelse(location %in% names(on_from_to_replacements), on_from_to_replacements[location], location))

#Correct a whole bunch of typos
replacements <- c("BFROM" = "B FROM",
                  "HFROM" = "H FROM",
                  "LFROM" = "L FROM",
                  "MFROM" = "M FROM",
                  "NFROM" = "N FROM",
                  ")TO " = ") TO",
                  " STO " = " S TO ",
                  "ONN " = "ON ",
                  " STFROM " = " ST FROM ",
                  " AVEFROM " = " AVE FROM ",
                  ") TOW " = ") TO W ",
                  ") TON " = ") TO N ",
                  " FROMS " = " FROM S ")

leftover_df <- leftover_df %>%
  mutate(location = gsubfn("\\b(.*?)\\b", replacements, location))

from_to_df <- leftover_df %>%
  filter(str_detect(location, regex(" FROM ", ignore_case = T))) %>%
  filter(str_detect(location, regex(" TO ", ignore_case = T))) %>%
  filter(str_detect(location, regex("ON ", ignore_case = T))) %>%
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

write.csv(from_to_df, "../output/from_to_df.csv", row.names = F)

# --------------------
# Location Data of format "# N/S/E/W road_1 & N/S/E/W road_2 & N/S/E/W road_3 & N/S/E/W road_4"
# --------------------
#remove any badly formatted lists with ones seperated by &
leftover_df <- leftover_df %>%
mutate(location =  str_replace_all(location, "([)A-Z]) ([NSEW] )", "\\1 & \\2")) 


addition_df <- leftover_df %>%
  filter(str_detect(location, regex("(&|;|:|--|-and-|/| and )", ignore_case = T))) %>%
  filter(!str_detect(location, regex(" from ", ignore_case = T)))

addition_modified_df <- addition_df %>%
  mutate(location = str_replace_all(location, "(&|;|:|--|-and-|/| and )", " & "))
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
#replace any instances of " & [NSEW] & " with " & "
addition_modified_df <- addition_modified_df %>%
  mutate(location = str_replace_all(location, regex(" & [N|S|E|W] & "), " & "))


df_with_3_ands <- addition_modified_df %>%
  filter(str_count(location, fixed("&")) == 3)

leftover_addition_df <- addition_modified_df  %>%
  anti_join(df_with_3_ands)
  
generate_intersections <- function(streets, maxpairs) {
  diag_streets <- c("N MILWAUKEE AV", "N MILWAUKEE AVE","S ARCHER AVE", "S BLUE ISLAND AV", "N CLYBOURN AVE",
   "S HILLCOCK AV", "S GROVE ST", "S ELEANOR ST", "N CALDWELL AVE", "N CALDWELL AVE","N LEOTI AVE",
   "N MAUD AV", "N CLYBORN AV", "N LISTER AV", "N WOLCOTT AV", "N FOREST GLEN AV", "N IONIA AV",
   "N CALDWELL AV", "N KINGSDALE AV", "N NORTHWEST HW", "N OLMSTED AV", "N HIAWATHA AV", "N TAHOMA AV",
   "N OWEN AV", "N OLMSTED AV", "N ALGONQUIN AV", "N SHERIDAN RD")
  ns <- streets[substr(streets, 1, 1) %in% c("N", "S")]
  ew <- streets[substr(streets, 1, 1) %in% c("E", "W")]
  if (length(ns) != length(ew)) {
    diag_streets_used <- intersect(diag_streets, streets)
    ns <- c(ns, diag_streets_used)
    ew <- c(ew, diag_streets_used)
  }
  #remove repeat streets in ns ew
  ns <- unique(ns)
  ew <- unique(ew)
  intersect_pairs <- expand.grid(ns, ew)
  #remove all pairs after pair 4
  intersect_pairs <- paste(intersect_pairs$Var1, intersect_pairs$Var2, sep=" & ")
  #remove any pairs where the same street comes before and after the &
  intersect_pairs_split <- str_split_fixed(intersect_pairs, " & ", 2)
  intersect_pairs <- intersect_pairs[intersect_pairs_split[, 1] != intersect_pairs_split[, 2]]
  #if any of streets have 3-5 numbers in them, add the street to intersect_pairs
  streets_with_3_5_numbers <- streets[str_count(streets, "[0-9] [N|S|E|W]") %in% 3:5]
  if (length(streets_with_3_5_numbers) > 0) {
    intersect_pairs <- c(intersect_pairs, streets_with_3_5_numbers)
  }
  #restrict intersect_pairs to maxpairs
  intersect_pairs <- intersect_pairs[1:maxpairs]
  return(intersect_pairs)
}

df_with_3_ands <- df_with_3_ands %>%
  mutate(location = str_replace_all(location, "ST3,611", "ST"),
         location = str_replace_all(location, "ST5,906", "ST"), #these still have correct est cost somehow
         location = str_replace_all(location, "87 th & Chappel & 87 th & Merrill", "E 87TH ST & S CHAPPEL AVE & E 87TH ST & S MERRILL AVE"),
         location = ifelse(location == "Damen & Division & Logan Blvd & Milwaukee-multiple locations", "N DAMEN AVE & W DIVISION ST & W LOGAN BLVD & N MILWAUKEE", location), #formatting
         location = ifelse(location == "E03 ST & E03 PL & S STATE ST & S WABASH AV", "E 103RD ST & S STATE ST & E 103RD ST & S WABASH AVE", location), # typo
         location = ifelse(location == "SRRAGANSETT AV & SGLE AV & W 51 & W 52", "S NARRAGANSETT AVE & S NAGLE AVE & W 51ST ST & W 52ND ST", location), # typo
         location = ifelse(location == "79 th & Marquette & 75 th & Colfax", "E 79TH ST & S MARQUETTE AVE & E 75TH ST & S COLFAX AVE", location), # formatting
         location = ifelse(location == "Maplewood & Diversey & Chicago & Northern Railroad", NA, location), #can't determine this
         location = ifelse(location == "79 th & Marquette & 75 th & Colfax", "E 79TH ST & S MARQUETTE AVE & E 75TH ST & S COLFAX AVE", location), # formatting
         location = ifelse(location == "Jackson & Adams & Laflin & Ashland", "W JACKSON BLVD & S ASHLAND AVE & W ADAMS ST & S LAFLIN ST", location), # formatting
         location = ifelse(location == "78 th & 79 th & Ridgeland & Creiger", "E 78TH ST & S RIDGELAND AVE & E 79TH ST & S CREIGER AVE", location), # formatting
         location = ifelse(location == "Rhodes & 67 th & 67 th & S. Chicago", "S RHODES AVE & E 67TH ST & E 67TH ST & S SOUTH CHICAGO AVE", location), # formatting
         location = ifelse(location == "18 th St & 18 th Pl & Hoyne & Leavitt", "W 18TH ST & S HOYNE AVE & S LEAVITT ST & W 18TH PL", location), # formatting
         location = ifelse(location == "Keystone & Lemonye to Grand & Lemonyne & Karlov to Pulaski", "N KEYSTONE AVENUE & W LEMOYNE ST & W GRAND AVE & N PULASKI RD", location ),
         location = ifelse(location == "Ashland & Clybourn & Webster & Dominick", "N CLYBOURN AVE & N ASHLAND AVE & W WEBSTER AVE & N DOMINICK ST", location), # formatting
         location = ifelse(location == "Estes & Lunt & Oleander & Oriole", "W ESTES AVE & W LUNT AVE & N OLEANDER AVE & N ORIOLE AVE", location), # formatting
         location = ifelse(location == "N CALDWELL AV & N CALDWELL AV & NVAJO AV & N LEMAI AV", "N CALDWELL AVENUE & N NAVAJO AVENUE & N LE MAI AVENUE & N LEOTI AVE", location),
         location = ifelse(location == "N HOYNE AV & N WILMOT AV & RAILROAD TRACKS & DEAD END", "2101 W WABANASIA AVE & 1701 N MILWAUKEE AVE & 1759 N WILMOT AVE & 1721 N HOYNE AVE", location),
         location = ifelse(location == "Ashland & Clybourn & Webster & Dominick", "N CLYBOURN AVE & N ASHLAND AVE & W WEBSTER AVE & N DOMINICK ST", location), # formatting
         location = ifelse(location == "W SHERIDAN RD & DEAD END & W PRATT AV & W FARWELL AV", "N SHERIDAN RD & DEAD END & W PRATT BLVD & W FARWELL AVE", location), #north sheridan typo
         location = ifelse(location == "W LUNT AV & W GREENLEAF AV & W SHERIDAN RD & DEAD END", "W LUNT AVE & W GREENLEAF AVE & N SHERIDAN RD & DEAD END", location) #north sheridan typo
         )

df_results <- df_with_3_ands %>%
  mutate(
    id = row_number(),
    location = str_split(location, " & ")
  ) %>%
  rowwise() %>%
  mutate(location = list(generate_intersections(unlist(location), 4))) %>%
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

# commented code to see which rows have 0 intersections matched
# df_with_3_ands <- df_with_3_ands %>%
#   filter(is.na(intersection_1) & is.na(intersection_2) & is.na(intersection_3) & is.na(intersection_4))
#apply ordinal indicator function to intersection_1, intersection_2, intersection_3, and intersection_4
for (i in 1:4) {
  var <- paste0("intersection_", i)
  df_with_3_ands <- add_ordinal_indicator(df_with_3_ands, var)
}

write.csv(df_with_3_ands, "../output/df_with_3_ands.csv", row.names = F)

# --------------------
# Location Data of format "# N/S/E/W road_1 & N/S/E/W road_2 & N/S/E/W road_3"
# --------------------
df_with_2_ands <- leftover_addition_df %>%
  filter(str_count(location, fixed(" & ")) == 2)

leftover_addition_df <- leftover_addition_df %>%
  anti_join(df_with_2_ands)

df_with_2_ands_replacements <- c(
  "108 th & Buffalo & 104 th Ave 'M'" = "E 108TH ST & S BUFFALO AVE & E 104TH ST",
  "Kedzie & 105 th St. & 107 th St." = "S KEDZIE AVE & W 105TH ST & W 107TH ST",
  "Victoria & Spaulding & 6123 Ravenswood" = "N VICTORIA ST & N SPAULDING AVE & 6123 N RAVENSWOOD AVE",
  "Division & Oakley Blvd. & Leavitt St." = "W DIVISION ST & N OAKLEY BLVD & N LEAVITT ST",
  "Milwaukee & Wood & Wolcott" = "N MILWAUKEE AVE & N WOOD ST & N WOLCOTT AVE",
  "S RUBLE ST & W 16 ST (1600 S) & N DAN RYAN ENTR RP (1676 S)" = "S RUBLE ST & W 16TH ST (1600 S) & S UNION AVE"
)
#apply replacements
df_with_2_ands <- df_with_2_ands %>%
  mutate(location = ifelse(location %in% names(df_with_2_ands_replacements), df_with_2_ands_replacements[location], location))
#create two new columns for the two intersections and apply generate_intersections to each row 
df_2_results <- df_with_2_ands %>%
  mutate(
    id = row_number(),
    location = str_split(location, " & ")
  ) %>%
  rowwise() %>%
  mutate(location = list(generate_intersections(unlist(location),2))) %>%
  unnest(location) %>%
  mutate(intersection_number = paste0("intersection_", ((row_number() - 1) %% 2) + 1)) %>%
  pivot_wider(names_from = intersection_number, values_from = location) 
#replace all instances of DEAD END with nothing
df_with_2_ands <- df_with_2_ands %>%
  mutate(location = str_replace(location, "DEAD END", ""))


df_with_2_ands <- df_with_2_ands %>%
  mutate(id = row_number()) %>%
  left_join(df_2_results) %>%
  select(-id)
#convert intersection_1 2 and 3 to character
df_with_2_ands <- df_with_2_ands %>%
  mutate(intersection_1 = map_chr(intersection_1, ~ paste(.x, collapse = "; "))) %>%
  mutate(intersection_2 = map_chr(intersection_2, ~ paste(.x, collapse = "; "))) 

#remove all text in () from intersection_1 and intersection_2
df_with_2_ands <- df_with_2_ands %>%
  mutate(intersection_1 = str_replace_all(intersection_1, "\\(.*?\\)", "")) %>%
  mutate(intersection_2 = str_replace_all(intersection_2, "\\(.*?\\)", ""))

intersection_replacements_2_ands <- c( #Some intersections don't exist, so they need to be replaced
  "N WOLCOTT AV & W CORNELIA AVE" = "1900 W CORNELIA AVE",
  "N CALDWELL AV & W THORNDALE AV" = "5803 N CALDWELL AVE",
  "S WENTWORTH AV & W 25 TH PL" = "200 W 25TH PL",
  "N IONIA AV & W PETERSON AV" = "6108 N FOREST GLEN AVE"
)
#replace any intersections in intersection_replacements_2_ands
df_with_2_ands <- df_with_2_ands %>%
  mutate(intersection_1 = ifelse(intersection_1 %in% names(intersection_replacements_2_ands), intersection_replacements_2_ands[intersection_1], intersection_1),
         intersection_2 = ifelse(intersection_2 %in% names(intersection_replacements_2_ands), intersection_replacements_2_ands[intersection_2], intersection_2))
  
#apply ordinal indicator function to every intersection variable
for (i in 1:2) {
  var <- paste0("intersection_", i)
  df_with_2_ands <- add_ordinal_indicator(df_with_2_ands, var)
}


write.csv(df_with_2_ands, "../output/df_with_2_ands.csv", row.names = F)

# --------------------
# Location Data of format "N/S/E/W road_1 % N/S/E/W road_2 - N/S/E/W road_3"
# --------------------
df_and_dash <- leftover_addition_df %>%
  filter(str_count(location, fixed(" & ")) == 1) %>%
  filter(str_count(location, fixed("-")) == 1)

#now process similar to "double-dash to" where "--" is & and "to" is "-"
leftover_addition_df <- leftover_addition_df %>%
  anti_join(df_and_dash)

#for each row, split location by " & " and  "-" to create a list
#then generate intersection_1 by combining the first and second element of the list with " & " between them
#then generate intersection_2 by combining the first and third element of the list with " & " between them
df_and_dash <- df_and_dash %>%
  mutate(
    id = row_number(),
    location = str_split(location, " & ")
  ) %>%
  rowwise() %>%
  mutate(location = list(generate_intersections(unlist(location), 2))) %>%
  unnest(location) %>%
  mutate(intersection_number = paste0("intersection_", ((row_number() - 1) %% 2) + 1)) %>%
  pivot_wider(names_from = intersection_number, values_from = location) %>%
  mutate(intersection_1 = map_chr(intersection_1, ~ paste(.x, collapse = "; "))) %>%
  mutate(intersection_2 = map_chr(intersection_2, ~ paste(.x, collapse = "; ")))



# --------------------
# Location Data of format "# N/S/E/W road_1 (& or ; or :) N/S/E/W road_2
# --------------------
intersection_df <- leftover_addition_df %>%
  filter(str_count(location, fixed("&")) == 1)

leftover_addition_df <- leftover_addition_df %>%
  anti_join(intersection_df)

#find PLDR. and STDR. and replace with PL DR. and ST DR.
intersection_df <- intersection_df %>%
  mutate(location = str_replace_all(location, "PLDR\\.", "PL DR."),
         location = str_replace_all(location, "STDR\\.", "ST DR."))

#apply ordinal indicator function
intersection_df <- add_ordinal_indicator(intersection_df, "location")

write.csv(intersection_df, "../output/intersection_df.csv", row.names = F)

# --------------------
# Location Data of format with multiple "&'s
# --------------------
df_with_mult_ands <- addition_modified_df %>%
  filter(str_count(location, fixed("&")) > 3)
#find the maximum number of & in a row
max_ands <- max(str_count(df_with_mult_ands$location, fixed("&")))

# leftover_addition_df <- leftover_addition_df %>%
#   anti_join(df_with_mult_ands)


df_mult_results <- df_with_mult_ands %>%
  mutate(
    id = row_number(),
    location = str_split(location, " & ")
  ) %>%
  rowwise() %>%
  mutate(location = list(generate_intersections(unlist(location), max_ands))) %>%
  unnest(location) %>%
  mutate(intersection_number = paste0("intersection_", ((row_number() - 1) %% max_ands) + 1)) %>%
  pivot_wider(names_from = intersection_number, values_from = location)

df_with_mult_ands <- df_with_mult_ands %>%
  mutate(id = row_number()) %>%
  left_join(df_mult_results) %>%
  select(-id)
#Convert all intersection_# from 1 to max_ands to character
for (i in 1:max_ands) {
  df_with_mult_ands <- df_with_mult_ands %>%
    mutate(!!paste0("intersection_", i) := map_chr(!!sym(paste0("intersection_", i)), ~ paste(.x, collapse = "; ")))
}

#apply ordinal indicator function to every intersection variable
for (i in 1:max_ands) {
  var <- paste0("intersection_", i)
  df_with_mult_ands <- add_ordinal_indicator(df_with_mult_ands, var)
}

write.csv(df_with_mult_ands, "../output/df_with_mult_ands.csv", row.names = F)
# --------------------
# Leftover Data
# --------------------
leftover_df <- leftover_df %>%
  anti_join(addition_df)

rm(leftover_addition_df, addition_df, addition_modified_df)
# write leftover_df to csv
write.csv(leftover_df, "../output/leftover_df.csv", row.names = F)