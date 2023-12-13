#create a function that filters a dataframe to only rows where type contains an inputted regex ignoring case
filter_type <- function(df, regex) {
    df_2 <- df %>%
        filter(str_detect(type, regex))
    return(df_2)
    }

generate_regex<- function(input_string) {
    #if input string is "alley_sidewalks", return "alley|sidewalk"
    if (input_string == "alley_sidewalks") {
        return("(?i)alley|sidewalk")
    }
    #if input string is "resurfacing", return "resurfacing"
    if (input_string == "resurfacing") {
        return("(?i)resurfacing")
    }
    #if input string is lights, return "light"
    if (input_string == "lights") {
        return("(?i)light")
    }
    #if input string is "misc", return "misc"
    if (input_string == "misc") {
        return("(?i)misc")
    }
    #if input string is "park", return "park"
    if (input_string == "beaut") {
        return("(?i)|fountain| park|play|garden|field|trail|mural|tree|bench|decor")
    }
    #if input string is "camera", return "camera"
    if (input_string == "camera") {
        return("(?i)camera")
    }
    #if input string is streets return "street|curb|bollard|hump|sign"
    if (input_string == "streets") {
        return("(?i)street|curb|gutter|bollard|hump|sign|parking")
    }
}