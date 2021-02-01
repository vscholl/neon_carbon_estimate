# Filter AOP tiles based on UTM coordinates:
# NEON AOP mosaic tiles are delivered in 1km x 1km tiles
# named based on the coordinate of their lower left corner.
# Sometimes I only want a certain subset of tiles to cover 
# a geographic range of interest. This script filters a collection of 
# image tiles based on a UTM coordinate extent of interest.
# 
# 02/01/21 

library(here)
library(dplyr)
library(tidyr)
library(filesstrings)

# directory containing image files to filter
input_dir <- here::here("niwo_rgb_tiles_2020/")
  
# directory to move the selected files 
output_dir <- here::here("niwo_rgb_tiles_2020_filtered")

# UTM coordinates of interest 
easting_min <- 448000
easting_max <- 454000
northing_min <- 4430000
northing_max <- 4434600

# list all files in the input directory 
image_names <- list.files(path = input_dir, pattern = ".tif")

# parse the easting and northing coordinate (representing the lower left corner)
# of each image 
df <- data.frame(image_name = image_names) %>%
        tidyr::separate(image_name, # separate the strings in this column
                        sep = "_",  # using an underscore separator
                        # don't keep the first 3 items, but keep the next 2 in 
                        # columns named "easting" and "northing"
                        into = c(NA, NA, NA, "easting", "northing"), 
                        # drop any extra parsed strings after the cols of interest
                        extra = "drop",
                        # don't remove the input column from the data frame
                        remove = FALSE)

# convert the numbers to strings 
df$easting <- as.numeric(df$easting)
df$northing <- as.numeric(df$northing)

df <- df %>% 
  filter((easting >= easting_min) & (easting <= easting_max) & 
           (northing >= northing_min & northing <= northing_max))

# if it doesn't already exist, create the output directory 
if(!dir.exists(output_dir)){
  dir.create(output_dir)
}

# move the tiles of interest into the output directory 
for(i in 1:nrow(df)){
  file.move(file.path(input_dir, df$image_name[i]),
            file.path(output_dir))
}
