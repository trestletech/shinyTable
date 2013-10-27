#' Parse incoming HTable input from the client
#' 
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' @export
parseShinyInput.htable <- function(val, shinysession, name){
  changes <- val$changes[[1]]
  cycle <- val$cycle
  
  .cycleCount[[shinysession$token]][[name]] <- cycle
  oldTbl <- .oldTables[[shinysession$token]][[name]]
  
  tbl <- applyTableChanges(oldTbl, changes)
  
  tbl
}