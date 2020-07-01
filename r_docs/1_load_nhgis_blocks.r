# 1_load_nhgis_blocks.r
# Author: David Van Riper
# Created: 2020-06-30
# 
# This script loads the IPUMS NHGIS 2010 census block file into a data.table. The block file will 
# be used to merge in additional geographic variables to the privacy-protected microdata file. 

require(data.table)

# Constants
nhgis_col_classes <- c("character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "character",
                       "integer")

# 0. Read in block csv to a data.table. We only need colClasses in fread because NHGIS already has 
# column headers in the CSV.  
dt <- fread("data/nhgis1329_ds172_2010_block.csv", sep = ",", colClasses = nhgis_col_classes)
