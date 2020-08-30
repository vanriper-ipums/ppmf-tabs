# 0_load_ppmf.r
# Author: David Van Riper
# Created: 2020-06-30
# 
# This script loads the ppmf microdata file into a data.table. The initial version of this script was 
# written to support the microdata released on 2020-07-01. 
# 

require(data.table)
require(tidyverse)

#### Define constants #### 
# ppmf column types
ppmf_col_classes <- c("character", "character", "character", "character", "character", "character", "character", "character", "character", "integer", "character", "character")

#### Load ppmf to a dt #### 
dt <- fread("data/ppmf.csv", sep = ",", colClasses = ppmf_col_classes)

# 2_load_recodes.r
# Author: David Van Riper
# Created: 2020-06-30
# 
# This script loads the required recode files for the ppmf variables.

file_path <- "data/recodes/"
file_list <- list.files(file_path)

#### Col classes #### 
recode_col_classes <- c("character", "integer")
recode_col_classes_tally <- c("character", "integer", "integer", "integer", "integer", "integer", "integer")

#### Load in recodes ####
for(i in file_list){
  # create output df name
  j <- str_split(i, "\\.")
  dt_name <- j[[1]][1]
  
  if(str_detect(dt_name, "age")){
    x <- fread(paste0(file_path, i))
  } else if(str_detect(dt_name, "racesTally_alone")){
    x <- fread(paste0(file_path, i), colClasses = recode_col_classes_tally)
  } else{ 
    x <- fread(paste0(file_path, i), colClasses = recode_col_classes)
  }
  
  assign(dt_name, x)
}

#### Clean up dt and lists #### 
rm(j)
rm(x)

# 3_merge_recodes.r 
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script merges the recodes onto dt

#### Set keys in dt and recodes ####
setkeyv(dt, c("QSEX", "CENHISP", "CENRACE", "QAGE", "GQTYPE"))
setkey(sex, "QSEX")
setkey(cenhisp, "CENHISP")
setkey(race7, "CENRACE")
setkey(race63, "CENRACE")
#setkey(race_alone_combo, "CENRACE")
setkey(age_p12, "QAGE")
setkey(age_p14, "QAGE")
setkey(voting_age, "QAGE")
setkey(gqtype, "GQTYPE")
setkey(racesTally_alone_combo, "CENRACE")
setkey(raceTally)

#### Sex ####
dt <- sex[dt, on = "QSEX"]

#### Hispanic ####
dt <- cenhisp[dt, on = "CENHISP"]

#### Race7 ####
dt <- race7[dt, on = "CENRACE"]

#### Race63 ####
dt <- race63[dt, on = "CENRACE"]

#### Age12 ####
dt <- age_p12[dt, on = "QAGE"]

#### Age14 #### 
dt<- age_p14[dt, on = "QAGE"]

#### Voting age #### 
dt <- voting_age[dt, on = "QAGE"]

#### Gqtype #### 
dt <- gqtype[dt, on = "GQTYPE"]

#### Race Tally Alone Combo #### 
dt <- racesTally_alone_combo[dt, on = "CENRACE"]

#### Race Tally #### 
dt <- raceTally[dt, on = "CENRACE"]

# 4_load_column_headers.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script loads the column header CSVs into tibbles, looping over all files in /data/headers directory.

file_path <- "data/headers/"
file_list <- list.files(file_path, pattern = "^header_nhgis")

#### Load in header CSVs and assign to data frames ####
for(i in file_list){
  # create output df name
  j <- str_split(i, "\\.")
  df_name <- j[[1]][1]
  df_name <- str_remove(df_name, "_nhgis")
  
  # read in header file 
  df <- read_csv(paste0(file_path, i))
  
  # assign df_name to df
  assign(df_name, df)
  
}

#### Clean up ####
rm(df)
rm(j)

# 6_compute_dummy_vars.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script uses the header tibbles to compute values for the dummy variables in dt.

#### Source the correct_column_order.r script #### 
source("r_docs/correct_column_order.r")

#### P1. Total population #### 
# This dummy is easiast to fill in - all records get a 1
dt[, H7V001_dp := 1]

#### P3. Race7 #### 
# Create vector with dummy var names 
vars <- header_race7$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_race7, set appropriate P var to 1 
for(row in 1:nrow(header_race7)){
  dt[, header_race7$header[row] := fifelse(race7 == header_race7$recode[row], 1, 0)]
}

# Create block-level total pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H7V001_dp:H7X008_dp]

# Add H7X001_dp, setting it equal to H7V001_dp
block[, H7X001_dp := H7V001_dp]

# Re-order columns
setcolorder(block, cols_p1_p3)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p1_p3.csv")

# Set H7V001_dp and vars to null to remove from dt
dt[, H7V001_dp := NULL]
dt[, (vars) := NULL]

#### P4. Hispanic/Not Hispanic #### 
# Create vector with dummy var names 
vars <- header_hisp$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_hisp, set appropriate P var to 1 
for(row in 1:nrow(header_hisp)){
  dt[, header_hisp$header[row] := fifelse(hisp == header_hisp$recode[row], 1, 0)]
}

# Create block-level total pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H7Y002_dp:H7Y003_dp]

# Create H7Y001_dp as sum of 2 and 3
block[, H7Y001_dp := H7Y002_dp + H7Y003_dp]

# Re-order columns 
setcolorder(block, cols_p4)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p4.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### P5. Hispanic by Race7 ####
# Create vector with dummy var names 
vars <- header_hisp_race7$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_hisp_race7, set appropriate P var to 1
for(row in 1:nrow(header_hisp_race7)){
  dt[, header_hisp_race7$header[row] := fifelse((hisp == header_hisp_race7$hisp[row] & race7 == header_hisp_race7$race7[row]), 1, 0)]
}

