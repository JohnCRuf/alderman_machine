arg_to_legend <- function(legend, year_1, year_2, df) {
    if (str_detect(legend, "total")) {
        df <- df %>%
            mutate(map_var = precinct_spending)
        scale_name <- paste0("Menu Spending \n", year_1, "-", year_2, "\n(thousands of dollars)")
        if (year_1 == year_2) {
            scale_name <- paste0("Menu Spending \n", year_2, "\n(thousands of dollars)")
        }
    label_name = scales::comma_format(scale = 1/1000)
    } else if (str_detect(legend, "fraction")) {
    df <- df %>%
            mutate(map_var = observed_spending_fraction)
        scale_name <- paste0("Fraction of Menu Spending \n", year_1, "-", year_2, "\n(%)")
        if (year_1 == year_2) {
            scale_name <- paste0("Fraction of Menu Spending \n", year_2, "\n(%)")
        }
    label_name = scales::percent_format(scale = 1)
    }   
return(list(df, scale_name, label_name))
}

arg_to_color <- function(color_arg, breaks) {
    if (color_arg == "viridis") {
        colors <- viridis::viridis(length(breaks) - 1, direction = -1, option = "viridis")
     } else if (color_arg == "red_blue") {
        colors <- colorRampPalette(rev(brewer.pal(n = 11, name = "RdBu")))(n_colors)
     } 
    return(colors)
}
