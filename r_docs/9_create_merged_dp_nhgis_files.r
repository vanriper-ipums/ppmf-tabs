# 9_create_final_files.r
# Author: David Van Riper
# Created: 2020-07-06
# 
# This script loads the sf_* nhgis files and merges them with dts from 8_create_dp_summary_files.r (except
# for blocks right now).

require(data.table)

#### Load sf_* files from NHGIS #### 
nhgis_path <- "data/sf1/nhgis1336_csv/sf_nhgis1336_ds172_2010_"
nhgis_path <- "data/sf1/nhgis1348_csv/sf_nhgis1348_ds172_2010_"
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
aianhh_144_n <- fread(paste0(nhgis_path, "aianhh_144.csv"))
county_282_n <- fread(paste0(nhgis_path, "county_282.csv"))
cty_sub_261_n <- fread(paste0(nhgis_path, "cty_sub_261.csv"))
#block_n <- fread(paste0(nhgis_path, "block.csv"))

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
aianhh_144_n <- aianhh_144[aianhh_144_n, on = "gisjoin"]
county_282_n <- county_282[county_282_n, on = "gisjoin"]
cty_sub_261_n <- cty_sub_261[cty_sub_261_n, on = "gisjoin"]
#block_n <- block[block_n, on = "gisjoin"]

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
setkey(aianhh_144_n, gisjoin)
setkey(county_282_n, gisjoin)
setkey(cty_sub_261_n, gisjoin)
#setkey(block_n, gisjoin)

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
aianhh_144_n[is.na(aianhh_144_n)] = 0
county_282_n[is.na(county_282_n)] = 0
cty_sub_261_n[is.na(cty_sub_261_n)] = 0
#block_n[is.na(block_n)] = 0

#### Substring to add state fips code ####
state_n <- state_n[, state := substr(gisjoin, 2, 3)]
county_n <- county_n[, state := substr(gisjoin, 2, 3)]
tract_n <- tract_n[, state := substr(gisjoin, 2, 3)]
blkgrp_n <- blkgrp_n[, state := substr(gisjoin, 2, 3)]
place_n <- place_n[, state := substr(gisjoin, 2, 3)]
cousub_n <- cousub_n[, state := substr(gisjoin, 2, 3)]
cd_n <- cd_n[, state := substr(gisjoin, 2, 3)]
sldl_n <- sldl_n[, state := substr(gisjoin, 2, 3)]
sldu_n <- sldu_n[, state := substr(gisjoin, 2, 3)]
sduni_n <- sduni_n[, state := substr(gisjoin, 2, 3)]
aianhh_144_n <- aianhh_144_n[, state := substr(gisjoin, 2, 3)]
county_282_n <- county_282_n[, state := substr(gisjoin, 2, 3)]
cty_sub_261_n <- cty_sub_261_n[, state := substr(gisjoin, 2, 3)]
#block_n <- block_n[, state := substr(gisjoin, 2, 3)]

#### Reorder columns to move gisjoin and name to beginning of dt #### 
# Generate correct column order for all final dt
dt_names <- names(state_n)
elements_to_remove <- c("gisjoin", "name", "state")
dt_names <- dt_names[!(dt_names %in% elements_to_remove)]
dt_names_state <- c("gisjoin", "name", "state", dt_names)
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
setcolorder(aianhh_144_n, dt_names_state)
setcolorder(county_282_n, dt_names_state)
setcolorder(cty_sub_261_n, dt_names_state)
#setcolorder(block_n, dt_names_state)

#### Write out to final file #### 
file_name_stub <- "nhgis_ppdd_20200527_"
out_path <- "data/output/"

fwrite(state_n, paste0(out_path, file_name_stub, "state.csv"))
fwrite(county_n, paste0(out_path, file_name_stub, "county.csv"))
fwrite(tract_n, paste0(out_path, file_name_stub, "tract.csv"))
fwrite(cousub_n, paste0(out_path, file_name_stub, "cty_sub.csv"))
fwrite(place_n, paste0(out_path, file_name_stub, "place.csv"))
fwrite(blkgrp_n, paste0(out_path, file_name_stub, "blck_grp.csv"))
fwrite(aianhh_n, paste0(out_path, file_name_stub, "aianhh.csv"))
fwrite(anrc_n, paste0(out_path, file_name_stub, "anrc.csv"))
fwrite(cbsa_n, paste0(out_path, file_name_stub, "cbsa.csv"))
fwrite(ua_n, paste0(out_path, file_name_stub, "urb_area.csv"))
fwrite(cd_n, paste0(out_path, file_name_stub, "cd_110th-112th.csv"))
fwrite(sldl_n, paste0(out_path, file_name_stub, "stleg_lo.csv"))
fwrite(sldu_n, paste0(out_path, file_name_stub, "stleg_up.csv"))
fwrite(sduni_n, paste0(out_path, file_name_stub, "sd_uni.csv"))
fwrite(aianhh_144_n, paste0(out_path, file_name_stub, "aianhh_144.csv"))
fwrite(county_282_n, paste0(out_path, file_name_stub, "county_282.csv"))
fwrite(cty_sub_261_n, paste0(out_path, file_name_stub, "cty_sub_261.csv"))
#fwrite(block_n, paste0(out_path, file_name_stub, "block.csv"))
