library(terra)
library(sf)
library(dplyr)
library(openxlsx)
library(stringr)

# --- CONFIGURATION ---
base_folder <- "I:/_Weather_Data/NRCAN_FWIS_Database"
shapefile <- "S:/2129/1/03_MappingAnalysisData/01_ArcMapProjects/Nima_Mapping/Weather.Point.shp"
output_excel <- "C:/Users/nkarimi/Desktop/Weather_WS_WD_ISI_FWI_2014_2024.xlsx"
years <- 2014:2024
vars <- c("ws", "wd", "isi", "fwi")

# --- LOAD POINT ---
point_sf <- st_read(shapefile, quiet = TRUE)
point <- point_sf[1, ]
point_crs <- st_crs(point)

# --- FUNCTION TO EXTRACT ONE VARIABLE OVER ALL YEARS ---
extract_variable <- function(var) {
  all_rows <- list()
  
  for (year in years) {
    folder <- file.path(base_folder, var)
    files <- list.files(folder, pattern = paste0("^", var, year, ".*\\.tif$"), full.names = TRUE)
    
    if (length(files) == 0) {
      cat("⚠️ No files found for", var, "in", year, "\n")
      next
    }
    
    for (f in files) {
      date_str <- str_extract(basename(f), "\\d{8}")
      date <- tryCatch(as.Date(date_str, "%Y%m%d"), error=function(e) NA)
      if (is.na(date)) next
      
      rast <- tryCatch(rast(f), error=function(e) NULL)
      if (is.null(rast)) next
      if (is.na(crs(rast))) crs(rast) <- "EPSG:3978"
      
      point_proj <- if (st_crs(rast) != point_crs) st_transform(point, crs(rast)) else point
      
      val <- tryCatch(terra::extract(rast, vect(point_proj))[,2], error=function(e) NA)
      if (is.null(val) || is.na(val) || val < -1e20) val <- NA
      
      all_rows[[length(all_rows) + 1]] <- data.frame(Date = date, Value = val)
    }
  }
  
  if (length(all_rows) == 0) {
    return(data.frame(Date = as.Date(character()), Value = numeric()))
  }
  
  df <- do.call(rbind, all_rows)
  names(df)[2] <- toupper(var)
  return(df)
}

# --- EXTRACT EACH VARIABLE SEPARATELY ---
cat("🔄 Extracting wind speed (WS)...\n")
ws_df <- extract_variable("ws")

cat("🔄 Extracting wind direction (WD)...\n")
wd_df <- extract_variable("wd")

cat("🔄 Extracting Initial Spread Index (ISI)...\n")
isi_df <- extract_variable("isi")

cat("🔄 Extracting Fire Weather Index (FWI)...\n")
fwi_df <- extract_variable("fwi")

# --- COMBINE ALL BY DATE ---
combined <- ws_df %>%
  full_join(wd_df, by = "Date") %>%
  full_join(isi_df, by = "Date") %>%
  full_join(fwi_df, by = "Date") %>%
  arrange(Date)

# --- ADD YEAR & SEASON ---
combined <- combined %>%
  mutate(
    Year = format(Date, "%Y"),
    Season = case_when(
      format(Date, "%m%d") >= "0401" & format(Date, "%m%d") <= "0614" ~ "Spring",
      format(Date, "%m%d") >= "0615" & format(Date, "%m%d") <= "1101" ~ "Summer/Fall",
      TRUE ~ NA_character_
    )
  )

# --- SAVE TO EXCEL ---
write.xlsx(combined, output_excel, overwrite = TRUE)
cat("✅ Combined weather variables saved to:", output_excel, "\n")
