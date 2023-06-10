menu_geolocate <- function(df, var_name) {
    df <- df %>%
        mutate(singlelineaddress = paste0(str_replace_all(!!sym(var_name), ",", " "), ", Chicago, IL"))
    #use geocode_combine to geolocate df using the census api and save as "census_df"
    results <- geocode_combine(df,
    queries = list(
        list(method = 'census'),
        list(method = 'google')
    ),
    global_params = list(address = 'singlelineaddress'),
    cascade = TRUE
    ) %>%
        select(-singlelineaddress)

    return (results)
}

#comments to test code
# library(tidyverse)
# library(tidygeocoder)
# main_df <- read_csv("../temp/normal_address_df.csv")
# df <- main_df[1:10,]
# geo_results <- menu_geolocate(df, "address")