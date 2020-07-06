# 1_load_nhgis_blocks.r
# Author: David Van Riper
# Created: 2020-06-30
# 
# This script loads the IPUMS NHGIS 2010 census block file into a data.table. The block file will 
# be used to merge in additional geographic variables to the privacy-protected microdata file. 

require(data.table)

#### Constants ####
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

#### Read in NHGIS block CSV as data.table ####
# We only need colClasses in fread because NHGIS already has column headers in the CSV.  
dt_nhgis <- fread("data/nhgis1329_ds172_2010_block.csv", sep = ",", colClasses = nhgis_col_classes)

#### Delete fields that we're not using now #### 
delete_nhgis_vars <- c("YEAR", "REGIONA", "DIVISIONA", "STATE", "COUNTY", "CONCITA", "RES_ONLYA", "TRUSTA", "AITSCEA", "TTRACTA", "TBLKGRPA", "METDIVA", "CSAA", "NECTAA", "NECTADIVA", "CNECTAA", "URBRURALA", "ZCTA5A", "SUBMCDA", "SDELMA", "SDSECA", "SABINSA", "NAME", "H7V001")

dt_nhgis[, (delete_nhgis_vars) := NULL]

#### Set name for GISJOIN to gisjoin ####
setnames(dt_nhgis, "GISJOIN", "gisjoin")

#### Set key for dt_nhgis data.table #### 
setkey(dt_nhgis, gisjoin)
