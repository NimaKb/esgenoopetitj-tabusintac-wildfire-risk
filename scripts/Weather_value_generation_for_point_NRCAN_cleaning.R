library(openxlsx)
library(dplyr)

# --- LOAD FROM EXCEL ---
input_file <- "C:/Users/nkarimi/Desktop/Weather_WS_WD_ISI_FWI_2014_2024.xlsx"
df <- read.xlsx(input_file)

# --- FILTER: remove rows with any missing value ---
clean_df <- df %>%
  filter(
    !is.na(WS),
    !is.na(WD),
    !is.na(ISI),
    !is.na(FWI),
    !is.na(Season)
  )

# --- SAVE TO CSV ---
output_csv <- "C:/Users/nkarimi/Desktop/Weather_WS_WD_ISI_FWI_2014_2024_COMPLETE.csv"
write.csv(clean_df, output_csv, row.names = FALSE)

cat("✅ Cleaned CSV saved to:", output_csv, "\n")
