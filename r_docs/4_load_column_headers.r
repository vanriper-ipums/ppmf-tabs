# 4_load_column_headers.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script loads the column header CSVs into tibbles

require(tidyverse)

#### Load column headers #### 
header_hisp <- read_csv("data/headers/header_hisp.csv")
header_sex <- read_csv("data/headers/header_sex.csv")
header_race7 <- read_csv("data/headers/header_race7.csv")

