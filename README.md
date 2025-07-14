# Wildfire Risk Assessment for Esgenoôpetitj and Tabusintac

This repository contains the core scripts and methodology used to support the wildfire risk assessment for the communities of Esgenoôpetitj and Tabusintac. The assessment combines fuel hazard data, building exposure proximity, and fire weather parameters to identify priority areas for mitigation, viable ember pathways, and community-specific fire vulnerability.

## Overview and Definitions

This project comprises three main components:

### 1. Fire Exposure and Directional Vulnerability

**Fire Exposure (FE)** refers to the relative concentration of hazardous fuels in the surrounding landscape, calculated as a continuous raster from 0 to 1. The metric reflects the likelihood of ember transmission toward a location, based on fuel type and distance.

**Directional Vulnerability** identifies the most viable directions from which a wildfire may reach a community or point of interest. It uses radial transects to determine directional pathways through continuous high-exposure areas.

### 2. Building Exposure Load (BEL)

**Building Exposure Load** quantifies the number of structure footprints located within a fixed buffer (500 meters) of each hazardous fuel patch. Higher BEL values indicate a greater potential impact area, useful for ranking treatment priorities.

### 3. Fire Weather and Windrose Analysis

This component examines long-term fire weather patterns, including wind direction, wind speed, Fire Weather Index (FWI), and Initial Spread Index (ISI), based on daily raster datasets. Seasonal summaries are visualized through windrose diagrams to assess alignment between weather trends and directional fire threat.

## Technical Workflow

The technical workflow documented here follows the methodology outlined in the full analysis and includes the following sections.

---

## 1. Fire Exposure Analysis

Fire Exposure (FE) was calculated using a continuous hazard raster representing the probability of ember transmission based on fuel type and distance. A directional component was added to identify high-exposure corridors by applying radial transects.

### 1.1 `fire_exp_dir_custom.R` – Custom Directional Exposure Function

This function extends the base `fireexposuR` package (https://github.com/ropensci/fireexposuR) by computing directional vulnerability from any given location. It operates as follows:

- Generates 360° radial transects from a point or polygon
- Divides each transect into four segments
- Evaluates viability if at least 80% of a transect overlaps areas with fire exposure ≥ 0.6

The function returns spatial line features indicating direction and exposure classification. It is designed for use in directional vulnerability assessments where fuel arrangement and ember travel routes are of interest.

### 1.2 `FireExposure_BurntChurch.R` – Execution Script

This script applies the fire exposure and directional vulnerability analysis by:

- Loading the hazard raster and community point shapefile
- Verifying spatial alignment and transforming coordinate systems if needed
- Calling the `fire_exp()` function from the `fireexposuR` package
- Sourcing the custom directional function
- Generating and exporting individual shapefiles of viable fire pathways
- Exporting the full fire exposure raster

**Outputs:**
- `fire_exposure.tif`: Continuous raster of fire exposure values
- `dir_exposure_point_X.shp`: Directional shapefiles for each community point

---

## 2. Building Exposure Load (BEL) Calculation

Building Exposure Load measures the number of structure footprints located within a 500-meter buffer of each hazardous fuel patch. This information is critical in assessing the relative importance of fuel units for mitigation.

### 2.1 `BEL_Calculation.R` – Spatial Buffer Analysis

The script performs the following tasks:

- Loads a hexagon shapefile representing hazardous fuel units
- Loads building footprint data for Esgenoôpetitj and Tabusintac
- Reprojects all layers to EPSG:3347 for accurate distance measurement
- Calculates the number of building points within 500 meters of each hexagon centroid
- Assigns the count to a new `BEL` field
- Saves the updated shapefile with the new attribute

**Output:**
- `Hazard_Fuel_Units_proj.shp`: Updated fuel unit layer with BEL values per hexagon

---

## 3. Fire Weather and Windrose Analysis

This analysis is composed of three scripts that extract, clean, and visualize daily fire weather data spanning 2014 to 2024.

### 3.1 `Weather_value_generation_for_point_NRCAN.R` – Data Extraction

This script extracts wind speed (WS), wind direction (WD), ISI, and FWI from raster files for a specified location. It:

- Defines paths to NRCAN raster folders by variable and year
- Loads a shapefile point for extraction
- Reprojects the point to match raster CRS (EPSG:3978)
- Extracts raster values for each day and variable
- Joins extracted tables into a unified dataset
- Adds date-based Year and Season fields

**Output:**
- `Weather_WS_WD_ISI_FWI_2014_2024.xlsx`: Multi-year Excel file with daily weather variables

### 3.2 `Weather_value_generation_for_point_NRCAN_cleaning.R` – Data Cleaning

This script prepares the dataset for seasonal visualization by removing incomplete records. It:

- Loads the Excel output from Section 3.1
- Removes rows with missing WS, WD, ISI, FWI, or Season values
- Saves the cleaned version for analysis

**Output:**
- `Weather_WS_WD_ISI_FWI_2014_2024_COMPLETE.csv`: Cleaned CSV file ready for plotting

### 3.3 `Windrose_generation_weather_data.R` – Windrose Visualization

This script visualizes the cleaned dataset through windrose plots that show frequency and intensity of fire-related weather by direction. It:

- Loads the cleaned CSV
- Prepares two datasets: one for FWI and one for ISI
- Defines classification breaks and color schemes
- Generates windroses for Spring and Summer/Fall periods
- Saves each plot as a PNG image

**Outputs:**
- `windrose_spring_fwi.png`
- `windrose_spring_isi.png`
- `windrose_summer_fall_fwi.png`
- `windrose_summer_fall_isi.png`

These plots help align dominant fire weather directions with mapped directional vulnerabilities and inform planning for fuel treatment and suppression resources.

---

## Repository Contents

All code scripts are located in the `/scripts` directory. Each file corresponds to one step in the analysis process, and filenames are referenced in the sections above.

Supplementary files, such as figures and shapefiles, are not stored in this repository due to size constraints but are referenced by path in each script.

This repository serves as a transparent, reproducible codebase for the wildfire exposure analysis conducted for the communities of Esgenoôpetitj and Tabusintac.

