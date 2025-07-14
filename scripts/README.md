# Scripts for Wildfire Risk Assessment

## Overview

This folder contains all R scripts used in the wildfire risk assessment project for the communities of Esgenoôpetitj and Tabusintac. The scripts are organized in the same order as the project methodology, from fire exposure analysis to weather visualization. Each script is standalone and executable, assuming proper inputs and dependencies are in place.

## Script Structure

```plaintext
scripts/
├── 1_fire_exp_dir_custom.R                      # Custom directional fire exposure function
├── 1.2_FireExposure_BurntChurch.R               # Executes fire exposure and directional vulnerability analysis
├── 2.1_BEL_Calculation.R                        # Calculates Building Exposure Load (BEL)
├── 3.1_Weather_value_generation_NRCAN.R         # Extracts WS, WD, ISI, and FWI from NRCAN data
├── 3.2_Weather_cleaning.R                       # Filters missing values for windrose preparation
├── 3.3_Windrose_generation.R                    # Generates seasonal windrose plots
