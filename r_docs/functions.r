# functions.r
# Author: David Van Riper
# Created: 2020-07-01
# 
# This script contains the functions used in the PPMF tabulation production

cartesian_join <- function(i, j){
  # Cartesian join of two data.tables
  # If i has M rows and j has N rows, the result will have M*N rows
  # Example: cartesian_join(as.data.table(iris), as.data.table(mtcars))
  
  # Check inputs
  if(!is.data.table(i)) stop("'i' must be a data.table")
  if(!is.data.table(j)) stop("'j' must be a data.table")
  if(nrow(i) == 0) stop("'i' has 0 rows. Not sure how to handle cartesian join")
  if(nrow(j) == 0) stop("'j' has 0 rows. Not sure how to handle cartesian join")
  
  # Do the join (use a join column name that's unlikely to clash with a pre-existing column name)
  i[, MrJoinyJoin := 1L]
  j[, MrJoinyJoin := 1L]
  result <- j[i, on = "MrJoinyJoin", allow.cartesian = TRUE]
  result[, MrJoinyJoin := NULL]
  i[, MrJoinyJoin := NULL]
  j[, MrJoinyJoin := NULL]
  
  return(result[])
}
