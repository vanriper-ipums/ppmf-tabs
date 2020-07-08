# 10_split_blocks_into_states.r
# Author: David Van Riper
# Created: 2020-07-08
# 
# This script reads in the block_20200527.csv, splits into state specific files and writes each state out 
# to a CSV. 

require(data.table)
require(tidyverse)

#### Constants ####
xwalk_file <- "data/state_code_xwalk.csv"
data_file_path <- "data/output/"
file <- "block_20200527.csv"

#### Load data and crosswalk #### 
dt <- fread(paste0(data_file_path, file))
xwalk <- read_csv(xwalk_file, col_types = "ic")

#### Loop over dt selecting out each state #### 
for(row in 1:nrow(xwalk)){
  
  # select out a single state's worth of blocks
  x <- dt[state == xwalk$code[row],]
  
  # write out to CSV 
  out_file <- paste0(data_file_path, "block_", tolower(xwalk$abb[row]), "_20200527.csv")
  fwrite(x, out_file)

  #assign(xwalk$abb[row], x)
  #  dt[, header_race7$header[row] := fifelse(race7 == header_race7$recode[row], 1, 0)]
}

#### Clean up dts before writing out to CSVs #### 
rm(dt)
rm(x)
rm(xwalk)


