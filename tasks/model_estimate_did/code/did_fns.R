apply_election_times <- function(df, post_treat_years, wards_selection, treated_wards){
    if (length(post_treat_years) == 3) {
        df_output <- df %>%
            filter(ward %in% wards_selection) %>%
            mutate(treated = ifelse(ward %in% treated_wards & year >= post_treat_years[1], 1, 0),
                treated_1 = ifelse(ward %in% treated_wards & year >= post_treat_years[2], 1, 0),
                treated_2 = ifelse(ward %in% treated_wards & year >= post_treat_years[3], 1, 0),
                first_treat = ifelse(ward %in% treated_wards, post_treat_years[1], 0))
    }
    else {
        stop("post_treat_years must be a vector of length 3 or 4")
    }
    return(df_output)
}

select_wards <- function(df, year_selected){
ward_vector <-  df %>%
                filter(year==year_selected) %>%
                select(ward) %>%
                pull()
return(ward_vector)
}

select_treated_wards <- function(df, year_selected){
ward_vector <-  df %>%
                filter(year==year_selected) %>%
                filter(treated==1) %>%
                select(ward) %>%
                pull()
return(ward_vector)
}

did_remove_double_treat <- function(list_1, list_2, list_3) {
    #remove all wards listed in 2 or more close_runoff_wards_treated lists
    list_1 <- list_1[!list_1 %in% list_2]
    list_1 <- list_1[!list_1 %in% list_3]
    list_2 <- list_2[!list_2 %in% list_1]
    list_2 <- list_2[!list_2 %in% list_3]
    list_3 <- list_3[!list_3 %in% list_1]
    list_3 <- list_3[!list_3 %in% list_2]
    return(c(list_1, list_2, list_3))
}