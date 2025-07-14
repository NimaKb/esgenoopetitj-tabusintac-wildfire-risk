# Load necessary libraries
if (!requireNamespace("sf", quietly = TRUE)) install.packages("sf")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("units", quietly = TRUE)) install.packages("units")

library(sf)
library(dplyr)
library(units)

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ 1. PARAMETERS – adjust these paths if necessary                           │
# └────────────────────────────────────────────────────────────────────────────┘

# Folder where all three shapefiles live
in_folder <- "S:/2129/1/03_MappingAnalysisData/01_ArcMapProjects/Nima_Mapping/BEL_calculations"

# Original shapefile names inside that folder
orig_hex_shp <- file.path(in_folder, "Hazard_Fuel_Units.shp")
orig_esfn_shp <- file.path(in_folder, "ESFN_footpoints.shp")
orig_tabu_shp <- file.path(in_folder, "TABU_footpoints.shp")

# Output shapefile name
hex_proj_shp <- file.path(in_folder, "Hazard_Fuel_Units_proj.shp")

# Radius in meters for counting
search_radius <- set_units(500, "m")

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ 2. LOAD SHAPEFILES                                                        │
# └────────────────────────────────────────────────────────────────────────────┘

# Load the hexagon shapefile
hex_sf <- st_read(orig_hex_shp)

# Load the ESFN and TABU point shapefiles
esfn_sf <- st_read(orig_esfn_shp)
tabu_sf <- st_read(orig_tabu_shp)

# Combine ESFN and TABU points into a single dataset
all_points_sf <- bind_rows(esfn_sf, tabu_sf)

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ 3. ENSURE PROJECTION IS METER-BASED                                       │
# └────────────────────────────────────────────────────────────────────────────┘

# Define the target projection (EPSG:3347 - NAD 1983 CSRS Canada LCC)
target_crs <- 3347

# Reproject all layers to the target CRS
hex_sf <- st_transform(hex_sf, crs = target_crs)
all_points_sf <- st_transform(all_points_sf, crs = target_crs)

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ 4. CALCULATE BEL (BURN EXPOSURE LEVEL)                                    │
# └────────────────────────────────────────────────────────────────────────────┘

# Add a new column for BEL (initialize with 0)
hex_sf$BEL <- 0

# Loop through each hexagon and count points within the search radius
hex_sf <- hex_sf %>%
  rowwise() %>%
  mutate(
    BEL = sum(
      st_distance(st_centroid(geometry), all_points_sf$geometry) <= search_radius
    )
  )

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ 5. SAVE THE OUTPUT                                                        │
# └────────────────────────────────────────────────────────────────────────────┘

# Save the updated hexagon shapefile with BEL values
st_write(hex_sf, hex_proj_shp, delete_layer = TRUE)

cat("All done! Open 'Hazard_Fuel_Units_proj.shp' to inspect BEL values.\n")