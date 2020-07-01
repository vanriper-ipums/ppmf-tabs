# 5_create_dummy_variables.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script adds dummy variables to the dt. The initial version just creates a character vector 
# in this script. Future versions may read those in from a file

require(data.table)

#### Create character vector used to add fields to the data.table #### 
vars <- c("P0010001",
"P0030002",
"P0030003",
"P0030004",
"P0030005",
"P0030006",
"P0030007",
"P0030008",
"P0040002",
"P0040003",
"P0120002",
"P0120026",
"P0050003",
"P0050004",
"P0050005",
"P0050006",
"P0050007",
"P0050008",
"P0050009",
"P0050011",
"P0050012",
"P0050013",
"P0050014",
"P0050015",
"P0050016",
"P0050017",
"P0120003",
"P0120004",
"P0120005",
"P0120006",
"P0120007",
"P0120008",
"P0120009",
"P0120010",
"P0120011",
"P0120012",
"P0120013",
"P0120014",
"P0120015",
"P0120016",
"P0120017",
"P0120018",
"P0120019",
"P0120020",
"P0120021",
"P0120022",
"P0120023",
"P0120024",
"P0120025",
"P0120027",
"P0120028",
"P0120029",
"P0120030",
"P0120031",
"P0120032",
"P0120033",
"P0120034",
"P0120035",
"P0120036",
"P0120037",
"P0120038",
"P0120039",
"P0120040",
"P0120041",
"P0120042",
"P0120043",
"P0120044",
"P0120045",
"P0120046",
"P0120047",
"P0120048",
"P0120049"
)

#### Add vars to dt and set all equal to zero #### 
dt[, (vars) := 0]


