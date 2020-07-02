# 7_sum_dummy_vars_by_geography.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script groups dt by geography vars and sums the dummy variable columns, giving me counts.

require(data.table)

#### Sum dummy vars (specified in the .SDcols parameter) for specific geographies ####
# need to modify the variable options in the .SDcols based on what I use!
# county <- dt[, lapply(.SD, sum),
#      by = .(TABBLKST, TABBLKCOU),
#      .SDcols = H7Y002_dp:H7V001_dp]

block <- dt[, lapply(.SD, sum),
             by = .(TABBLKST, TABBLKCOU, TABTRACTCE, TABBLK),
             .SDcols = H7Y002_dp:H7V001_dp]