# Create block-level total pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H7Z003_dp:H7Z017_dp]

# Create H71001_dp, and the non-hisp/hisp races tallied subtotals 
block[, H7Z002_dp := H7Z003_dp + H7Z004_dp + H7Z005_dp + H7Z006_dp + H7Z007_dp + H7Z008_dp + H7Z009_dp]
block[, H7Z010_dp := H7Z011_dp + H7Z012_dp + H7Z013_dp + H7Z014_dp + H7Z015_dp + H7Z016_dp + H7Z017_dp]
block[, H7Z001_dp := H7Z002_dp + H7Z010_dp]

# Re-order columns
setcolorder(block, cols_p5)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p5.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### P6. Total races tallies by race ####
# The recode file for this table essentially serves as the dummy vars for this table. Thus, 
# we don't need to add and compute dummy vars. All we need to do is sum by block ID. 

# Create block-level counts
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H70001_dp:H70007_dp]

# Re-order columns 
setcolorder(block, cols_p6)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p6.csv")

#### P7. Total races tallies by race by Hispanic/Not Hispanic ####
vars <- header_hisp_races_tallied$header

# Add dummies to dt
dt[, (vars) := 0]

# # For each value in header_hisp_races_tallied, set appropriate header var to 1
# use the get() function to convert values in header_hisp_races_tallied to variable names
for(row in 1:nrow(header_hisp_races_tallied)){
  dt[, header_hisp_races_tallied$header[row] := fifelse((get(header_hisp_races_tallied$raceTally_alone_combo[row]) == 1 & hisp == header_hisp_races_tallied$hisp[row]), 1, 0)]
}


# Create block-level counts
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H71003_dp:H71015_dp]

# Create H71001_dp total races tallied, and the non-hisp/hisp races tallied subtotals 
block[, H71002_dp := rowSums(.SD), .SDcols = H71003_dp:H71008_dp]
block[, H71009_dp := rowSums(.SD), .SDcols = H71010_dp:H71015_dp]
block[, H71001_dp := rowSums(.SD), .SDcols = H71002_dp:H71009_dp]

# Re-order columns 
setcolorder(block, cols_p7)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p7.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### P42. Major GQ type #### 
# Create vector with dummy var names 
vars <- header_major_gqtype$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_major_gqtype, set appropriate P var to 1
for(row in 1:nrow(header_major_gqtype)){
  dt[, header_major_gqtype$header[row] := fifelse(gqtypen == header_major_gqtype$recode[row], 1, 0)]
}

# Create block-level counts
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H80003_dp:H80010_dp]

# Generate correct subtotals and total pop in group quarters 
block[, H80002_dp := H80003_dp + H80004_dp + H80005_dp + H80006_dp]
block[, H80007_dp := H80008_dp + H80009_dp + H80010_dp]
block[, H80001_dp := H80002_dp + H80007_dp]

# Re-order columns 
setcolorder(block, cols_p42)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p42.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### Sex #### 
# # Create vector with dummy var names 
# vars <- header_sex$header
# 
# # Add dummies to dt
# dt[, (vars) := 0]
# 
# # For each value in header_sex, set appropriate P var to 1 
# for(row in 1:nrow(header_sex)){
#   dt[, header_sex$header[row] := fifelse(sex == header_sex$recode[row], 1, 0)]
# }
# 
# # Create block-level total pops
# block <- dt[, lapply(.SD, sum),
#             by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
#             .SDcols = H76002_dp:H76026_dp]
# 
# # Write out to CSV for further processing
# fwrite(block, file = "data/output/block_p12_sex.csv")
# 
# # Set vars to null to remove from dt
# dt[, (vars) := NULL]

#### P12. Sex by Age #### 
# Create vector with dummy var names 
vars <- header_sex_age_p12$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age12, set appropriate P var to 1
for(row in 1:nrow(header_sex_age_p12)){
  dt[, header_sex_age_p12$header[row] := fifelse((sex == header_sex_age_p12$sex[row] & age_p12 == header_sex_age_p12$age_p12[row]), 1, 0)]
}

# Create block-level total pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H76003_dp:H76049_dp]

# Generate correct subtotals (sex) and total pop in sex by age  
# 3 through 25 - males
block[, H76002_dp := H76003_dp + H76004_dp + H76005_dp + H76006_dp + H76007_dp + H76008_dp + H76009_dp + H76010_dp + H76011_dp + H76012_dp + H76013_dp + H76014_dp + H76015_dp + H76016_dp + H76017_dp + H76018_dp + H76019_dp + H76020_dp + H76021_dp + H76022_dp + H76023_dp + H76024_dp + H76025_dp]
# 26 through 49 - females
block[, H76026_dp := H76027_dp + H76028_dp + H76029_dp + H76030_dp + H76031_dp + H76032_dp + H76033_dp + H76034_dp + H76035_dp + H76036_dp + H76037_dp + H76038_dp + H76039_dp + H76040_dp + H76041_dp + H76042_dp + H76043_dp + H76044_dp + H76045_dp + H76046_dp + H76047_dp + H76048_dp + H76049_dp]
# total pop 
block[, H76001_dp := H76002_dp + H76026_dp]

# Re-order columns 
setcolorder(block, cols_p12)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p12.csv")

# Don't set p12 vars to NULL because I need them for the p12A-I dummies. 
dt[, (vars) := NULL]

#### P12A. Sex by Age for White Alone Population #### 
# Create vector with dummy var names 
vars <- header_sex_age_p12A$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age12A, set appropriate dummy var to 1
for(row in 1:nrow(header_sex_age_p12A)){
  dt[, header_sex_age_p12A$header[row] := fifelse((sex == header_sex_age_p12A$sex[row] & age_p12 == header_sex_age_p12A$age_p12[row] & race7 == header_sex_age_p12A$race7[row]), 1, 0)]
}

