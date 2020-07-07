# 9_create_final_files.r
# Author: David Van Riper
# Created: 2020-07-06
# 
# This script loads the sf_* nhgis files and merges them with dts from 8_create_dp_summary_files.r (except
# for blocks right now).

require(data.table)

#### Load sf_* files from NHGIS #### 
nhgis_path <- "data/sf1/nhgis1336_csv/sf_nhgis1336_ds172_2010_"
state_n <- fread(paste0(nhgis_path, "state.csv"))
county_n <- fread(paste0(nhgis_path, "county.csv"))
tract_n <- fread(paste0(nhgis_path, "tract.csv"))
cousub_n <- fread(paste0(nhgis_path, "cty_sub.csv"))
place_n <- fread(paste0(nhgis_path, "place.csv"))
blkgrp_n <- fread(paste0(nhgis_path, "blck_grp.csv"))
aianhh_n <- fread(paste0(nhgis_path, "aianhh.csv"))
anrc_n <- fread(paste0(nhgis_path, "anrc.csv"))
cbsa_n <- fread(paste0(nhgis_path, "cbsa.csv"))
ua_n <- fread(paste0(nhgis_path, "urb_area.csv"))
cd_n <- fread(paste0(nhgis_path, "cd110th-112th.csv"))
sldu_n <- fread(paste0(nhgis_path, "stleg_up.csv"))
sldl_n <- fread(paste0(nhgis_path, "stleg_lo.csv"))
sduni_n<- fread(paste0(nhgis_path, "sd_uni.csv"))
block <- fread(paste0(nhgis_path, "block.csv"))

#### remove dupes from anrc_n ####
anrc_n <- unique(anrc_n)

#### Join DP to SF dt #### 
state_n <- state[state_n, on = "gisjoin"]
county_n <- county[county_n, on = "gisjoin"]
tract_n <- tract[tract_n, on = "gisjoin"]
cousub_n <- cousub[cousub_n, on = "gisjoin"]
place_n <- place[place_n, on = "gisjoin"]
blkgrp_n <- blkgrp[blkgrp_n, on = "gisjoin"]
aianhh_n <- aianhh[aianhh_n, on = "gisjoin"]
anrc_n <- anrc[anrc_n, on = "gisjoin"]
cbsa_n <- cbsa[cbsa_n, on = "gisjoin"]
ua_n <- ua[ua_n, on = "gisjoin"]
cd_n <- cd[cd_n, on = "gisjoin"]
sldu_n <- sldu[sldu_n, on = "gisjoin"]
sldl_n <- sldl[sldl_n, on = "gisjoin"]
sduni_n <- sduni[sduni_n, on = "gisjoin"]
block_n <- block[block_n, on = "gisjoin"]

#### setkeys for all dts for sort order #### 
setkey(state_n, gisjoin)
setkey(county_n, gisjoin)
setkey(tract_n, gisjoin)
setkey(cousub_n, gisjoin)
setkey(place_n, gisjoin)
setkey(blkgrp_n, gisjoin)
setkey(aianhh_n, gisjoin)
setkey(anrc_n, gisjoin)
setkey(cbsa_n, gisjoin)
setkey(ua_n, gisjoin)
setkey(cd_n, gisjoin)
setkey(sldu_n, gisjoin)
setkey(sldl_n, gisjoin)
setkey(sduni_n, gisjoin)
setkey(block_n, gisjoin)

#### Fill in missing values with zeroes after joining NHGIS data #### 
state_n[is.na(state_n)] = 0
county_n[is.na(county_n)] = 0
tract_n[is.na(tract_n)] = 0
blkgrp_n[is.na(blkgrp_n)] = 0
cousub_n[is.na(cousub_n)] = 0
place_n[is.na(place_n)] = 0
aianhh_n[is.na(aianhh_n)] = 0
anrc_n[is.na(anrc_n)] = 0
cbsa_n[is.na(cbsa_n)] = 0
ua_n[is.na(ua_n)] = 0
cd_n[is.na(cd_n)] = 0
sldu_n[is.na(sldu_n)] = 0
sldl_n[is.na(sldl_n)] = 0
sduni_n[is.na(sduni_n)] = 0
block_n[is.na(block_n)] = 0

#### Reorder columns to move gisjoin and name to beginning of dt #### 
# Generate correct column order for all final dt
dt_names <- names(state_n)
elements_to_remove <- c("gisjoin", "name", "STATEA")
dt_names <- dt_names[!(dt_names %in% elements_to_remove)]
dt_names_state <- c("gisjoin", "name", "STATEA", dt_names)
dt_names_nostate <- c("gisjoin", "name", dt_names)

# Set column order for each dt 
setcolorder(state_n, dt_names_state)
setcolorder(county_n, dt_names_state)
setcolorder(tract_n, dt_names_state)
setcolorder(blkgrp_n, dt_names_state)
setcolorder(cousub_n, dt_names_state)
setcolorder(place_n, dt_names_state)
setcolorder(aianhh_n, dt_names_nostate)
setcolorder(anrc_n, dt_names_nostate)
setcolorder(cbsa_n, dt_names_nostate)
setcolorder(ua_n, dt_names_nostate)
setcolorder(cd_n, dt_names_state)
setcolorder(sldl_n, dt_names_state)
setcolorder(sldu_n, dt_names_state)
setcolorder(sduni_n, dt_names_state)
setcolorder(block_n, dt_names_state)

#### Write out to final file #### 
out_path <- "data/output/"

fwrite(state_n, paste0(out_path, "state_20200527.csv"))
fwrite(county_n, paste0(out_path, "county_20200527.csv"))
fwrite(tract_n, paste0(out_path, "tract_20200527.csv"))
fwrite(cousub_n, paste0(out_path, "cousub_20200527.csv"))
fwrite(place_n, paste0(out_path, "place_20200527.csv"))
fwrite(blkgrp_n, paste0(out_path, "blck_grp_20200527.csv"))
fwrite(aianhh_n, paste0(out_path, "aianhh_20200527.csv"))
fwrite(anrc_n, paste0(out_path, "anrc_20200527.csv"))
fwrite(cbsa_n, paste0(out_path, "cbsa_20200527.csv"))
fwrite(ua_n, paste0(out_path, "urb_area_20200527.csv"))
fwrite(cd_n, paste0(out_path, "cd_110th-112th_20200527.csv"))
fwrite(sldl_n, paste0(out_path, "stleg_lo_20200527.csv"))
fwrite(sldu_n, paste0(out_path, "stleg_up_20200527.csv"))
fwrite(sduni_n, paste0(out_path, "sd_uni_20200527.csv"))
fwrite(block_n, paste0(out_path, "block_20200527.csv"))
