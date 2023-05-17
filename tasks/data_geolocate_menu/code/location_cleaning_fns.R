double_dash_to_clean <- function(df) {
    output_df <- df %>% 
        mutate(#removing chicago coordinates that confuse geolocator API
                location_2 = str_replace_all(location, "\\(.*\\)", ""),
                main_street = str_extract(location_2, "^[^--]+"),
                from_street = str_extract(location_2, "(?<=-- ).*(?= -to-)"),
                to_street = str_extract(location_2, "(?<=-to- ).*$"),
                from_intersection = paste0(main_street, " and ", from_int),
                to_intersection = paste0(main_street, " and ", to_int)) %>%
        select(-location_2,-main_street, -from_street, -to_street) 
    return(output_df)
}

normal_address_clean <- function(df) {
    output_df <- df %>%
        mutate(address = str_replace_all(location, "\\(.*\\)", ""))
    return(output_df)
}

school_park_clean <- function(df) {
    output_df <- df %>% #extract all text beck
        mutate(location_2 = str_replace_all(location, "\\(.*\\)", ""),
               school_park_name = str_extract(location_2, ".*(?= school| park)"))
    return(output_df)
}

addition_modifier_clean <- function(df) {
    adjusted_df <- df %>%
        mutate(location_2 = str_replace_all(location, "\\(.*\\)", ""))
    single_and_df <- adjusted_df %>%
        filter(str_detect(location_2, "&")) %>%
        mutate(intersection = location_2)
    double_and_df <- adjusted_df %>%
        filter(str_detect(location_2, "&") %>% sum() == 2) %>%
        mutate(intersection = str_extract(location_2, ".*(?= and)"))
    triple_and_df <- adjusted_df %>%
        filter(str_detect(location_2, "&") %>% sum() == 3) %>%
        mutate(split_location = str_split(location, "&"),
            cardinal_vector = str_c(str_extract(split_location, "[N|S|E|W]"), collapse = ",")
        ) %>%
        select(-split_location) 
    output_df <- triple_and_df
    return(output_df)
}