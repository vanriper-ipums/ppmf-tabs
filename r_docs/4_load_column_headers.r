# 4_load_column_headers.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script loads the column header CSVs into tibbles, looping over all files in /data/headers directory.

require(tidyverse)

file_path <- "data/headers/"
file_list <- list.files(file_path, pattern = "^header_nhgis")

#### Load in header CSVs and assign to data frames ####
for(i in file_list){
  # create output df name
  j <- str_split(i, "\\.")
  df_name <- j[[1]][1]
  df_name <- str_remove(df_name, "_nhgis")
  
  # read in header file 
  df <- read_csv(paste0(file_path, i))
  
  # assign df_name to df
  assign(df_name, df)
  
}

#### Clean up ####
rm(df)
rm(j)

#### Load column headers #### 
# header_hisp <- read_csv("data/headers/header_nhgis_hisp.csv")
# header_sex <- read_csv("data/headers/header_nhgis_sex.csv")
# header_race7 <- read_csv("data/headers/header_nhgis_race7.csv")
# header_hisp_race7 <- read_csv("data/headers/header_nhgis_hisp_race7.csv")
# header_major_gqtype <- read_csv("data/headers/header_nhgis_major_gqtype.csv")
# header_race63 <- read_csv("data/headers/header_nhgis_race63.csv")
# header_race63_voting_age <- read_csv("data/headers/header_nhgis_race63_voting_age.csv")
# header_hisp_race63 <- read_csv("data/headers/header_nhgis_hisp_race63.csv")
# header_hisp_race63_voting_age <- read_csv("data/headers/header_nhgis_hisp_race63_voting_age.csv")
# header_sex_age12 <- read_csv("data/headers/header_nhgis_sex_age_p12.csv")


