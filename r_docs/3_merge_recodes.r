# 3_merge_recodes.r 
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script merges the recodes onto dt

require(data.table)

#### Set keys in dt and recodes ####
setkey(dt, c("qsex", "cenhisp", "cenrace", "qage", "gqtype"))
setkey(sex, "qsex")
setkey(hisp, "cenhisp")
setkey(race7, "cenrace")
setkey(race63, "cenrace")
setkey(age12, "qage")
setkey(voting, "qage")
setkey(gqtype, "gqtype")

#### Sex ####
sex[dt]

#### Hispanic ####
hisp[dt]

#### Race7 ####
race7[dt]

#### Race63 ####
race63[dt]

#### Age12 ####
age12[dt]

#### Voting age #### 
voting[dt]

#### Gqtype #### 
gqtype[dt]