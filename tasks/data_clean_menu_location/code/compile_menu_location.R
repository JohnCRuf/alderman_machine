library(tidyverse)

#compile point data
point_list <- c("../temp/leftover_df.csv", "../temp/intersection_df.csv", "../temp/school_park_df.csv", "../temp/normal_address_df.csv")
#for load, clean, and append
point_df <- data.frame()
for (i in 1:length(point_list)) {
  df <- read_csv(point_list[i])
  point_df <- rbind(point_df, df)
}

#compile line data
line_list <- c("../temp/and_dash_df.csv", "../temp/df_with_2_ands.csv", "../temp/from_to_df.csv", "../temp/double_dash_to_df.csv", "../temp/through_address_df.csv")
line_df <- data.frame()
for (i in 1:length(line_list)) {
  df <- read_csv(line_list[i])
  line_df <- rbind(line_df, df)
}

#compile quadrilateral data
quad_list <- c("../temp/df_with_3_ands.csv")
quad_df <- data.frame()
for (i in 1:length(quad_list)) {
  df <- read_csv(quad_list[i])
  quad_df <- rbind(quad_df, df)
}

#compile pentagon data
pent_list <- c("../temp/df_with_mult_ands.csv")
pent_df <- data.frame()
for (i in 1:length(pent_list)) {
  df <- read_csv(pent_list[i])
  pent_df <- rbind(pent_df, df)
}

#write to csv
write_csv(point_df, "../output/menu_data_point.csv")
write_csv(line_df, "../output/menu_data_line.csv")
write_csv(quad_df, "../output/menu_data_quad.csv")
write_csv(pent_df, "../output/menu_data_pent.csv")
