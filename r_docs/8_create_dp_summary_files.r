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
int_p8 <- rep("integer", 71)
int_p9 <- rep("integer", 73)
int_p10 <- rep("integer", 71)
int_p11 <- rep("integer", 73)
int_p12 <- rep("integer", 49)
int_p42 <- rep("integer", 10)

#### Column classes ####
col_classes_p1_p3 <- c(char_all, int_p1_p3)
col_classes_p4 <- c(char_all, int_p4)
col_classes_p5 <- c(char_all, int_p5)
col_classes_p8 <- c(char_all, int_p8)
col_classes_p9 <- c(char_all, int_p9)
col_classes_p10 <- c(char_all, int_p10)
col_classes_p11 <- c(char_all, int_p11)
col_classes_p12 <- c(char_all, int_p12)
col_classes_p42 <- c(char_all, int_p42)

#### Load data in using correct col_classes #### 
p1_p3 <- fread("data/output/block_p1_p3.csv", colClasses = col_classes_p1_p3)
p4 <- fread("data/output/block_p4.csv", colClasses = col_classes_p4)
p5 <- fread("data/output/block_p5.csv", colClasses = col_classes_p5)
p8 <- fread("data/output/block_p8.csv", colClasses = col_classes_p8)
p9 <- fread("data/output/block_p9.csv", colClasses = col_classes_p9)
p10 <- fread("data/output/block_p10.csv", colClasses = col_classes_p10)
p11 <- fread("data/output/block_p11.csv", colClasses = col_classes_p11)
p12 <- fread("data/output/block_p12.csv", colClasses = col_classes_p12)
p42 <- fread("data/output/block_p42.csv", colClasses = col_classes_p42)

#### Set keys #### 
setkeyv(p1_p3, geog_vars)
setkeyv(p2, geog_vars)
setkeyv(p4, geog_vars)
setkeyv(p5, geog_vars)
setkeyv(p8, geog_vars)
setkeyv(p9, geog_vars)
setkeyv(p10, geog_vars)
setkeyv(p11, geog_vars)
setkeyv(p12, geog_vars)
setkeyv(p42, geog_vars)

#### Merge together data.tables #### 
dp <- p1_p3[p4][p5][p8][p9][p10][p11][p12][p42]


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
            .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", STATEA, "0")][, STATEA := NULL]

county <- dp[, lapply(.SD, sum),
            by = .(STATEA, COUNTYA),
            .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", STATEA, "0", COUNTYA, "0")][, c("STATEA", "COUNTYA") := NULL]

tract <- dp[, lapply(.SD, sum),
            by = .(STATEA, COUNTYA, TRACTA),
            .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", STATEA, "0", COUNTYA, "0", TRACTA)][, c("STATEA", "COUNTYA", "TRACTA") := NULL]

cousub <- dp[, lapply(.SD, sum),
            by = .(STATEA, COUNTYA, COUSUBA),
            .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", STATEA, "0", COUNTYA, "0", COUSUBA)][, c("STATEA", "COUNTYA", "COUSUBA") := NULL]

place <- dp[, lapply(.SD, sum),
             by = .(STATEA, PLACEA),
             .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", STATEA, "0", PLACEA)][, c("STATEA", "PLACEA") := NULL]

blkgrp <- dp[, lapply(.SD, sum),
            by = .(STATEA, COUNTYA, TRACTA, BLKGRPA),
            .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", STATEA, "0", COUNTYA, "0", TRACTA, BLKGRPA)][, c("STATEA", "COUNTYA", "TRACTA", "BLKGRPA") := NULL]


aianhh <- dp[, lapply(.SD, sum),
             by = .(AIANHHA),
             .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", AIANHHA)][, c("AIANHHA") := NULL]


anrc <- dp[, lapply(.SD, sum),
           by = .(ANRCA),
           .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", ANRCA)][, c("ANRCA") := NULL]

cbsa <- dp[, lapply(.SD, sum),
            by = .(CBSAA),
            .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", CBSAA)][, c("CBSAA") := NULL] 

ua <- dp[, lapply(.SD, sum),
         by = .(UAA),
         .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", UAA)][, c("UAA") := NULL]

cd <- dp[, lapply(.SD, sum),
         by = .(STATEA, CDA),
         .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", STATEA, "0", CDA)][, c("STATEA","CDA") := NULL]

sldu <- dp[, lapply(.SD, sum),
           by = .(STATEA, SLDUA),
           .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", STATEA, "0", SLDUA)][, c("STATEA","SLDUA") := NULL]

sldl <- dp[, lapply(.SD, sum),
           by = .(STATEA, SLDLA),
           .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", STATEA, "0", SLDLA)][, c("STATEA","SLDLA") := NULL]

sduni <- dp[, lapply(.SD, sum),
            by = .(STATEA, SDUNIA),
            .SDcols = H7V001_dp:H80010_dp][, gisjoin := paste0("G", STATEA, "0", SDUNIA)][, c("STATEA","SDUNIA") := NULL]

block <- dp[, lapply(.SD, sum),
            by = .(gisjoin),
            .SDcols = H7V001_dp:H80010_dp]

#### Clean up extra dts and gc() #### 
rm(dp)
rm(dt_nhgis)
rm(list=ls(pattern="p[0-9]"))
gc()