# Create block-level pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H9A003_dp:H9A049_dp]

# Generate correct subtotals (sex) and total pop in sex by age  
# 3 through 25 - males
block[, H9A002_dp := rowSums(.SD), .SDcols = H9A003_dp:H9A025_dp]
# 27 through 49 - females
block[, H9A026_dp := rowSums(.SD), .SDcols = H9A027_dp:H9A049_dp] 
# total White Alone pop      
block[, H9A001_dp := H9A002_dp + H9A026_dp]

# Re-order columns 
setcolorder(block, cols_p12A)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p12A.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### p12B. Sex by Age for Black Alone Population ####
# Create vector with dummy var names
vars <- header_sex_age_p12B$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age_p12B, set appropriate dummy var to 1
for(row in 1:nrow(header_sex_age_p12B)){
  dt[, header_sex_age_p12B$header[row] := fifelse((sex == header_sex_age_p12B$sex[row] & age_p12 == header_sex_age_p12B$age_p12[row] & race7 == header_sex_age_p12B$race7[row]), 1, 0)]
}

# Create block-level pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H9B003_dp:H9B049_dp]

# Generate correct subtotals (sex) and pop in sex by age
# 3 through 25 - males
block[, H9B002_dp := rowSums(.SD), .SDcols = H9B003_dp:H9B025_dp]
# 27 through 49 - females
block[, H9B026_dp := rowSums(.SD), .SDcols = H9B027_dp:H9B049_dp]
# total Black Alone pop
block[, H9B001_dp := H9B002_dp + H9B026_dp]

# Re-order columns
setcolorder(block, cols_p12B)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p12B.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### p12C. Sex by Age for AIAN Alone Population ####
# Create vector with dummy var names
vars <- header_sex_age_p12C$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age_p12C, set appropriate dummy var to 1
for(row in 1:nrow(header_sex_age_p12C)){
  dt[, header_sex_age_p12C$header[row] := fifelse((sex == header_sex_age_p12C$sex[row] & age_p12 == header_sex_age_p12C$age_p12[row] & race7 == header_sex_age_p12C$race7[row]), 1, 0)]
}

# Create block-level pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H9C003_dp:H9C049_dp]

# Generate correct subtotals (sex) and pop in sex by age
# 3 through 25 - males
block[, H9C002_dp := rowSums(.SD), .SDcols = H9C003_dp:H9C025_dp]
# 27 through 49 - females
block[, H9C026_dp := rowSums(.SD), .SDcols = H9C027_dp:H9C049_dp]
# total American Indian/Alaska Native Alone pop
block[, H9C001_dp := H9C002_dp + H9C026_dp]

# Re-order columns
setcolorder(block, cols_p12C)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p12C.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### p12D. Sex by Age for Asian Alone Population ####
# Create vector with dummy var names
vars <- header_sex_age_p12D$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age_p12D, set appropriate dummy var to 1
for(row in 1:nrow(header_sex_age_p12D)){
  dt[, header_sex_age_p12D$header[row] := fifelse((sex == header_sex_age_p12D$sex[row] & age_p12 == header_sex_age_p12D$age_p12[row] & race7 == header_sex_age_p12D$race7[row]), 1, 0)]
}

# Create block-level pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H9D003_dp:H9D049_dp]

# Generate correct subtotals (sex) and pop in sex by age
# 3 through 25 - males
block[, H9D002_dp := rowSums(.SD), .SDcols = H9D003_dp:H9D025_dp]
# 27 through 49 - females
block[, H9D026_dp := rowSums(.SD), .SDcols = H9D027_dp:H9D049_dp]
# total Asian Alone pop
block[, H9D001_dp := H9D002_dp + H9D026_dp]

# Re-order columns
setcolorder(block, cols_p12D)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p12D.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### p12E. Sex by Age for NHPI Alone Population ####
# Create vector with dummy var names
vars <- header_sex_age_p12E$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age_p12E, set appropriate dummy var to 1
for(row in 1:nrow(header_sex_age_p12E)){
  dt[, header_sex_age_p12E$header[row] := fifelse((sex == header_sex_age_p12E$sex[row] & age_p12 == header_sex_age_p12E$age_p12[row] & race7 == header_sex_age_p12E$race7[row]), 1, 0)]
}

# Create block-level pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H9E003_dp:H9E049_dp]

# Generate correct subtotals (sex) and pop in sex by age
# 3 through 25 - males
block[, H9E002_dp := rowSums(.SD), .SDcols = H9E003_dp:H9E025_dp]
# 27 through 49 - females
block[, H9E026_dp := rowSums(.SD), .SDcols = H9E027_dp:H9E049_dp]
# total NHPI Alone pop
block[, H9E001_dp := H9E002_dp + H9E026_dp]

# Re-order columns
setcolorder(block, cols_p12E)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p12E.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### p12F. Sex by Age for SOR Alone Population ####
# Create vector with dummy var names
vars <- header_sex_age_p12F$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age_p12F, set appropriate dummy var to 1
for(row in 1:nrow(header_sex_age_p12F)){
  dt[, header_sex_age_p12F$header[row] := fifelse((sex == header_sex_age_p12F$sex[row] & age_p12 == header_sex_age_p12F$age_p12[row] & race7 == header_sex_age_p12F$race7[row]), 1, 0)]
}

# Create block-level pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H9F003_dp:H9F049_dp]

# Generate correct subtotals (sex) and pop in sex by age
# 3 through 25 - males
block[, H9F002_dp := rowSums(.SD), .SDcols = H9F003_dp:H9F025_dp]
# 27 through 49 - females
block[, H9F026_dp := rowSums(.SD), .SDcols = H9F027_dp:H9F049_dp]
# total SOR Alone pop
block[, H9F001_dp := H9F002_dp + H9F026_dp]

