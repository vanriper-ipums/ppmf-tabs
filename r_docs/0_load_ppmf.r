# 0_load_ppmf.r
# Author: David Van Riper
# Created: 2020-06-30
# 
# This script loads the ppmf microdata file into a data.table. The initial version of this script was 
# written to support the microdata released on 2020-07-01. 
# 

require(data.table)

#### Define constants #### 
# ppmf column types
ppmf_col_classes <- c("character", "character", "character", "character", "character", "character", "character", "character", "character", "integer", "character", "character")

#### Load ppmf to a dt #### 
dt <- fread("data/ppmf.csv", sep = ",", colClasses = ppmf_col_classes)
