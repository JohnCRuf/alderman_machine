last_keyword_position <- function(x) {
  keyword_positions <- unlist(str_locate_all(tolower(x), "(\\bschool\\b|\\bpark\\b|\\bcenter\\b|\\bfield\\b)"))
  if (length(keyword_positions) == 0) {
    return(as.integer(NA))
  }
  max(keyword_positions)
}