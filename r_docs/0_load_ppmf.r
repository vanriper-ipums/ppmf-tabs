# 0_load_ppmf.r
# Author: David Van Riper
# Created: 2020-06-30
# 
# This script loads the ppmf microdata file into a data.table. The initial version of this script was 
# written to support the microdata released on 2020-07-01. 
# 

library(data.table)

# Constants 

# ppmf column types
ppmf_col_classes <- c("character", "character", "character", "character", "character", "character", "character", "character", "character", "integer", "character", "character")

# ppmf column names
ppmf_col_names <- c("vintage", "tabblkst", "tabblkcou", "tabtractce", "tabblkgrpce", "tabblk", "rtype", "gqtype", "qsex", "qage", "cenhisp", "cenrace")

# 0. Read in CSV to a dt 
dt <- fread("", sep = ",", colClasses = ppmf_col_classes, col.names = ppmf_col_names)
