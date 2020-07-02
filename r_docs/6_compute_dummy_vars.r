# 6_compute_dummy_vars.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script uses the header tibbles to compute values for the dummy variables in dt.

require(data.table)

#### Total population #### 
# This dummy is easiast to fill in - all records get a 1
#dt[, P0010001 := 1]
dt[, H7V001 := 1]

#### Hispanic/Not Hispanic #### 
# For each value in header_hisp, set appropriate P var to 1 
for(row in 1:nrow(header_hisp)){
  dt[, header_hisp$header[row] := fifelse(hisp == header_hisp$recode[row], 1, 0)]
}

#### Sex #### 
# For each value in header_sex, set appropriate P var to 1 
for(row in 1:nrow(header_sex)){
  dt[, header_sex$header[row] := fifelse(sex == header_sex$recode[row], 1, 0)]
}

#### Race7 #### 
# For each value in header_race7, set appropriate P var to 1 
for(row in 1:nrow(header_race7)){
  dt[, header_race7$header[row] := fifelse(race7 == header_race7$recode[row], 1, 0)]
}

#### Hispanic by Race7 ####
# For each value in header_hisp_race7, set appropriate P var to 1
for(row in 1:nrow(header_hisp_race7)){
  dt[, header_hisp_race7$header[row] := fifelse((hisp == header_hisp_race7$hisp[row] & race7 == header_hisp_race7$race7[row]), 1, 0)]
}

#### Sex by Age_p12 #### 
# For each value in header_sex_age12, set appropriate P var to 1
for(row in 1:nrow(header_sex_age12)){
  dt[, header_sex_age12$header[row] := fifelse((sex == header_sex_age12$sex[row] & age_p12 == header_sex_age12$age_p12[row]), 1, 0)]
}

#### Major GQ type #### 
# For each value in header_major_gqtype, set appropriate P var to 1
for(row in 1:nrow(header_major_gqtype)){
  dt[, header_major_gqtype$header[row] := fifelse(gqtypen == header_major_gqtype$recode[row], 1, 0)]
}

#### Race63 #### 
# For each value in header_race63, set appropriate P var to 1
for(row in 1:nrow(header_race63)){
  dt[, header_race63$header[row] := fifelse(race63 == header_race63$recode[row], 1, 0)]
}

#### Hispanic or Not Hispanice by Race63 #### 
# For each value in header_hisp_race63, set appropriate P var to 1
for(row in 1:nrow(header_hisp_race63)){
  dt[, header_hisp_race63$header[row] := fifelse((hisp == header_hisp_race63$hisp[row] & race63 == header_hisp_race63$race63[row]), 1, 0)]
}

#### Race63 by Voting age #### 
# For each value in header_race63_voting_age, set appropriate P var to 1
for(row in 1:nrow(header_race63_voting_age)){
  dt[, header_race63_voting_age$header[row] := fifelse((voting_age == header_race63_voting_age$voting_age[row] & race63 == header_hisp_race63_voting_age$race63[row]), 1, 0)]
}

#### Hispanic or Not Hispanice by Race63 by Voting age ####  
# For each value in header_hisp_race63_voting_age, set appropriate P var to 1
for(row in 1:nrow(header_hisp_race63_voting_age)){
  dt[, header_hisp_race63_voting_age$header[row] := fifelse((voting_age == header_hisp_race63_voting_age$voting_age[row] & hisp == header_hisp_race63_voting_age$hisp[row] & race63 == header_hisp_race63_voting_age$race63[row]), 1, 0)]
}