library(tidyverse)
library(tidygeocoder)
source("geocode_function.R")
df <- read_csv("../input/leftover_df.csv")
#additional cleaning needed
#create a list called "filter list" and filter df by it
filter_list <- c("16 TH WARD", "15 locations", "Various Locations", "8 locations", "9 locations", "11 locations",
 "10 th Ward", "Capital Upgrades", "Trees on the public way", "Decorative Baskets - Installed at 107 locations",
 "Decorative Waste Receptacles - various locations", "City owned vacant land (signs)", "20 Decorative Bench installation",
 "2 Option I POD", "Purchase of 32 decorative waste baskets", "Model block various locations",
 "Decorative Waste Receptacles - various locations", "Chicago Public Art Group- various locations","Martin Luther King Boulevard artwork installation",
 "Replace faded bikeway marking", "10 Decorative Benches", "2 Option i POD", "48 th Ward Retail Study",
 "Various arterial Streets (in file) - Tree planting", "Model block", "various locations", "30 Trees to be planted in the Ward",
 "Various Chicago Public Art Group Projects", "Sign Installation project", "Police Bikes", "3203", "Tree Planting - 4239",
 "4.00", "VARIOUS LOCATIONS IN WARD", "Decorative Bench", "Hiawatha Ave - multiple locations", "Christmass Tree decorations",
"8 decorative garbage cans", "Trees on MLK Drive (2012 installation)", "53 rd Street - 5 tree grates", "Chicago Public Art Group - various Locations",
"Shot Spotters", "Installation of two bike stations","OBM Concrete Alley Program", "POD Cameras - 37 locations", "Honorary Signs - Sanchez Dr.",
"Hamlin Blvd Landscape Enhancement", "CICERO AVE", "Roscoe Ave pavers", "Access Living Public Improvements", "Tree installation",
"W LAWRENCE AVEDEAD END", "W ADDISON STDEAD END", "W MONTROSE AVEDEAD END", "W WILSON AVEDEAD END","Gravel Pave Alley surface",
"N. Clark St. (Benazir Bhutto Way Honorarily Sign)", "Honorary Sign Wayne Peters Ave", "Solar Powered Garbage Containers - 8 locations. TPC =",
"Solar Powered Garbage Containers- 8 locations (201", "Parks" 
 )
df <- df %>% filter(!location %in% filter_list)
replacement_list <- c("Saughnash" = "4321 W Peterson Ave",
"Forest Glen Mural" = "N FOREST GLEN AVE & W ELSTON AVE", #nearest intersection to train station mural https://www.dnainfo.com/chicago/20140618/forest-glen/forest-glen-mural-replacement-effort-underway/
"Ohio Street Dog Park Fence" = "Ohio Place Dog Park", #obvious typo
"CTA Fullerton Stop- Healy Stone Project. Menu 2003,2004,2005," = "CTA Fullerton Stop",
"Sheridan Rd @ Castlewood Terrace" = "942 W Castlewood Terrace", #nearest address to intersection-like thing
"Dog Park across from Clarendon Park" = "Clarendon Community Center", #center that operates the dog park
"PINE GROVE AVE" = "Hazel & Wilson; Clarendon & Wilson Broadway & Leland; Addison & Pine Grove", #location stored in "type" column
"Lincoln Ave at Cullom Ave" = "N Lincoln Ave & W Cullom Ave", 
"Damen @ Byron" = "N Damen Ave & W Byron St",
"Lawrence @ Campbell" = "N Lawrence Ave & N Campbell Ave",
"Foster Ave at Marine Drive" = "N Marine Dr & W Foster Ave",
"Foster at Lake Shore Dr. Sandblasting" = "N Lake Shore Dr & W Foster Ave",
"Broadway at Thorndale" = "N Broadway & W Thorndale Ave",
"Thorndale CTA Station (lighting)" = "Thorndale CTA Station",
"Sheridan on lightpole North of Thorndale" = "N Sheridan Rd & W Thorndale Ave",
"N BROADWAYW ARDMORE AV (5800 N)" = "N Broadway & W Ardmore Ave",
"Street Resurfacing - N. Sheridan (Devon)" = "N Sheridan Rd & W Devon Ave",
"Fence at 4919 N. Winthrop (City property)" = "4919 N Winthrop Ave",
"Tree Gates at 7300 N Oakley" = "7300 N Oakley Ave",
"Loyola Beach Dunes - sign" = "Loyola Beach",
"Benches, shelters- Red line stops Jarvis,Morse,Loyola (Final cost shown)." = "Jarvis CTA Station; Morse CTA Station; Loyola CTA Station",
"Murals in Rogers Park on CTA Viaducts" = "Rogers Park Train Station",#nearest to viaduct
"Lunt at RR (1600 W)" = "W Lunt Ave & N Glenwood Ave",
"Estes at RR (1600 W)" = "W Estes Ave & N Glenwood Ave",
"Touhy at RR (1600 W)" = "W Touhy Ave & Main st", #nearest intersection
"Birchwood at RR (1600 W)" = "1600 W Birchwood Ave", #close enough
"2728", "2728-2890 S State",
"104 th Ave 'M'" = "104th AVE & S M AVE"
)
#apply the replacements to the df, using mutate and ifelse() if location is in the list
df <- df %>% mutate(location = ifelse(location %in% names(replacement_list), replacement_list[location], location))


