# Parse incoming HTable input from the client
.onLoad <- function(libname, pkgname){
  shiny::registerInputHandler("htable", function(val, shinysession, name){
    oldTbl <- .oldTables[[shinysession$token]][[name]]
    .cycleCount[[shinysession$token]][[name]] <- val$cycle

    if (!is.null(val$changes)) {
      for (cng in val$changes) {
        .cycleCount[[shinysession$token]][[name]] <- cng$cycle
        if (cng$type == "update") {
          tbl = applyTableChanges(oldTbl, cng$change)
        } else if (cng$type == "createRow") {
          tbl = addRow(oldTbl, cng$change$index, cng$change$count)
        } else if (cng$type == "removeRow") {
          tbl = delRow(oldTbl, cng$change$index, cng$change$count)
        } else if (cng$type == "createCol") {
          tbl = addCol(oldTbl, cng$change$index, cng$change$count)
        } else if (cng$type == "removeCol") {
          tbl = delCol(oldTbl, cng$change$index, cng$change$count)        
        } else {
          tbl = oldTbl
        }
      }
      .tblChanges[[shinysession$token]][[name]] = val$changes
    } else {
      tbl = oldTbl
    }
    
    tbl
  })
}