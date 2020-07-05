# 6_compute_dummy_vars.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script uses the header tibbles to compute values for the dummy variables in dt.

require(data.table)

#### Total population #### 
# This dummy is easiast to fill in - all records get a 1
dt[, H7V001_dp := 1]

#### Race7 #### 
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
setcolorder(block, col_order_p1_p3)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p1_p3.csv")

# Set H7V001_dp and vars to null to remove from dt
dt[, H7V001_dp := NULL]
dt[, (vars) := NULL]

#### Hispanic/Not Hispanic #### 
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
setcolorder(block, col_order_p4)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p4.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### Hispanic by Race7 ####
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

# Create H7Z001_dp, and the non-hisp/hisp subtotals 
block[, H7Z002_dp := H7Z003_dp + H7Z004_dp + H7Z005_dp + H7Z006_dp + H7Z007_dp + H7Z008_dp + H7Z009_dp]
block[, H7Z010_dp := H7Z011_dp + H7Z012_dp + H7Z013_dp + H7Z014_dp + H7Z015_dp + H7Z016_dp + H7Z017_dp]
block[, H7Z001_dp := H7Z002_dp + H7Z010_dp]

# Re-order columns
setcolorder(block, col_order_p5)

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p5.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### Major GQ type #### 
# Create vector with dummy var names 
vars <- header_major_gqtype$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_major_gqtype, set appropriate P var to 1
for(row in 1:nrow(header_major_gqtype)){
  dt[, header_major_gqtype$header[row] := fifelse(gqtypen == header_major_gqtype$recode[row], 1, 0)]
}

# Create block-level total pops
block <- dt[, lapply(.SD, sum),
            by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
            .SDcols = H80003_dp:H80010_dp]

# Generate correct subtotals and total pop in group quarters 
block[, H80002_dp := H80003_dp + H80004_dp + H80005_dp + H80006_dp]
block[, H80007_dp := H80008_dp + H80009_dp + H80010_dp]
block[, H80001_dp : H80002_dp + H80007_dp]

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

#### Sex by Age_p12 #### 
# Create vector with dummy var names 
vars <- header_sex_age12$header

# Add dummies to dt
dt[, (vars) := 0]

# For each value in header_sex_age12, set appropriate P var to 1
for(row in 1:nrow(header_sex_age12)){
  dt[, header_sex_age12$header[row] := fifelse((sex == header_sex_age12$sex[row] & age_p12 == header_sex_age12$age_p12[row]), 1, 0)]
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

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### Race63 ####
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

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p8.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### Hispanic or Not Hispanice by Race63 #### 
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

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p9.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### Race63 by Voting age #### 
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

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p10.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]

#### Hispanic or Not Hispanice by Race63 by Voting age #### 
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

# Write out to CSV for further processing
fwrite(block, file = "data/output/block_p11.csv")

# Set vars to null to remove from dt
dt[, (vars) := NULL]