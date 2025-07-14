# --- Load libraries ---
install.packages("openair")
library(openair)
library(readr)
library(dplyr)

# --- Load your cleaned CSV ---
df <- read_csv("C:/Users/nkarimi/Desktop/Weather_WS_WD_ISI_FWI_2014_2024_COMPLETE.csv")

# --- Filter and Prepare Data ---
df <- df %>%
  filter(!is.na(WD), !is.na(FWI), !is.na(ISI), !is.na(Season))

# --- Rename columns for windRose compatibility ---
df_fwi <- df %>%
  rename(ws = FWI, wd = WD)

df_isi <- df %>%
  rename(ws = ISI, wd = WD)

# --- Define thresholds and colors ---
breaks_fwi <- c(0, 5, 10, 19, 30, 100)
breaks_isi <- c(0, 2, 4, 8, 15, 100)
col_scheme <- "YlOrRd"

# --- SPRING FWI ---
spring_fwi_plot <- windRose(df_fwi %>% filter(Season == "Spring"),
                            ws = "ws", wd = "wd",
                            breaks = breaks_fwi,
                            paddle = FALSE,
                            main = "Spring Windrose (FWI)",
                            col = col_scheme,
                            key.header = "FWI",
                            key.footer = "",
                            key.position = "bottom",
                            calm = NULL)

# --- SPRING ISI ---
spring_isi_plot <- windRose(df_isi %>% filter(Season == "Spring"),
                            ws = "ws", wd = "wd",
                            breaks = breaks_isi,
                            paddle = FALSE,
                            main = "Spring Windrose (ISI)",
                            col = col_scheme,
                            key.header = "ISI",
                            key.footer = "",
                            key.position = "bottom",
                            calm = NULL)

# --- SUMMER/FALL FWI ---
sf_fwi_plot <- windRose(df_fwi %>% filter(Season == "Summer/Fall"),
                        ws = "ws", wd = "wd",
                        breaks = breaks_fwi,
                        paddle = FALSE,
                        main = "Summer/Fall Windrose (FWI)",
                        col = col_scheme,
                        key.header = "FWI",
                        key.footer = "",
                        key.position = "bottom",
                        calm = NULL)

# --- SUMMER/FALL ISI ---
sf_isi_plot <- windRose(df_isi %>% filter(Season == "Summer/Fall"),
                        ws = "ws", wd = "wd",
                        breaks = breaks_isi,
                        paddle = FALSE,
                        main = "Summer/Fall Windrose (ISI)",
                        col = col_scheme,
                        key.header = "ISI",
                        key.footer = "",
                        key.position = "bottom",
                        calm = NULL)

# --- SAVE TO PNG FILES ---
png("C:/Users/nkarimi/Desktop/windrose_spring_fwi.png", width = 800, height = 800)
print(spring_fwi_plot)
dev.off()

png("C:/Users/nkarimi/Desktop/windrose_spring_isi.png", width = 800, height = 800)
print(spring_isi_plot)
dev.off()

png("C:/Users/nkarimi/Desktop/windrose_summer_fall_fwi.png", width = 800, height = 800)
print(sf_fwi_plot)
dev.off()

png("C:/Users/nkarimi/Desktop/windrose_summer_fall_isi.png", width = 800, height = 800)
print(sf_isi_plot)
dev.off()
