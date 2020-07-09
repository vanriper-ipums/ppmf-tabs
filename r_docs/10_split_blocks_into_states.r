# 10_split_blocks_into_states.r
# Author: David Van Riper
# Created: 2020-07-08
# 
# This script reads in the nhgis_ppdd_20200527_block.csv, splits into state specific files and writes each state out 
# to a CSV. 

require(data.table)
require(tidyverse)

#### Constants ####
xwalk_file <- "data/state_code_xwalk.csv"
data_file_path <- "data/output/"
file_name_stub <- "nhgis_ppdd_20200527_"
file <- "nhgis_ppdd_20200527_block.csv"


#### Load data and crosswalk #### 
dt <- fread(paste0(data_file_path, file))
xwalk <- read_csv(xwalk_file, col_types = "ic")

#### Loop over dt selecting out each state #### 
for(row in 1:nrow(xwalk)){
  
  # select out a single state's worth of blocks
  x <- dt[state == xwalk$code[row],]
  
  # write out to CSV 
  out_file <- paste0(data_file_path, file_name_stub, "block_", xwalk$abb[row], ".csv")
  fwrite(x, out_file)
}

#### Clean up objects #### 
rm(dt)
rm(x)
rm(xwalk)


