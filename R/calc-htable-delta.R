#' Calculate data.frame differences
#' 
#' Calculate the differences in the data.frames provided
#' @param old The old data.frame
#' @param new The new data.frame
#' @return A matrix in which each row represents a change from the old to the
#'   new matrix in the form of [row, col, newVal, oldVal].
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' @export
calcHtableDelta <- function (old, new, zeroIndex = TRUE){
  changes <- matrix(ncol=4, nrow=0)
  colnames(changes) <- c("row", "col", "new", "old")
  
  if (is.vector(old)) {
    if (ncol(new) > nrow(new))
      old <- t(as.matrix(old))
    else
      old <- as.matrix(old)
  }
  
  # handle adds/deletes
  if (is.null(dim(new)) || any(dim(old) != dim(new)))
    return (changes)
  
  # Loop through each column, comparing the data
  for(i in 1:(max(ncol(new), ncol(old)))){
    
    thisColChanges <- NULL
    
    if (i > ncol(new)){
      # the new data.frame doesn't have this column 
      thisColChanges <- data.frame(1:nrow(old), 
                                   rep(i, nrow(old)), 
                                   rep(NA, nrow(old)),
                                   old[,i])
    } else if (i > ncol(old)){
      # The old data.frame doesn't have this column
      thisColChanges <- data.frame(1:nrow(new), 
                                   rep(i, nrow(new)), 
                                   new[,i], 
                                   rep(NA, nrow(new)))
    } else {
      # They both have this column
      deltaInd <- which(!compareNA(old[,i], new[,i]))
      lng <- length(deltaInd)
      
      if (nrow(old) < nrow(new))
        val_old <- rep(NA, lng)
      else
        val_old <- old[deltaInd, i]
      thisColChanges <- data.frame(deltaInd, 
                                   rep(i, lng), 
                                   new[deltaInd, i], 
                                   val_old)  
    }
    
    if (zeroIndex && nrow(thisColChanges) > 0){
      thisColChanges[,1] <- as.integer(thisColChanges[,1]) - 1;
      thisColChanges[,2] <- as.integer(thisColChanges[,2]) - 1;
    }
    
    changes <- rbind(changes, thisColChanges)
  }
  return (changes)
}

#' This function returns TRUE wherever elements are the same, including NA's.
#'  
#' @param v1
#' @param v2
#' @return boolean
#' @seealso http://www.cookbook-r.com/Manipulating_data/Comparing_vectors_or_factors_with_NA/
compareNA <- function(v1, v2) {
  mind <- min(length(v1), length(v2))
  
  same <- (v1[1:mind] == v2[1:mind])  |  (is.na(v1[1:mind]) & is.na(v2[1:mind]))
  same[is.na(same)] <- FALSE
  
  mxind <- max(length(v1), length(v2))
  if (mind != mxind)
    same <- c(same, rep(FALSE, mxind - mind))
  return(same)
}
