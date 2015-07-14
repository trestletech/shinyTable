#' Calculate data.frame differences
#' 
#' Calculate the differences in the data.frames provided
#' @param old The old data.frame
#' @param new The new data.frame
#' @return A matrix in which each row represents a change from the old to the
#'   new matrix in the form of [row, col, newVal, oldVal].
#' @author Jeff Allen \email{jeff@@trestletech.com}, Jonathan Owen \email{jonathanro@@gmail.com}, Tadeas Palusga \email{tadeas@@palusga.cz}
#' @export
calcHtableDelta <- function (old, new, zeroIndex = TRUE){
  changes <- NULL
  
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
      deltaInd <- which(suppressWarnings(old[,i] != new[,i]))
      lng <- length(deltaInd)
      
      thisColChanges <- data.frame(deltaInd, 
                                   rep(i, lng), 
                                   new[deltaInd, i], 
                                   old[deltaInd, i])  
    }
    
    if (is.logical(thisColChanges[, 3]))
      thisColChanges[, 3] = ifelse(thisColChanges[, 3], "true", "false")
    if (is.logical(thisColChanges[, 4]))
      thisColChanges[, 4] = ifelse(thisColChanges[, 4], "true", "false")
    
    if (zeroIndex && nrow(thisColChanges) > 0){
      thisColChanges[,1] <- as.integer(thisColChanges[,1]) - 1;
      thisColChanges[,2] <- as.integer(thisColChanges[,2]) - 1;
    }
    changes <- rbind(changes, thisColChanges)
  }
  
  if(!is.null(changes)) {
    colnames(changes) <- c("row", "col", "new", "old")
  }
  return (changes)
}