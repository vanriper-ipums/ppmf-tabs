# 4_load_column_headers.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script loads the column header CSVs into data.tables

require(data.table)

#### Load column headers #### 
header_hisp <- fread("data/headers/header_hisp.csv")
header_sex <- fread("data/headers/header_sex.csv")
header_race7 <- fread("data/headers/header_race7.csv")

