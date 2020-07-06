# 7_fix_p9_p11.r
# Author: David Van Riper
# Created: 2020-07-05
# 
# This script fixes up tables P9 and P11. Table P9 requires the following:
# 
# 1. Add in Hispanic/Latino total population
# 2. Correct H73003 and H73004 sums
# 
# Table P11 requires the following:
# 
# 1. Add in the Total Population age 18 and older
# 2. Compute the Hispanic age 18 and older pop (subtract Non Hispanic total from overall total)
# 
# This is a hack job for the time being! 


require(data.table)

#### Source the correct_column_order.r script #### 
source("r_docs/correct_column_order.r")

#### Constant "character" vector #### 
char_all <- rep("character", 4)
geog_vars <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")

#### Create vector if "integer" values #### 
#int_p1_p3 <- rep("integer", 8)
int_p4 <- rep("integer", 3)
int_p9 <- rep("integer", 69)
int_p10 <- rep("integer", 71)
int_p11 <- rep("integer", 69)
#int_p5 <- rep("integer", 14)

#### Column classes ####
#col_classes_p1_p3 <- c(char_all, int_p1_p3)
col_classes_p4 <- c(char_all, int_p4)
col_classes_p9 <- c(char_all, int_p9)
col_classes_p10 <- c(char_all, int_p10)
col_classes_p11 <- c(char_all, int_p11)
#col_classes_p5 <- c(char_all, int_p5)

#### Load data in using correct col_classes #### 
p4 <- fread("data/output/block_p4.csv", colClasses = col_classes_p4)
p9 <- fread("data/output/block_p9.csv", colClasses = col_classes_p9)
p10 <- fread("data/output/block_p10.csv", colClasses = col_classes_p10)
p11 <- fread("data/output/block_p11.csv", colClasses = col_classes_p11)

#### Set keys on geog_vars for three data.tables #### 
setkeyv(p4, geog_vars)
setkeyv(p9, geog_vars)
setkeyv(p10, geog_vars)
setkeyv(p11, geog_vars)

#### P9 #### 
# This section fixes up P9

#### Correct a couple of sums in P9 ####
# Pop of 1 race
p9[, H73004_dp := H73005_dp + H73006_dp + H73007_dp + H73008_dp + H73009_dp + H73010_dp]
# Non-Hispanic total 
p9[, H73003_dp := H73004_dp + H73011_dp]

#### Join P4 to P9 to get the correct Hispanic total ####
p9 <- p4[p9]

#### Rename variables #### 
temp_from <- c("H7Y001_dp", "H7Y003_dp")
temp_to <- c("H73001_dp", "H73002_dp")

#### Set names for P9 ####
setnames(p9, temp_from, temp_to)

#### Remove H7Y003_dp from dt #### 
p9[, H7Y002_dp := NULL]

#### Set correct column order for P9 #### 
setcolorder(p9, cols_p9)

# Write out to CSV for further processing
fwrite(p9, file = "data/output/block_p9.csv")

#### P11 ####
# This section fixes up table P11

#### Keep total pop > 18 from P10 #### 
p10_var <- c(geog_vars, "H74001_dp")
p10 <- p10[, ..p10_var]

#### Correct a couple of sums in P11 ####
# Pop of 1 race
p11[, H75004_dp := H75005_dp + H75006_dp + H75007_dp + H75008_dp + H75009_dp + H75010_dp]
# Non-Hispanic total 
p11[, H75003_dp := H75004_dp + H75011_dp]

#### Join P10 to get total pop >= 18 #### 
p11 <- p10[p11]

#### Change H74001_dp to H75001_dp #### 
setnames(p11, "H74001_dp", "H75001_dp")

#### Compute Hispanic/Latino >= 18 years #### 
p11[, H75002_dp := H75001_dp - H75003_dp]

#### Re-order P11 columns #### 
setcolorder(p11, cols_p11)

#### Write out to CSV #### 
fwrite(p11, file = "data/output/block_p11.csv")

