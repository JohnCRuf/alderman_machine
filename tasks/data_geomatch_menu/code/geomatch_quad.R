library(tidyverse)
library(sp)
library(rgdal)
library(lwgeom)
library(sf)
source("geomatch_points_fn.R")
source("geomatch_lines_fn.R")
source("geomatch_shapes_fn.R")
source("map_data_prep_fn.R")
source("geomatch_data_prep_fns.R")
ARGS<- commandArgs(trailingOnly = TRUE)
df <- read_csv("../input/geocoded_quad_df.csv")
#replace all non-numeric lat_1, lat_2, lat_3, lat_4, lon_1, lon_2, lon_3, lon_4 with NA
df <- convert_lat_lon_to_na(df)
#create df for cases where there is only one unique lat-lon pair
df_points<- unique_pairs_filter(df, 1, GEQ = FALSE)

df <- df %>%
    anti_join(df_points)

#create new variables lat and long that is the only unique lat-lon pair
df_points <- extract_unique_lat_lon(df_points)

#load either 2003-2011 or 2012-2022 precinct shapefile
map <- map_load(ARGS[1])

#feed single addresses into geomatch_single_coordinate
df_points_matched <-geomatch_single_coordinate(df_points, map, 4326)
write_csv(df_points_matched, ARGS[2])


#Now to move on to lines within the df
df_line <- unique_pairs_filter(df, 2, GEQ = FALSE)

df<- df %>%
    anti_join(df_line)


df_line <- df_line %>%
  rowwise() %>%
  mutate(
    all_lats = list(c_across(starts_with("lat_"))[!is.na(c_across(starts_with("lat_")))]),
    all_lons = list(c_across(starts_with("lon_"))[!is.na(c_across(starts_with("lon_")))]),
    lat_A = ifelse(length(all_lats) >= 1, all_lats[[1]], NA_real_),
    lon_A = ifelse(length(all_lons) >= 1, all_lons[[1]], NA_real_),
    lat_B = ifelse(length(all_lats) >= 2, all_lats[[2]], NA_real_),
    lon_B = ifelse(length(all_lons) >= 2, all_lons[[2]], NA_real_)
  ) %>%
  select(-all_lats, -all_lons) %>%
  ungroup()


df_line_sf <- create_sf_lines(df_line, "lat_A", "lon_A", "lat_B", "lon_B", 4326)

df_line_matched <- geomatch_lines(df_line_sf, map, 10)

df_line_matched <- df_line_matched %>%
 mutate(total_length = as.double(total_length),
        intersect_length = as.double(intersect_length)) %>%
 arrange(desc(total_length)) %>%
 select(-total_length, -intersect_length) 
write_csv(df_line_matched, ARGS[3])

df_shape <- unique_pairs_filter(df, 3, GEQ = TRUE)
df_shape_sf <- create_sf_geometry(df_shape, "lat", "lon", 4326)

df_shape_geomatched <- geomatch_shapes(df_shape_sf, map, 200)
#convert areas to numeric
df_shape_geomatched <- df_shape_geomatched %>%
 mutate(total_area = as.double(total_area),
        intersect_area = as.double(intersect_area)) %>%
 arrange(desc(total_area))

write_csv(df_shape_geomatched, ARGS[4])