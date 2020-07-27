# 3_merge_recodes.r 
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script merges the recodes onto dt

require(data.table)

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