#remove any text in location after (menu and (TPC
df <- df %>% mutate(location = str_remove(location, "\\(menu.*"))
df <- df %>% mutate(location = str_remove(location, "\\(TPC.*"))
#split the df into rows that contain a - between two numbers and rows that don't
df_with_dash <- df %>% filter(str_detect(location, "^[0-9]{2,5}-[0-9]{1,5}"))
df_without_dash <- df %>% filter(!str_detect(location, "^[0-9]{2,5}-[0-9]{1,5}"))

#rename location to avoid function name conflict
df_with_dash <- df_with_dash %>% rename(location_dash = location)
df_without_dash <- df_without_dash %>% rename(location_no_dash = location)

geocoded_df_no_dash <- menu_geocode(df_without_dash, "location_no_dash", 10)
#replace all obviously non-Chicago coordinates with NA
geocoded_df_no_dash <- filter_chicago_coordinates(geocoded_df_no_dash)
write_csv(geocoded_df_no_dash, "../output/geocoded_leftover_df.csv")


#apply the same process of through_address_df to df_with_dash and then geocode
df_with_dash <- df_with_dash %>%
  mutate(
    N1 = str_extract(location_dash, "^[0-9]{2,5}"), 
    N2 = str_extract(location_dash, "(?<=-)[0-9]{1,5}"),
    street = str_extract(location_dash, "[A-Z].*")
  )

df_with_dash <- df_with_dash %>%
  mutate(
    N2 = ifelse(str_length(N1) > str_length(N2), paste0(substr(N1, 1, str_length(N1)-str_length(N2)), N2), N2),
    start_address = ifelse(str_length(N1) == str_length(N2), paste0(N1, " ", street), NA_character_),
    end_address = ifelse(str_length(N1) == str_length(N2), paste0(N2, " ", street), NA_character_)
  ) %>%
  select(-N1, -N2, -street)

geocoded_df_dash <- menu_geocode(df_with_dash, "start_address", 10) %>%
    rename(lat_start = lat, lon_start = long, query_start = query) %>%
    menu_geocode(., "end_address", 10) %>%
    rename(lat_end = lat, lon_end = long, query_end = query)
#replace all obviously non-Chicago coordinates with NA
geocoded_df_dash <- filter_chicago_coordinates(geocoded_df_dash)
write_csv(geocoded_df_dash, "../output/geocoded_leftover_df_dash.csv")