# Re-order columns
setcolorder(block, cols_p12F)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p12F.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### p12G. Sex by Age for Two or more races population ####
# Create vector with dummy var names
vars <- header_sex_age_p12G$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age_p12G, set appropriate dummy var to 1
for(row in 1:nrow(header_sex_age_p12G)){
  dt[, header_sex_age_p12G$header[row] := fifelse((sex == header_sex_age_p12G$sex[row] & age_p12 == header_sex_age_p12G$age_p12[row] & race7 == header_sex_age_p12G$race7[row]), 1, 0)]
}

# Create block-level pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H9G003_dp:H9G049_dp]

# Generate correct subtotals (sex) and pop in sex by age
# 3 through 25 - males
block[, H9G002_dp := rowSums(.SD), .SDcols = H9G003_dp:H9G025_dp]
# 27 through 49 - females
block[, H9G026_dp := rowSums(.SD), .SDcols = H9G027_dp:H9G049_dp]
# total Two or more races pop
block[, H9G001_dp := H9G002_dp + H9G026_dp]

# Re-order columns
setcolorder(block, cols_p12G)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p12G.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### p12H. Sex by Age for Hispanic/Latino Population ####
# Create vector with dummy var names
vars <- header_sex_age_p12H$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age_p12H, set appropriate dummy var to 1
for(row in 1:nrow(header_sex_age_p12H)){
  dt[, header_sex_age_p12H$header[row] := fifelse((sex == header_sex_age_p12H$sex[row] & age_p12 == header_sex_age_p12H$age_p12[row] & hisp == header_sex_age_p12H$hisp[row]), 1, 0)]
}

# Create block-level pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H9H003_dp:H9H049_dp]

# Generate correct subtotals (sex) and pop in sex by age
# 3 through 25 - males
block[, H9H002_dp := rowSums(.SD), .SDcols = H9H003_dp:H9H025_dp]
# 27 through 49 - females
block[, H9H026_dp := rowSums(.SD), .SDcols = H9H027_dp:H9H049_dp]
# total Hispanic/Latino pop
block[, H9H001_dp := H9H002_dp + H9H026_dp]

# Re-order columns
setcolorder(block, cols_p12H)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p12H.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### p12I. Sex by Age for White Alone, Not Hispanic/Latino Alone Population ####
# Create vector with dummy var names
vars <- header_sex_age_p12I$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age_p12I, set appropriate dummy var to 1
for(row in 1:nrow(header_sex_age_p12I)){
  dt[, header_sex_age_p12I$header[row] := fifelse((sex == header_sex_age_p12I$sex[row] & age_p12 == header_sex_age_p12I$age_p12[row] & race7 == header_sex_age_p12I$race7[row] & hisp == header_sex_age_p12I$hisp[row]), 1, 0)]
}

# Create block-level pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H9I003_dp:H9I049_dp]

# Generate correct subtotals (sex) and total pop in sex by age
# 3 through 25 - males
block[, H9I002_dp := rowSums(.SD), .SDcols = H9I003_dp:H9I025_dp]
# 27 through 49 - females
block[, H9I026_dp := rowSums(.SD), .SDcols = H9I027_dp:H9I049_dp]
# total White Alone, not Hispanic/Latino pop
block[, H9I001_dp := H9I002_dp + H9I026_dp]

# Re-order columns
setcolorder(block, cols_p12I)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p12I.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### P14. Sex by Age (single year) for population under age 20 #### 
# Create vector with dummy var names 
vars <- header_sex_age_p14$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age12, set appropriate P var to 1
for(row in 1:nrow(header_sex_age_p14)){
  dt[, header_sex_age_p14$header[row] := fifelse((sex == header_sex_age_p14$sex[row] & age_p14 == header_sex_age_p14$age_p14[row]), 1, 0)]
}

# Create block-level total pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H78003_dp:H78043_dp]

# Generate correct subtotals (sex) and total pop in sex by age (single year of age, 0-19)  
# 3 through 22 - males
block[, H78002_dp := rowSums(.SD), .SDcols = H78003_dp:H78022_dp] 
## 24 through 43 - females
block[, H78023_dp := rowSums(.SD), .SDcols = H78024_dp:H78043_dp]
# total pop under 20 years of age
block[, H78001_dp := rowSums(.SD), .SDcols = H78003_dp:H78043_dp]

# Re-order columns 
setcolorder(block, cols_p14)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p14.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### P8. Race63 ####
# Create vector with dummy var names 
vars <- header_race63$header

# Add dummies to dt
dt[, (vars) := 0] 

# For each value in header_race63, set appropriate P var to 1
for(row in 1:nrow(header_race63)){
  dt[, header_race63$header[row] := fifelse(race63 == header_race63$recode[row], 1, 0)]
}

# Create block-level total pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H72003_dp:H72071_dp]

