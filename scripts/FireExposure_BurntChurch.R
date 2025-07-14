# Load necessary libraries
if (!require(pacman)) install.packages("pacman")
pacman::p_load(fireexposuR, terra, MultiscaleDTM, devtools, tidyterra, geosphere, ggspatial, maptiles)

# Path to your hazard map and point shapefile
hazard_file_path <- "S:/2129/1/03_MappingAnalysisData/01_ArcMapProjects/Nima_Mapping/FBP_50KM_Hazard.tif"
points_file_path <- "S:/2129/1/03_MappingAnalysisData/01_ArcMapProjects/Nima_Mapping/Community_Points.shp"

# Load hazard map (raster)
hazard <- terra::rast(hazard_file_path)
print(hazard)

# Load point shapefile (Community Points)
points <- terra::vect(points_file_path)
print(points)

# Check CRS for both layers (should match WGS 1984 / EPSG:4326)
print(crs(hazard))
print(crs(points))

# If CRS does not match, transform points to match the hazard map CRS
if (crs(hazard) != crs(points)) {
  points <- terra::project(points, crs(hazard))
  print(crs(points))  # Confirm transformation
}

# Plotting to visually check alignment
plot(hazard, main = "Hazard Map")
plot(points, add = TRUE, col = "red", pch = 16)

# Compute fire exposure with long-range transmission distance
exposure <- fire_exp(hazard, tdist = "l")
print(exposure)

# Plot exposure map
plot(exposure, main = "Fire Exposure Map")
plot(points, add = TRUE, col = "blue", pch = 16)

# Source custom directional exposure function
source("C:/Users/nkarimi/Desktop/NimaKarimi.repo/fire_exp_dir_custom.R")

# Compute directional exposure for each point
for (i in 1:nrow(points)) {
  this_point <- points[i, ]  # Extract individual point
  
  # Compute directional exposure for the current point
  dir_exposure <- fire_exp_dir_custom(
    exposure = exposure,
    value = this_point,
    t_lengths = c(5000, 5000, 5000, 10000),
    interval = 1,
    thresh_exp = 0.6,
    thresh_viable = 0.8
  )
  
  # Export the directional exposure for the current point
  output_dir_exposure <- paste0("S:/2129/1/03_MappingAnalysisData/01_ArcMapProjects/Nima_Mapping/dir_exposure_point_", i, ".shp")
  if (file.exists(output_dir_exposure)) {
    file.remove(output_dir_exposure)  # Delete existing file if necessary
  }
  terra::writeVector(dir_exposure, output_dir_exposure, overwrite = TRUE)
  
  # Plot the directional exposure map for the current point
  plot(dir_exposure, main = paste("Directional Exposure Map for Point", i))
  plot(this_point, add = TRUE, col = "red", pch = 16)
  
  cat(paste("Directional exposure map for Point", i, "exported successfully!\n"))
}

# Export fire exposure raster
output_exposure <- "S:/2129/1/03_MappingAnalysisData/01_ArcMapProjects/Nima_Mapping/fire_exposure.tif"
if (file.exists(output_exposure)) {
  file.remove(output_exposure)  # Delete existing file if necessary
}
terra::writeRaster(exposure, output_exposure, overwrite = TRUE)

cat("Fire exposure raster exported successfully!")