# 3_merge_recodes.r 
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script merges the recodes onto dt

require(data.table)

#### Set keys in dt and recodes ####
setkeyv(dt, c("QSEX", "CENHISP", "CENRACE", "QAGE", "GQTYPE"))
setkey(sex, "QSEX")
setkey(hisp, "CENHISP")
setkey(race7, "CENRACE")
setkey(race63, "CENRACE")
setkey(race_alone_combo, "CENRACE")
setkey(age12, "QAGE")
setkey(voting, "QAGE")
setkey(gqtype, "GQTYPE")

#### Sex ####
dt <- sex[dt, on = "QSEX"]

#### Hispanic ####
dt <- hisp[dt, on = "CENHISP"]

#### Race7 ####
dt <- race7[dt, on = "CENRACE"]

#### Race63 ####
dt <- race63[dt, on = "CENRACE"]

#### Age12 ####
dt <- age12[dt, on = "QAGE"]

#### Voting age #### 
dt <- voting[dt, on = "QAGE"]

#### Gqtype #### 
dt <- gqtype[dt, on = "GQTYPE"]