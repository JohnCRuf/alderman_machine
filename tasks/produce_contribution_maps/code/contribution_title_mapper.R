arg_to_legend <- function(legend, year_1, year_2, df) {
    if (str_detect(legend, "total")) {
        df <- df %>%
            mutate(map_var = contribution_spending)
        scale_name <- paste0("Campaign Contributions \n", year_1, "-", year_2, "\n(dollars)")
        if (year_1 == year_2) {
            scale_name <- paste0("Campaign Contributions \n", year_2, "\n(dollars)")
        }
    label_name = scales::comma_format(scale = 1)
    } else if (str_detect(legend, "fraction")) {
    df <- df %>%
            mutate(map_var = observed_spending_fraction)
        scale_name <- paste0("Fraction of Campaign Contributions \n", year_1, "-", year_2, "\n(%)")
        if (year_1 == year_2) {
            scale_name <- paste0("Fraction of Campaign Contributions \n", year_2, "\n(%)")
        }
    label_name = scales::percent_format(scale = 1)
    }   
return(list(df, scale_name, label_name))
}

arg_to_color <- function(color_arg, breaks) {
    if (color_arg == "red_blue") {
        colors <- colorRampPalette(rev(brewer.pal(n = 11, name = "RdBu")))(n_colors)}
    else {
        # create command that is color_arg
        viridis_color_command <- paste0("viridis::", color_arg, "( length(breaks) - 1, , direction = -1)")
        colors <- eval(parse(text = viridis_color_command))
     } 
    return(colors)
}