# Calculate subtotals/totals
# Pop of one race
block[, H72002_dp := H72003_dp + H72004_dp + H72005_dp + H72006_dp + H72007_dp + H72008_dp]
# Pop of 6 races 
block[, H72070_dp := H72071_dp]
# Pop of 5 races
block[, H72063_dp := H72064_dp + H72065_dp + H72066_dp + H72067_dp + H72068_dp + H72069_dp]
# Pop of 4 races
block[, H72047_dp := H72048_dp + H72049_dp + H72050_dp + H72051_dp + H72052_dp + H72053_dp + H72054_dp +  H72055_dp + H72056_dp + H72057_dp + H72058_dp + H72059_dp + H72060_dp + H72061_dp + H72062_dp]
# Pop of 3 races 
block[, H72026_dp := H72027_dp + H72028_dp + H72029_dp + H72030_dp + H72031_dp + H72032_dp + H72033_dp +  H72034_dp + H72035_dp + H72036_dp + H72037_dp + H72038_dp + H72039_dp + H72040_dp + H72041_dp + H72042_dp + H72043_dp + H72044_dp + H72045_dp + H72046_dp]
# Pop of 2 races
block[, H72010_dp := H72011_dp + H72012_dp + H72013_dp + H72014_dp + H72015_dp + H72016_dp + H72017_dp +  H72018_dp + H72019_dp + H72020_dp + H72021_dp + H72022_dp + H72023_dp + H72024_dp + H72025_dp]
# Pop of 2 or more races
block[, H72009_dp := H72010_dp + H72026_dp + H72047_dp + H72063_dp + H72070_dp]
# Total popualtion 
block[, H72001_dp := H72002_dp + H72009_dp]

# Re-order columns 
setcolorder(block, cols_p8)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p8.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### P9. Hispanic or Not Hispanic by Race63 #### 
# Create vector with dummy var names 
vars <- header_hisp_race63$header

# Add dummies to dt
dt[, (vars) := 0] 

# For each value in header_hisp_race63, set appropriate P var to 1
for(row in 1:nrow(header_hisp_race63)){
  dt[, header_hisp_race63$header[row] := fifelse((hisp == header_hisp_race63$hisp[row] & race63 == header_hisp_race63$race63[row]), 1, 0)]
}

# Create block-level total pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H73005_dp:H73073_dp]

# Subtotals and totals 
# Pop of 6 or more races 
block[, H73072_dp := H73073_dp]
# Pop of 5 races
block[, H73065_dp := H73066_dp + H73067_dp + H73068_dp + H73069_dp + H73070_dp + H73071_dp]
# Pop of 4 races
block[, H73049_dp := H73050_dp + H73051_dp + H73052_dp + H73053_dp + H73054_dp + H73055_dp + H73056_dp + H73057_dp + H73058_dp + H73059_dp + H73060_dp + H73061_dp + H73062_dp + H73063_dp + H73064_dp]
# Pop of 3 races
block[, H73028_dp := H73029_dp + H73030_dp + H73031_dp + H73032_dp + H73033_dp + H73034_dp + H73035_dp + H73036_dp + H73037_dp + H73038_dp + H73039_dp + H73040_dp + H73041_dp + H73042_dp + H73043_dp + H73044_dp + H73045_dp + H73046_dp + H73047_dp + H73048_dp]
# Pop of 2 races
block[, H73012_dp := H73013_dp + H73014_dp + H73015_dp + H73016_dp + H73017_dp + H73018_dp + H73019_dp + H73020_dp + H73021_dp + H73022_dp + H73023_dp + H73024_dp + H73025_dp + H73026_dp + H73027_dp]
# Pop of 2 or more races
block[, H73011_dp := H73012_dp + H73028_dp + H73049_dp + H73065_dp + H73072_dp]
# Pop of 1 race
block[, H73004_dp := H73005_dp + H73006_dp + H73007_dp + H73008_dp + H73009_dp + H73010_dp]
# Non-Hispanic total 
block[, H73003_dp := H73004_dp + H73011_dp]

# Re-order columns 
# setcolorder(block, cols_p9)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p9.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### P10. Race63 by Voting age #### 
# Create vector with dummy var names 
vars <- header_race63_voting_age$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_race63_voting_age, set appropriate P var to 1
for(row in 1:nrow(header_race63_voting_age)){
  dt[, header_race63_voting_age$header[row] := fifelse((voting_age == header_race63_voting_age$voting_age[row] & race63 == header_hisp_race63_voting_age$race63[row]), 1, 0)]
}

# Create block-level total pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H74003_dp:H74071_dp]

# Calculate subtotals/totals
# Pop of one race
block[, H74002_dp := H74003_dp + H74004_dp + H74005_dp + H74006_dp + H74007_dp + H74008_dp]
# Pop of 6 races 
block[, H74070_dp := H74071_dp]
# Pop of 5 races
block[, H74063_dp := H74064_dp + H74065_dp + H74066_dp + H74067_dp + H74068_dp + H74069_dp]
# Pop of 4 races
block[, H74047_dp := H74048_dp + H74049_dp + H74050_dp + H74051_dp + H74052_dp + H74053_dp + H74054_dp +  H74055_dp + H74056_dp + H74057_dp + H74058_dp + H74059_dp + H74060_dp + H74061_dp + H74062_dp]
# Pop of 3 races 
block[, H74026_dp := H74027_dp + H74028_dp + H74029_dp + H74030_dp + H74031_dp + H74032_dp + H74033_dp +  H74034_dp + H74035_dp + H74036_dp + H74037_dp + H74038_dp + H74039_dp + H74040_dp + H74041_dp + H74042_dp + H74043_dp + H74044_dp + H74045_dp + H74046_dp]
# Pop of 2 races
block[, H74010_dp := H74011_dp + H74012_dp + H74013_dp + H74014_dp + H74015_dp + H74016_dp + H74017_dp +  H74018_dp + H74019_dp + H74020_dp + H74021_dp + H74022_dp + H74023_dp + H74024_dp + H74025_dp]
# Pop of 2 or more races
block[, H74009_dp := H74010_dp + H74026_dp + H74047_dp + H74063_dp + H74070_dp]
# Total population 18 years and older 
block[, H74001_dp := H74002_dp + H74009_dp]

