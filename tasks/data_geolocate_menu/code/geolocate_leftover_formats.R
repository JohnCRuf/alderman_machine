library(tidyverse)
library(tidygeocoder)
source("geolocate_function.R")
df <- read_csv("../temp/leftover_df.csv")
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
"Solar Powered Garbage Containers- 8 locations (201", "Parks", 

 )
df <- df %>% filter(!location %in% filter_list)
replacement_list <- c("Saughnash" = "4321 W Peterson Ave",
"Forest Glen Mural" = "N FOREST GLEN AVE & W ELSTON AVE", #nearest intersection to train station mural https://www.dnainfo.com/chicago/20140618/forest-glen/forest-glen-mural-replacement-effort-underway/
"Ohio Street Dog Park Fence" = "Ohio Place Dog Park", #obvious typo
"CTA Fullerton Stop- Healy Stone Project. Menu 2003,2004,2005," = "CTA Fullerton Stop",
"Sheridan Rd @ Castlewood Terrace" = "942 W Castlewood Terrace", #nearest address to intersection-like thing
"Dog Park across from Clarendon Park" = "Clarendon Community Center" #center that operates the dog park
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
"2728", "2728-2890 S State"
)
#apply the replacements to the df, using mutate and ifelse() if location is in the list
df <- df %>% mutate(location = ifelse(location %in% names(replacement_list), replacement_list[location], location))


#remove any text in location after (menu and (TPC
df <- df %>% mutate(location = str_remove(location, "\\(menu.*"))
df <- df %>% mutate(location = str_remove(location, "\\(TPC.*"))
#split the df into rows that contain a - and rows that don't
df_with_dash <- df %>% filter(str_detect(location, "-"))
df_without_dash <- df %>% filter(!str_detect(location, "-"))



geolocated_df <- menu_geolocate(df, "location_1", 100) %>%  #100 b/c of tougher geocoding.
    rename(lat_1 = lat, lon_1 = long, query_1 = query) %>%
    menu_geolocate(., "location_2", 10) %>% 
    rename(lat_2 = lat, lon_2 = long, query_2 = query) %>%
    menu_geolocate(., "location_3", 10) %>% 
    rename(lat_3 = lat, lon_3 = long, query_3 = query) 

write_csv(geolocated_df, "../temp/geolocated_from_to_df.csv")