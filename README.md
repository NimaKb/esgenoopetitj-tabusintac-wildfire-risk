# Wildfire Risk Assessment for Esgenoôpetitj and Tabusintac

This repository provides the technical implementation and code used in the wildfire risk analysis for Esgenoôpetitj and Tabusintac. It is structured into three major components: fire exposure and directional vulnerability, building exposure load (BEL), and seasonal fire weather and windrose analysis. All scripts referenced below are located in the `/scripts` folder.

---

## Structure of the Workflow

- **1. Fire Exposure and Directional Vulnerability**
  - 1.1 Custom function for directional fire exposure (`fire_exp_dir_custom.R`)
  - 1.2 Fire exposure analysis execution script (`FireExposure_BurntChurch.R`)
- **2. Building Exposure Load (BEL)**
  - 2.1 BEL calculation script (`BEL_Calculation.R`)
- **3. Fire Weather and Windrose Analysis**
  - 3.1 Weather data extraction from NRCAN rasters
  - 3.2 Cleaning and filtering of extracted weather data
  - 3.3 Windrose generation using FWI and ISI

---

## Key Definitions

**Fire Exposure (FE):** A raster-based representation (0 to 1) of ember propagation potential based on surrounding fuel type and distance.

**Directional Vulnerability:** Identification of spatially viable pathways where ember spread is likely to reach a community, based on the shape and continuity of hazardous fuels around a point of interest.

**Building Exposure Load (BEL):** The count of building footprints (e.g., homes) located within 500 meters of each hazardous fuel unit. Higher BEL values indicate greater potential structure impact.

---

## Wildfire Risk Assessment for Esgenoôpetitj and Tabusintac

This repository contains the core scripts and methodology used to support the wildfire risk assessment for the communities of Esgenoôpetitj and Tabusintac. The assessment combines fuel hazard data, building exposure proximity, and fire weather parameters to identify priority areas for mitigation, viable ember pathways, and community-specific fire vulnerability.

The technical workflow documented here is aligned with the analysis presented in the report titled:

**"Fire Exposure, Directional Vulnerability, and Building Exposure Load for Wildland-Urban Interface Communities"**

The methodology builds upon the `fireexposuR` package with custom extensions and includes three main components:

Fire Exposure and Directional Vulnerability is a published and reliable way to evaluate the exposure, vulnerability, and risk for different scales. To better understand the method and its details, you can visit these publications here:

