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
  
  # Loop through each column, comparing the data
  for(i in 1:(max(ncol(new), ncol(old)))){
    
    thisColChanges <- NULL
    
    if (i > ncol(new)){
      # the new data.frame doesn't have this column 
      thisColChanges <- matrix(c(1:nrow(old), 
                                 rep(i, nrow(old)), 
                                 rep(NA, nrow(old)),
                                 old[,i])
                               , ncol=4)
    } else if (i > ncol(old)){
      # The old data.frame doesn't have this column
      thisColChanges <- matrix(c(1:nrow(new), 
                                 rep(i, nrow(new)), 
                                 new[,i], 
                                 rep(NA, nrow(new)))
                               , ncol=4)
    } else {
      # They both have this column
      deltaInd <- which(suppressWarnings(old[,i] != new[,i]))
      lng <- length(deltaInd)
      
      thisColChanges <- matrix(c(deltaInd, 
                                 rep(i, lng), 
                                 new[deltaInd, i], 
                                 old[deltaInd, i])
                               , ncol=4)  
    }
    
    if (zeroIndex && nrow(thisColChanges) > 0){
      thisColChanges[,1] <- as.integer(thisColChanges[,1]) - 1;
      thisColChanges[,2] <- as.integer(thisColChanges[,2]) - 1;
    }
    
    changes <- rbind(changes, thisColChanges)
  }
  return (changes)
}