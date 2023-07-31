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
