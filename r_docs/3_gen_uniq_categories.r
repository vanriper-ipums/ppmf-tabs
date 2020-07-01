# 3_gen_uniq_categories.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script generates unique values for each recode dt.

require(data.table)
source("r_docs/functions.r")

#### Create copies of each recode dt #### 
uniq_voting <- voting
uniq_age5 <- age5
uniq_age12 <- age12
uniq_sex <- sex
uniq_race7 <- race7
uniq_race_tally <- race_tally
uniq_race63 <- race63
uniq_race11 <- race11
uniq_hisp <- hisp
uniq_rtype <- rtype

#### Remove original value from each dt ####
uniq_voting[, qage := NULL] 
uniq_age5[, qage := NULL]
uniq_age12[, qage := NULL]
uniq_sex[, qsex := NULL]
uniq_race7[, cenrace := NULL]
uniq_race_tally[, cenrace := NULL]
uniq_race63[, cenrace := NULL]
uniq_race11[, cenrace := NULL]
uniq_hisp[, cenhisp := NULL]
uniq_rtype[, rtype := NULL]

#### Create unique values for each recode ####
uniq_voting <- unique(uniq_voting)
uniq_age5 <- unique(uniq_age5)
uniq_age12 <- unique(uniq_age12)
uniq_sex <- unique(uniq_sex)
uniq_race7 <- unique(uniq_race7)
uniq_race_tally <- unique(uniq_race_tally)
uniq_race11 <- unique(uniq_race11)
uniq_hisp <- unique(uniq_hisp)
uniq_rtype <- unique(uniq_rtype)



