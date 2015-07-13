#' Apply Changes to Htable
#' 
#' Apply the changes as passed from htable to a data.frame
#' @param table The htable data.frame
#' @param changes A single change (in an array of length 4) or a 2D array of 
#'   multiple changes to apply, in the format used by 
#'   Handsontable. Each array should be of the form 
#'   [row, col, oldValue, newValue] using 0-based-indexing to identify row and
#'   col.
#' @param trim if \code{TRUE}, will trim any leading or trailing whitespace from
#'   the relevant values.
#' @return The data.frame provided with the changes applied
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' @export
applyTableChanges <- function(table, changes, trim=TRUE){
  if (is.null(changes)){
    return(table)
  }
  if (length(changes) == 4 || length(changes[0] == 0)){
    return (applyChange(table, changes, trim))
  } else{
    # This is a 2D array of changes to be applied.
    for (i in 1:length(changes)){
      table <- applyChange(table, changes[i], trim)
    }
    return (table)
  }
}

#' Apply a single change to the table.
#' @param table The htable data.frame
#' @param changes An array of length 4 of changes to apply, in the form of
#'   [row, col, oldValue, newValue] using 0-based-indexing
#' @param trim if \code{TRUE}, will trim any leading or trailing whitespace from
#'   the relevant values.
#' @return The data.frame provided with the change applied.
#' @author Jeff Allen \email{jeff@@trestletech.com}
applyChange <- function(table, change, trim=TRUE){
  if (length(change) != 4){
    stop(paste("Invalid change to be applied:", paste(change, collapse=",")))
  }
  # Extract and shift to 1-based-indexing
  row <- as.integer(change[1]) + 1
  col <- as.integer(change[2]) + 1
  old <- setHtableClass(change[3], table[row, col])[1, 1]
  new <- change[4]
  
  if (trim){
    old <- strtrim(old)
    new <- strtrim(new)
  }
  
  if (as.character(table[row,col]) != as.character(old)){
    warning(paste("The old value for the cell in the change provided ('", 
                  table[row, col],
                  "') does not match the value provided by the client ('",
                  old, "').", sep=""))
  }
  
  table[row, col] <- new
  return (table)
}

#' Trim trailing or leading whitespace from a string.
strtrim <- function(string){
  classes <- class(string[[1]])
  string <- sub('^\\s*', '', string)
  string <- sub('\\s*$', '', string)
  class(string) <- classes
  string
}