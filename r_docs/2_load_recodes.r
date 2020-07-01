# 2_load_recodes.r
# Author: David Van Riper
# Created: 2020-06-30
# 
# This script loads the required recode files for the ppmf variables.

require(data.table)

#### Col classes #### 
recode_col_classes <- c("character", "integer")

#### Read in age recodes #### 

#Voting age recode (under 18 / over 18)
voting <- fread("data/recodes/voting_age.csv")

# 5-year age bins up to 85, then over 85
age5 <- fread("data/recodes/age5.csv")

# Age bins for table P12
age12 <- fread("data/recodes/age_p12.csv")

#### Read in race recodes ####

# 63-category race recode (essentially creates numeric version of cenrace)
race63 <- fread("data/recodes/race63.csv", colClasses = recode_col_classes)

# 11-category race recode (for two, three, four, five, six race totals)
race11 <- fread("data/recodes/race11.csv", colClasses = recode_col_classes)

# 7-category race recode 
race7 <- fread("data/recodes/race7.csv", colClasses = recode_col_classes)

# tally count recode - this tells you the number of races recorded by the 
# respondant 
race_tally <- fread("data/recodes/raceTally.csv", colClasses = recode_col_classes) 

# Race alone or in combo recode
race_alone_combo <- fread("data/recodes/race_alone_combo.csv", colClasses = c("character", "integer", "integer", "integer", "integer", "integer", "integer"))        

#### Read in sex recode ####

# Recode sex from character to integer value
sex <- fread("data/recodes/sex.csv", colClasses = recode_col_classes)

#### Read in sex recode ####

# Recode cenhisp from character to integer value
hisp <- fread("data/recodes/cenhisp.csv", colClasses = recode_col_classes)

#### Read in rtype recode ####

# Recode rtype from character to integer value
rtype <- fread("data/recodes/rtype.csv", colClasses = recode_col_classes)

#### Read in gqtype recode #### 

# Recode gqtype from character to integer value
gqtype <- fread("data/recodes/gqtype.csv", colClasses = recode_col_classes)
