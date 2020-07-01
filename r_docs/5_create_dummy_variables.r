# 5_create_dummy_variables.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script adds dummy variables to the dt. The script concatenates the header* data frames 
# into one large df, and then extracts the header names into a character vector. The headers 
# (variables) are then added to the dt and initialized to 0.

require(data.table)
require(tidyverse)

#### Get list of header* dfs #### 
header_list <- mget(ls(pattern = "header*"))

#### Bind list into single df ###
headers <- bind_rows(header_list)

#### Extract var codes (from header column) into a character vector ####
vars <- headers$header

#### Add vars to dt and set all equal to zero #### 
dt[, (vars) := 0]

#### Clean up the unneeded dfs ####
rm(header_list)
rm(headers)