# Re-order columns 
setcolorder(block, cols_p10)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p10.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### P11. Hispanic or Not Hispanic by Race63 by Voting age #### 
# Create vector with dummy var names 
vars <- header_hisp_race63_voting_age$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_hisp_race63_voting_age, set appropriate P var to 1
for(row in 1:nrow(header_hisp_race63_voting_age)){
  dt[, header_hisp_race63_voting_age$header[row] := fifelse((voting_age == header_hisp_race63_voting_age$voting_age[row] & hisp == header_hisp_race63_voting_age$hisp[row] & race63 == header_hisp_race63_voting_age$race63[row]), 1, 0)]
}

# Create block-level total pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H75005_dp:H75073_dp]

# Subtotals and totals 
# Pop of 6 or more races 
block[, H75072_dp := H75073_dp]
# Pop of 5 races
block[, H75065_dp := H75066_dp + H75067_dp + H75068_dp + H75069_dp + H75070_dp + H75071_dp]
# Pop of 4 races
block[, H75049_dp := H75050_dp + H75051_dp + H75052_dp + H75053_dp + H75054_dp + H75055_dp + H75056_dp + H75057_dp + H75058_dp + H75059_dp + H75060_dp + H75061_dp + H75062_dp + H75063_dp + H75064_dp]
# Pop of 3 races
block[, H75028_dp := H75029_dp + H75030_dp + H75031_dp + H75032_dp + H75033_dp + H75034_dp + H75035_dp + H75036_dp + H75037_dp + H75038_dp + H75039_dp + H75040_dp + H75041_dp + H75042_dp + H75043_dp + H75044_dp + H75045_dp + H75046_dp + H75047_dp + H75048_dp]
# Pop of 2 races
block[, H75012_dp := H75013_dp + H75014_dp + H75015_dp + H75016_dp + H75017_dp + H75018_dp + H75019_dp + H75020_dp + H75021_dp + H75022_dp + H75023_dp + H75024_dp + H75025_dp + H75026_dp + H75027_dp]
# Pop of 2 or more races
block[, H75011_dp := H75012_dp + H75028_dp + H75049_dp + H75065_dp + H75072_dp]
# Pop of 1 race
block[, H75004_dp := H75005_dp + H75006_dp + H75007_dp + H75008_dp + H75009_dp + H75010_dp]
# Non-Hispanic total 
block[, H75003_dp := H75004_dp + H75011_dp]

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p11.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

# correct_column_order.r 
# Author: David Van Riper
# Created: 2020-07-05
# 
# This script generates vectors of column headers in the correct order. These vectors will be used 
# to create the final datasets with columns in correct order.

#### Geog var vector #### 
# Create a geog var vector to concatenate onto correct_column_order vectors 
geog_vars <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")

#### Read in NHGIS state extract to get column headers in correct order #### 
#sf1 <- fread("data/sf1/nhgis1333_ds172_2010_state.csv")
sf1 <- fread("data/sf1/nhgis1348_csv/nhgis1348_ds172_2010_state.csv")

#### Keep only sf1_names that start with H* #### 
sf1_names <- grep("^H", names(sf1), value = TRUE)

#### Append '_dp' to each variable name #### 
sf1_names <- paste0(sf1_names, "_dp")

#### Extract columns for each set of tables #### 
cols_p1 <- grep("^H7V", sf1_names, value = TRUE)
cols_p3 <- grep("^H7X", sf1_names, value = TRUE)
cols_p4 <- grep("^H7Y", sf1_names, value = TRUE)
cols_p5 <- grep("^H7Z", sf1_names, value = TRUE)
cols_p6 <- grep("^H70", sf1_names, value = TRUE)
cols_p7 <- grep("^H71", sf1_names, value = TRUE)   
cols_p8 <- grep("^H72", sf1_names, value = TRUE)
cols_p9 <- grep("^H73", sf1_names, value = TRUE)
cols_p10 <- grep("^H74", sf1_names, value = TRUE)
cols_p11 <- grep("^H75", sf1_names, value = TRUE)
cols_p12 <- grep("^H76", sf1_names, value = TRUE)
cols_p14 <- grep("^H78", sf1_names, value = TRUE)
cols_p42 <- grep("^H80", sf1_names, value = TRUE)
cols_p12A <- grep("^H9A", sf1_names, value = TRUE)
cols_p12B <- grep("^H9B", sf1_names, value = TRUE)
cols_p12C <- grep("^H9C", sf1_names, value = TRUE)
cols_p12D <- grep("^H9D", sf1_names, value = TRUE)
cols_p12E <- grep("^H9E", sf1_names, value = TRUE)
cols_p12F <- grep("^H9F", sf1_names, value = TRUE)
cols_p12G <- grep("^H9G", sf1_names, value = TRUE)
cols_p12H <- grep("^H9H", sf1_names, value = TRUE)
cols_p12I <- grep("^H9I", sf1_names, value = TRUE)

#### Append the geog_vars to the table columns #### 
cols_p1_p3 <- c(geog_vars, cols_p1, cols_p3)
rm(cols_p3)
#cols_p3 <- c(geog_vars, cols_p3)
cols_p4 <- c(geog_vars, cols_p4)
cols_p5 <- c(geog_vars, cols_p5)
cols_p6 <- c(geog_vars, cols_p6)
cols_p7 <- c(geog_vars, cols_p7)
cols_p8 <- c(geog_vars, cols_p8)
cols_p9 <- c(geog_vars, cols_p9)
cols_p10 <- c(geog_vars, cols_p10)
cols_p11 <- c(geog_vars, cols_p11)
cols_p12 <- c(geog_vars, cols_p12)
cols_p14 <- c(geog_vars, cols_p14)
cols_p42 <- c(geog_vars, cols_p42)
cols_p12A <- c(geog_vars, cols_p12A)
cols_p12B <- c(geog_vars, cols_p12B)
cols_p12C <- c(geog_vars, cols_p12C)
cols_p12D <- c(geog_vars, cols_p12D)
cols_p12E <- c(geog_vars, cols_p12E)
cols_p12F <- c(geog_vars, cols_p12F)
cols_p12G <- c(geog_vars, cols_p12G)
cols_p12H <- c(geog_vars, cols_p12H)
cols_p12I <- c(geog_vars, cols_p12I)

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

