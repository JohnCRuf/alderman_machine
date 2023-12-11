# Border discontinuity generate placebo maps

    This task generates placebo maps for the border discontinuity analysis. This task uses the census block maps, and then chooses a set of 50 random blocks to be ``seed'' blocks, one for each of the 50 wards. 
    Then I deploy a flood-fill algorithm to grow each seed into a ward by randomly selecting an adjacent block and adding it to the ward.

    I do this 100 times and aggregate the results to a single .RDA file.


## Outputs
- `placebo_maps.rda`: 100 randomly-generated ward maps.

## Code
- `generate_ward_maps.R`: R script to generate the ward maps.
- `flood_fill_functions.R`: R script with functions to perform the flood-fill algorithm.

## Inputs
- `block_map_2010.rds`: Census block map.

This task takes ~ 90 computational hours to run serially. I ran it in 15 hours using 6 cores on a Framework laptop. I recommend using a server if you have access to one.