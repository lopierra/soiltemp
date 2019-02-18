## Get soil temp data for shiny app


library(tidyverse)
library(tabulizer)
library(here)

# Use tabulizer package to extract table from PDF (first saved as a file from https://extension.oregonstate.edu/sites/default/files/documents/12281/soiltemps.pdf)
# [in future could also use `download.file` to get the PDF directly from the website]
# Output will be a data frame, but as a the first element in a list -> needs to be subsetted

soil_temp_data <- extract_tables(here("oregonstate.pdf"), pages = 1, output = "data.frame") %>% 
  .[[1]]

# Rename column headers, delete 1st row

colnames(soil_temp_data) <- c("crop", "min", "opt_range", "opt_temp", "max")
soil_temp_data <- soil_temp_data[-1,]

# Remove min and max columns since I won't be using those

soil_temp_data <- select(soil_temp_data, -min, -max)

# Split the opt_range column into 2

soil_temp_data <- separate(soil_temp_data, opt_range, sep = "-", c("opt_min", "opt_max"))

# Get germination data from page 2 of PDF

germination_wide <- extract_tables(here("oregonstate.pdf"), pages = 2, output = "data.frame") %>% 
  .[[1]]

# Split column 2 into 6

germination_wide <- separate(germination_wide, 2, sep = " ", c("32", "41", "50", "59", "68", "77"))

# use first row as column headers, then remove first row

colnames(germination_wide) <- germination_wide[1,]
germination_wide <- germination_wide[-1,]

# gather into tidy format, convert soil_temp to numeric

germination <- germination_wide %>% 
  gather(key = "ref_temp", value = "germ_time", 2:10) 

germination$ref_temp <- as.numeric(germination$ref_temp)

