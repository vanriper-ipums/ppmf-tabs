# correct_column_order.r 
# Author: David Van Riper
# Created: 2020-07-05
# 
# This script generates vectors of column headers in the correct order. These vectors will be used 
# to create the final datasets with columns in correct order.

require(data.table)

#### Geog var vector #### 
# Create a geog var vector to concatenate onto correct_column_order vectors 
geog_vars <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")

#### Read in NHGIS state extract to get column headers in correct order #### 
sf1 <- fread("data/sf1/nhgis1333_ds172_2010_state.csv")

#### Keep only sf1_names that start with H* #### 
sf1_names <- grep("^H", names(sf1), value = TRUE)

#### Append '_dp' to each variable name #### 
sf1_names <- paste0(sf1_names, "_dp")

#### Extract columns for each set of tables #### 
cols_p1 <- grep("^H7V", sf1_names, value = TRUE)
cols_p3 <- grep("^H7X", sf1_names, value = TRUE)
cols_p4 <- grep("^H7Y", sf1_names, value = TRUE)
cols_p5 <- grep("^H7Z", sf1_names, value = TRUE)
cols_p8 <- grep("^H72", sf1_names, value = TRUE)
cols_p9 <- grep("^H73", sf1_names, value = TRUE)
cols_p10 <- grep("^H74", sf1_names, value = TRUE)
cols_p11 <- grep("^H75", sf1_names, value = TRUE)
cols_p12 <- grep("^H76", sf1_names, value = TRUE)
cols_p42 <- grep("^H80", sf1_names, value = TRUE)

#### Append the geog_vars to the table columns #### 
cols_p1_p3 <- c(geog_vars, cols_p1, cols_p3)
rm(cols_p3)
#cols_p3 <- c(geog_vars, cols_p3)
cols_p4 <- c(geog_vars, cols_p4)
cols_p5 <- c(geog_vars, cols_p5)
cols_p8 <- c(geog_vars, cols_p8)
cols_p9 <- c(geog_vars, cols_p9)
cols_p10 <- c(geog_vars, cols_p10)
cols_p11 <- c(geog_vars, cols_p11)
cols_p12 <- c(geog_vars, cols_p12)
cols_p42 <- c(geog_vars, cols_p42)


# col_order_p1_p3 <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK", "H7V001_dp",  "H7X001_dp", "H7X002_dp",  "H7X003_dp", "H7X004_dp",  "H7X005_dp",  "H7X006_dp",  "H7X007_dp",  "H7X008_dp")
# 
# col_order_p4 <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK", "H7Y001_dp", "H7Y002_dp", "H7Y003_dp")
# 
# col_order_p5 <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK",
#                   "H7Z001_dp",
#                   "H7Z002_dp", "H7Z003_dp" , "H7Z004_dp" , "H7Z005_dp" , "H7Z006_dp" , "H7Z007_dp" , "H7Z008_dp" , "H7Z009_dp",
#                   "H7Z010_dp", "H7Z011_dp" , "H7Z012_dp" , "H7Z013_dp" , "H7Z014_dp" , "H7Z015_dp" , "H7Z016_dp" , "H7Z017_dp"
# )
# 
# col_order_p8 <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")
# 
# col_order_p9 <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")
# 
# col_order_p10 <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")
# 
# col_order_p11 <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")
# 
# col_order_p12 <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")
# 
# col_order_p42 <- c("TABBLKST", "TABBLKCOU", "TABTRACTCE", "TABBLK")
# 
#   