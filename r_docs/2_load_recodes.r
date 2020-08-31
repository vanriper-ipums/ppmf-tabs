# 2_load_recodes.r
# Author: David Van Riper
# Created: 2020-06-30
# 
# This script loads the required recode files for the ppmf variables.

require(data.table)
require(tidyverse)

file_path <- "data/recodes/"
file_list <- list.files(file_path)

#### Col classes #### 
recode_col_classes <- c("character", "integer")
recode_col_classes_tally <- c("character", "integer", "integer", "integer", "integer", "integer", "integer")

#### Load in recodes ####
for(i in file_list){
  # create output df name
  j <- str_split(i, "\\.")
  dt_name <- j[[1]][1]
  
  if(str_detect(dt_name, "age")){
    x <- fread(paste0(file_path, i))
  } else if(str_detect(dt_name, "racesTally_alone")){
    x <- fread(paste0(file_path, i), colClasses = recode_col_classes_tally)
  } else{ 
    x <- fread(paste0(file_path, i), colClasses = recode_col_classes)
  }
  # read in i to a dt
#  dt <- fread(paste0(file_path, i), colClasses = recode_col_classes)
  
  # assign dt_name to dt
  assign(dt_name, x)
}

#### Clean up dt and lists #### 
rm(j)
rm(x)