1. [A simple metric of landscape fire exposure](https://doi.org/10.1007/s10980-020-01173-8)  
2. [Assessing directional vulnerability to wildfire](https://doi.org/10.1007/s11069-023-05885-3)  
3. [Optimizing fuel treatments for community wildfire mitigation planning](https://doi.org/10.1016/j.jenvman.2024.122325)
If you have any questions regarding the steps taken to generate the outcomes, please contact the author of this repository with email as nkarimi@forsite.ca
---

## 1. Fire Exposure Analysis

Fire Exposure (FE) was calculated using a continuous hazard raster representing the probability of ember transmission based on fuel type and distance. To extend this, a directional component was introduced using custom radial transects.

### 1.1 `fire_exp_dir_custom.R` – Custom Directional Exposure Function

This function extends the base `fireexposuR` model (where details about the published package can be found here: https://github.com/ropensci/fireexposuR) by calculating 360° radial transects from a point or polygon (e.g., community centroid), dividing them into four segments, and identifying which directions are viable pathways for fire transmission.

**Key Features:**
- User-defined angular interval (e.g., 1° = 360 directions)
- Classifies each segment as viable if ≥80% of its length overlaps with areas of high fire exposure (FE ≥ 0.6)
- Returns a spatial line feature with direction and viability attributes

This function supports directional vulnerability analysis, which is useful in identifying community-facing threats based purely on fuel arrangement.

### 1.2 `FireExposure_BurntChurch.R` – Fire Exposure Execution Script

This script executes the complete fire exposure analysis:

- Loads the hazard raster and community point shapefile
- Ensures spatial alignment via CRS checking
- Runs `fire_exp()` from the `fireexposuR` package
- Sources the custom function (`fire_exp_dir_custom.R`)
- Iteratively computes and exports directional viability shapefiles for each community point
- Saves the full fire exposure raster and generates plots

**Output:**
- `fire_exposure.tif`: Raster showing FE values from 0 to 1  
- `dir_exposure_point_X.shp`: Shapefiles showing viable fire approach directions

---

## 2. Building Exposure Load (BEL) Calculation

Building Exposure Load (BEL) quantifies the number of building footprints (FireSmart-classified VARs) located within a 500-meter radius of each hazardous fuel unit. This metric helps assess how “offensive” each fuel unit is, in terms of proximity to built assets.

### 2.1 `BEL_Calculation.R` – Spatial Buffer Analysis

This script performs the following:

**Loads:**
- Hexagon shapefile representing hazardous fuel patches
- Building footprints for Esgenoôpetitj and Tabusintac

**Steps:**
- Reprojects all layers to EPSG:3347 (meters) for accurate distance calculation
- Computes centroid of each hexagon
- Counts building points within 500 meters
- Assigns count to the `BEL` field
- Exports an updated shapefile with BEL values

**Output:**
- `Hazard_Fuel_Units_proj.shp`: Hexagon layer with a new field `BEL` indicating the number of nearby structures

---

## 3. Fire Weather and Windrose Analysis

### 3.1 `Weather_value_generation_for_point_NRCAN.R` – Weather Data Extraction

This script extracts daily values for WS, WD, ISI, and FWI from raster datasets (GeoTIFFs) hosted locally by variable and year. The script loops through multiple years (2014–2024) and compiles a long-term, point-based weather record for the selected community.

**Workflow:**

**Configuration:**
- Defines paths to NRCAN raster folders (organized by variable and year)
- Specifies the point location shapefile for extraction (`Weather.Point.shp`)
- Lists target variables (ws, wd, isi, fwi) and years (2014–2024)

**Point Extraction:**
- Reprojects the point if necessary to match the raster CRS (EPSG:3978)
- Iteratively extracts raster values for each day and variable
- Handles missing data and invalid values

**Compilation:**
- Joins all four variable tables (WS, WD, ISI, FWI) by date
- Adds `Year` and `Season` fields based on date formatting:
  - Spring: April 1 – June 14
  - Summer/Fall: June 15 – November 1

**Output:**
- `Weather_WS_WD_ISI_FWI_2014_2024.xlsx`: Multi-year dataset with daily values, ready for visualization and analysis

**Inputs:**
- Folder structure with GeoTIFF files named by variable and date (e.g., `ws20140515.tif`)
- Shapefile with point location of the weather extraction site

**Purpose:**
This script prepares the foundation for understanding seasonal fire weather patterns that influence fire behavior and direction. The results inform:
- Seasonal windrose analysis
- Correlation between directional vulnerability and dominant wind/fire behavior
- Justification for pre-suppression planning and fuel treatment orientation

---

### 3.2 `Weather_value_generation_for_point_NRCAN_cleaning.R` – Cleaning and Filtering Weather Data

This script refines the multi-year fire weather dataset by removing incomplete or invalid records prior to seasonal analysis and visualization. It ensures that only days with valid values for all four key variables — WS, WD, ISI, and FWI — are included in downstream analysis.

**Workflow Summary:**

**Load Excel File:**
- Reads the raw, multi-variable Excel output (`Weather_WS_WD_ISI_FWI_2014_2024.xlsx`)

**Apply Quality Filters:**
- Removes rows with missing values for:
  - Wind Speed (WS)
  - Wind Direction (WD)
  - Initial Spread Index (ISI)
  - Fire Weather Index (FWI)
  - Season classification

**Export Cleaned Dataset:**
- Saves the filtered dataset as a CSV file ready for plotting and statistical analysis:
  - `Weather_WS_WD_ISI_FWI_2014_2024_COMPLETE.csv`

**Input:**
- `Weather_WS_WD_ISI_FWI_2014_2024.xlsx`

**Output:**
- `Weather_WS_WD_ISI_FWI_2014_2024_COMPLETE.csv`

**Purpose:**
This cleaning step ensures the accuracy and consistency of the dataset used in windrose generation. Since windrose plots rely on complete daily records of wind speed and direction, this filtering step is essential to avoid misleading visualizations or statistical bias.

---

### 3.3 `Windrose_generation_weather_data.R` – Seasonal Windrose Visualization

This script generates seasonal windrose plots based on Fire Weather Index (FWI) and Initial Spread Index (ISI), using wind direction (WD) as the angular input. The script builds upon the cleaned CSV file generated in Section 3.2 and visualizes seasonal directional fire weather behavior.

**Workflow Summary:**

**Load Cleaned Weather Data:**
- Reads `Weather_WS_WD_ISI_FWI_2014_2024_COMPLETE.csv` into R

**Prepare Data for Visualization:**
- Creates two windrose-compatible data frames:
  - `df_fwi` (FWI as wind speed)
  - `df_isi` (ISI as wind speed)

**Define Binning Thresholds and Color Scheme:**
- FWI: 0–5, 5–10, 10–19, 19–30, 30+
- ISI: 0–2, 2–4, 4–8, 8–15, 15+
- Uses `"YlOrRd"` palette

**Generate Windrose Plots:**
- Produces four seasonal plots:
  - Spring FWI
  - Spring ISI
  - Summer/Fall FWI
  - Summer/Fall ISI

**Export to PNG:**
- `windrose_spring_fwi.png`
- `windrose_spring_isi.png`
- `windrose_summer_fall_fwi.png`
- `windrose_summer_fall_isi.png`

**Input:**
- `Weather_WS_WD_ISI_FWI_2014_2024_COMPLETE.csv`

**Output:**
- PNG image files for each seasonal windrose

**Purpose:**
These visualizations allow planners and analysts to:
- Understand dominant wind directions during fire seasons
- Align observed wind behavior with directional vulnerability maps
- Justify fuel treatment orientation, suppression resource prepositioning, and community-specific risk communication