#### Source the correct_column_order.r script #### 
source("r_docs/correct_column_order.r")

#### Constant "character" vector #### 
char_all <- rep("character", 4)
geog_vars <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")

#### Create vector if "integer" values #### 
#int_p1_p3 <- rep("integer", 8)
int_p4 <- rep("integer", 3)
int_p9 <- rep("integer", 71)
int_p10 <- rep("integer", 71)
int_p11 <- rep("integer", 71)
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
#p9[, H73004_dp := H73005_dp + H73006_dp + H73007_dp + H73008_dp + H73009_dp + H73010_dp]
# Non-Hispanic total 
#p9[, H73003_dp := H73004_dp + H73011_dp]

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
#p11[, H75004_dp := H75005_dp + H75006_dp + H75007_dp + H75008_dp + H75009_dp + H75010_dp]
# Non-Hispanic total 
#p11[, H75003_dp := H75004_dp + H75011_dp]

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

# 8_create_dp_summary_files.r
# Author: David Van Riper
# Created: 2020-07-05
# 
# This script creates summary files for specific geographic levels. 

require(data.table)

#### Source the 1_load_nhgis_blocks.r script to load crosswalk #### 
source("r_docs/1_load_nhgis_blocks.r")

#### Constant "character" vector #### 
char_all <- rep("character", 4)
geog_vars <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")

#### Create vector if "integer" values #### 
int_p1_p3 <- rep("integer", 9)
int_p4 <- rep("integer", 3)
int_p5 <- rep("integer", 17)
int_p6 <- rep("integer", 7)
int_p7 <- rep("integer", 15)
int_p8 <- rep("integer", 71)
int_p9 <- rep("integer", 73)
int_p10 <- rep("integer", 71)
int_p11 <- rep("integer", 73)
int_p12 <- rep("integer", 49)
int_p12 <- rep("integer", 49)
int_p12A <- rep("integer", 49)
int_p12B <- rep("integer", 49)
int_p12C <- rep("integer", 49)
int_p12D <- rep("integer", 49)
int_p12E <- rep("integer", 49)
int_p12F <- rep("integer", 49)
int_p12G <- rep("integer", 49)
int_p12H <- rep("integer", 49)
int_p12I <- rep("integer", 49)
int_p14 <-rep("integer", 43)
int_p42 <- rep("integer", 10)

#### Column classes ####
col_classes_p1_p3 <- c(char_all, int_p1_p3)
col_classes_p4 <- c(char_all, int_p4)
col_classes_p5 <- c(char_all, int_p5)
col_classes_p6 <- c(char_all, int_p6)
col_classes_p7 <- c(char_all, int_p7)
col_classes_p8 <- c(char_all, int_p8)
col_classes_p9 <- c(char_all, int_p9)
col_classes_p10 <- c(char_all, int_p10)
col_classes_p11 <- c(char_all, int_p11)
col_classes_p12 <- c(char_all, int_p12)
col_classes_p12A <- c(char_all, int_p12A)
col_classes_p12B <- c(char_all, int_p12B)
col_classes_p12C <- c(char_all, int_p12C)
col_classes_p12D <- c(char_all, int_p12D)
col_classes_p12E <- c(char_all, int_p12E)
col_classes_p12F <- c(char_all, int_p12F)
col_classes_p12G <- c(char_all, int_p12G)
col_classes_p12H <- c(char_all, int_p12H)
col_classes_p12I <- c(char_all, int_p12I)
col_classes_p14 <- c(char_all, int_p14)
col_classes_p42 <- c(char_all, int_p42)

#### Load data in using correct col_classes #### 
p1_p3 <- fread("data/output/block_p1_p3.csv", colClasses = col_classes_p1_p3)
p4 <- fread("data/output/block_p4.csv", colClasses = col_classes_p4)
p5 <- fread("data/output/block_p5.csv", colClasses = col_classes_p5)
p6 <- fread("data/output/block_p6.csv", colClasses = col_classes_p6)
p7 <- fread("data/output/block_p7.csv", colClasses = col_classes_p7)
p8 <- fread("data/output/block_p8.csv", colClasses = col_classes_p8)
p9 <- fread("data/output/block_p9.csv", colClasses = col_classes_p9)
p10 <- fread("data/output/block_p10.csv", colClasses = col_classes_p10)
p11 <- fread("data/output/block_p11.csv", colClasses = col_classes_p11)
p12 <- fread("data/output/block_p12.csv", colClasses = col_classes_p12)
p12A <- fread("data/output/block_p12A.csv", colClasses = col_classes_p12A)
p12B <- fread("data/output/block_p12B.csv", colClasses = col_classes_p12B)
p12C <- fread("data/output/block_p12C.csv", colClasses = col_classes_p12C)
p12D <- fread("data/output/block_p12D.csv", colClasses = col_classes_p12D)
p12E <- fread("data/output/block_p12E.csv", colClasses = col_classes_p12E)
p12F <- fread("data/output/block_p12F.csv", colClasses = col_classes_p12F)
p12G <- fread("data/output/block_p12G.csv", colClasses = col_classes_p12G)
p12H <- fread("data/output/block_p12H.csv", colClasses = col_classes_p12H)
p12I <- fread("data/output/block_p12I.csv", colClasses = col_classes_p12I)
p14 <- fread("data/output/block_p14.csv", colClasses = col_classes_p14)
p42 <- fread("data/output/block_p42.csv", colClasses = col_classes_p42)

