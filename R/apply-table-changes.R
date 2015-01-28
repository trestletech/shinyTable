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
  # This is a 2D array of changes to be applied.
  for (i in 1:length(changes)){
    table <- applyChange(table, unlist(changes[i]), trim)
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
  # Extract and shift to 1-based-indexing
  row <- as.integer(change[1]) + 1
  col <- as.integer(change[2]) + 1
  
  old <- change[3]
  if (length(change) == 4) {
    # cell update
    new <- change[4]
  } else if (length(change) == 3) {
    # update to new column with no value
    new <- change[3]
  } else {
    stop(paste("Invalid change to be applied:", paste(change, collapse=",")))
  }
  
  if (trim){
    old <- strtrim(old)
    new <- strtrim(new)
  }
  
  if (!is.na(table[row,col]) && 
        as.character(table[row,col]) != as.character(old)) {
    warning(paste("The old value for the cell in the change provided ('", 
                  table[row, col],
                  "') does not match the value provided by the client ('",
                  old, "').", sep=""))
  }
  
  table[row, col] <- toCls(new, class(table[row, col]))
  return (table)
}

#' Adds a row to a table.
#' @param table The htable data.frame
#' @param ind The 0 based index location to add the row
#' @param ct The number of rows to add
#' @return The data.frame provided with the change applied.
addRow = function(table, ind, ct) {
  conv_vect = function(x) as.matrix(x)
  if (is.vector(table)) {
    table = conv_vect(table)
    vect_in = TRUE
  } else {
    vect_in = FALSE
  }
 
  new_rows = matrix(NA, ncol=ncol(table), nrow=ct)
  rownames(new_rows) = ind + 1
  if (class(table) != "matrix")
    new_rows <- as.data.frame(new_rows)
  new_rows <- setHtableClass(new_rows, table)  
  colnames(new_rows) <- colnames(table)
  
  if (ind == 0) {
    uptd <- rbind(new_rows, table)
  } else if (nrow(table) == ind) {
    uptd <- rbind(table, new_rows)
  } else  {
    if (vect_in || ncol(table) == 1)
      uptd <- rbind(rbind(conv_vect(table[seq(1, ind), ]), new_rows), 
                    conv_vect(table[seq(ind + 1, nrow(table)), ]))
    else
      uptd <- rbind(rbind(table[seq(1, ind), ], new_rows), 
                    table[seq(ind + 1, nrow(table)), ])
  }
  
  return (uptd)
}

#' Deletes a row from a table.
#' @param table The htable data.frame
#' @param ind The 0 based index location to delete the row
#' @param ct The number of rows to delete
#' @return The data.frame provided with the change applied.
delRow = function(table, ind, ct) {
  uptd <- table[-seq(ind + 1, length=ct), ]
  
  return (uptd)
}

#' Adds a column to a table.
#' @param table The htable data.frame
#' @param ind The 0 based index location to add the column
#' @param ct The number of columns to add
#' @return The data.frame provided with the change applied.
addCol = function(table, ind, ct) {
  conv_vect = function(x) t(as.matrix(x))
  if (is.vector(table)) {
    table = conv_vect(table)
    vect_in = TRUE
  } else {
    vect_in = FALSE
  }

  new_cols <- matrix(NA, nrow=nrow(table), ncol=ct)
  colnames(new_cols) <- paste0("X", ind + 1)
  
  if (ind == 0) {
    uptd <- cbind(new_cols, table)
  } else if (ncol(table) == ind) {
    uptd <- cbind(table, new_cols)
  } else {
    if (vect_in)
      uptd <- cbind(cbind(conv_vect(table[, seq(1, ind)]), new_cols), 
                    conv_vect(table[, seq(ind + 1, ncol(table))]))
    else
      uptd <- cbind(cbind(table[, seq(1, ind)], new_cols), 
                    table[, seq(ind + 1, ncol(table))])
    colnames(uptd) = c(colnames(table)[seq(1, ind)], colnames(new_cols),
                       colnames(table)[seq(ind + 1, ncol(table))])
                       
  }
    
  return (uptd)
}

#' Deletes a column from a table.
#' @param table The htable data.frame
#' @param ind The 0 based index location to delete the column
#' @param ct The number of columns to delete
#' @return The data.frame provided with the change applied.
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