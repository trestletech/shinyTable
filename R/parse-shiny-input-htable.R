# Parse incoming HTable input from the client
.onLoad <- function(libname, pkgname){
  shiny::registerInputHandler("htable", function(val, shinysession, name){
    changes <- val$changes[[1]]
    cycle <- val$cycle
    
    .cycleCount[[shinysession$token]][[name]] <- cycle
    oldTbl <- .oldTables[[shinysession$token]][[name]]
    
    tbl <- applyTableChanges(oldTbl, changes)
    
    tbl
  })
}