#### Set keys #### 
setkeyv(p1_p3, geog_vars)
#setkeyv(p2, geog_vars)
setkeyv(p4, geog_vars)
setkeyv(p5, geog_vars)
setkeyv(p6, geog_vars)
setkeyv(p7, geog_vars)
setkeyv(p8, geog_vars)
setkeyv(p9, geog_vars)
setkeyv(p10, geog_vars)
setkeyv(p11, geog_vars)
setkeyv(p12, geog_vars)
setkeyv(p12A, geog_vars)
setkeyv(p12B, geog_vars)
setkeyv(p12C, geog_vars)
setkeyv(p12D, geog_vars)
setkeyv(p12E, geog_vars)
setkeyv(p12F, geog_vars)
setkeyv(p12G, geog_vars)
setkeyv(p12H, geog_vars)
setkeyv(p12I, geog_vars)
setkeyv(p14, geog_vars)
setkeyv(p42, geog_vars)

#### Merge together data.tables #### 
dp <- p1_p3[p4][p5][p6][p7][p8][p9][p10][p11][p12][p14][p42][p12A][p12B][p12C][p12D][p12E][p12F][p12G][p12H][p12I]


#### Generate gisjoin #### 
dp[, gisjoin := paste0("G", TABBLKST, "0", TABBLKCOU, "0", TABTRACTCE, TABBLK)]

#### Set key on gisjoin for dp] ####
setkey(dp, "gisjoin")

#### Merge the nhgis crosswalk with dp data #### 
# The line of code below merges dt_nhgis into the dp data.table, keeping the row count at 
# 6,058,148
dp <- dt_nhgis[dp]

#### Create summary dt for each geog. level, including gisjoin #### 
state <- dp[, lapply(.SD, sum),
            by = .(STATEA),
            .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0")][, STATEA := NULL]

county <- dp[, lapply(.SD, sum),
             by = .(STATEA, COUNTYA),
             .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", COUNTYA, "0")][, c("STATEA","COUNTYA") := NULL]

tract <- dp[, lapply(.SD, sum),
            by = .(STATEA, COUNTYA, TRACTA),
            .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", COUNTYA, "0", TRACTA)][, c("STATEA","COUNTYA", "TRACTA") := NULL]

cousub <- dp[, lapply(.SD, sum),
             by = .(STATEA, COUNTYA, COUSUBA),
             .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", COUNTYA, "0", COUSUBA)][, c("STATEA", "COUNTYA", "COUSUBA") := NULL]

place <- dp[, lapply(.SD, sum),
            by = .(STATEA, PLACEA),
            .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", PLACEA)][, c("STATEA","PLACEA") := NULL]

blkgrp <- dp[, lapply(.SD, sum),
             by = .(STATEA, COUNTYA, TRACTA, BLKGRPA),
             .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", COUNTYA, "0", TRACTA, BLKGRPA)][, c("STATEA","COUNTYA", "TRACTA", "BLKGRPA") := NULL]


aianhh <- dp[, lapply(.SD, sum),
             by = .(AIANHHA),
             .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", AIANHHA)][, c("AIANHHA") := NULL]


anrc <- dp[, lapply(.SD, sum),
           by = .(ANRCA),
           .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", ANRCA)][, c("ANRCA") := NULL]

cbsa <- dp[, lapply(.SD, sum),
           by = .(CBSAA),
           .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", CBSAA)][, c("CBSAA") := NULL] 

ua <- dp[, lapply(.SD, sum),
         by = .(UAA),
         .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", UAA)][, c("UAA") := NULL]

cd <- dp[, lapply(.SD, sum),
         by = .(STATEA, CDA),
         .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", CDA)][, c("STATEA","CDA") := NULL]

sldu <- dp[, lapply(.SD, sum),
           by = .(STATEA, SLDUA),
           .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", SLDUA)][, c("STATEA","SLDUA") := NULL]

sldl <- dp[, lapply(.SD, sum),
           by = .(STATEA, SLDLA),
           .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", SLDLA)][, c("STATEA","SLDLA") := NULL]

sduni <- dp[, lapply(.SD, sum),
            by = .(STATEA, SDUNIA),
            .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", SDUNIA)][, c("STATEA", "SDUNIA") := NULL]

block <- dp[, lapply(.SD, sum),
            by = .(STATEA, COUNTYA, TRACTA, BLOCKA),
            .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", COUNTYA, "0", TRACTA, BLOCKA)][, c("STATEA", "COUNTYA", "TRACTA", "BLOCKA") := NULL]

aianhh_144 <- dp[, lapply(.SD, sum),
                 by = .(STATEA, COUNTYA, TRACTA, AIANHHA),
                 .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", COUNTYA, "0", TRACTA, AIANHHA)][, c("STATEA", "COUNTYA", "TRACTA", "AIANHHA") := NULL]

cty_sub_261 <- dp[, lapply(.SD, sum),
                  by = .(STATEA, AIANHHA, COUNTYA, COUSUBA),
                  .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", AIANHHA, COUNTYA, "0", COUSUBA)][, c("STATEA", "AIANHHA", "COUNTYA", "COUSUBA") := NULL]

county_282 <- dp[, lapply(.SD, sum),
                 by = .(STATEA, AIANHHA, COUNTYA),
                 .SDcols = H7V001_dp:H9I049_dp][, gisjoin := paste0("G", STATEA, "0", AIANHHA, COUNTYA, "0")][, c("STATEA", "AIANHHA", "COUNTYA") := NULL]

#### Clean up extra dts and gc() #### 
rm(dp)
rm(dt_nhgis)
rm(list=ls(pattern="p[0-9]"))
gc()

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


