# Parse incoming HTable input from the client
.onLoad <- function(libname, pkgname){
  shiny::registerInputHandler("htable", function(val, shinysession, name){
    oldTbl <- .oldTables[[shinysession$token]][[name]]
    .cycleCount[[shinysession$token]][[name]] <- val$cycle
    
    if (!is.null(val$changes)) {
      initTbl = oldTbl
      for (cng in val$changes) {
        .cycleCount[[shinysession$token]][[name]] <- cng$cycle
        if (cng$type == "update") {
          tbl = applyTableChanges(oldTbl, cng$change)
        } else if (cng$type == "createRow") {
          tbl = addRow(initTbl, cng$change$index, cng$change$count)
        } else if (cng$type == "removeRow") {
          tbl = delRow(initTbl, cng$change$index, cng$change$count)
        } else if (cng$type == "createCol") {
          tbl = addCol(initTbl, cng$change$index, cng$change$count)
        } else if (cng$type == "removeCol") {
          tbl = delCol(initTbl, cng$change$index, cng$change$count)        
        } else {
          tbl = initTbl
        }
        initTbl = tbl
      }
    } else {
      tbl = oldTbl
    }
    
    tbl
  })
}