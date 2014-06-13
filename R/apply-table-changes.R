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
  for (i in 1:length(changes)){
      table <- applyChange(table, changes$change[[1]], trim)
  }
  return (table)
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
  old <- change[3]
  new <- change[4]
  
  if (trim){
    old <- strtrim(old)
    new <- strtrim(new)
  }
  
  if (!(is.null(old) && is.na(table[row, col])) ||
        as.character(table[row, col]) != as.character(old)){
    warning(paste("The old value for the cell in the change provided ('", 
                  table[row, col],
                  "') does not match the value provided by the client ('",
                  old, "').", sep=""))
  }
  
  table[row, col] <- new
  return (table)
}

addRow = function(table, ind, ct) {
  uptd <- rbind(table[seq(1, ind), ],
                matrix(NA, ncol=ncol(table), nrow=ct))
  if (nrow(table) > ind) 
    uptd <- rbind(uptd, table[seq(ind + 1, nrow(table)), ])
  
  return (uptd)
}

delRow = function(table, ind, ct) {
  uptd <- table[-seq(ind + 1, length=ct), ]
  
  return (uptd)
}

addCol = function(table, ind, ct) {
  uptd <- cbind(table[, seq(1, ind)],
               matrix(NA, nrow=nrow(table), ncol=ct))
  if (ncol(table) > ind)
    uptd <- cbind(uptd, table[, seq(ind + 1, ncol(table))])
  
  return (uptd)
}

delCol = function(table, ind, ct) {
  uptd <- table[, -seq(ind + 1, length=ct)]
  
  return (uptd)
}

#' Trim trailing or leading whitespace from a string.
strtrim <- function(string){
  classes <- class(string[[1]])
  string <- sub('^\\s*', '', string)
  string <- sub('\\s*$', '', string)
  class(string) <- classes
  string
}
