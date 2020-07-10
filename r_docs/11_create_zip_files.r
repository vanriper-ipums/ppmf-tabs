# 11_create_zip_files.r
# Author: David Van Riper
# Created: 2020-07-08
# 
# This script creates ZIP archives from CSV and codebook.txt
require(zip)
require(tidyverse)

#### Set file_path ####
file_path <- "data/output/"

#### Generate list of CSV files ####
file_list <- list.files(file_path, pattern = glob2rx("*.csv"))

#### Loop over file_list creating a ZIP for each ####
for(i in file_list){
  j = str_split(i, "\\.")
  zipr(paste0(file_path, j[[1]][1],".zip"), c(paste0(file_path, i), paste0(file_path, "nhgis_ppdd_20200527_codebook.txt")))
}
