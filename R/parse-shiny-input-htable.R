# Parse incoming HTable input from the client
.onLoad <- function(libname, pkgname){
  shiny::registerInputHandler("htable", function(val, shinysession, name){
    changes <- val$changes[[1]]
    cycle <- val$cycle

    .cycleCount[[shinysession$token]][[name]] <- cycle
    oldTbl <- .oldTables[[shinysession$token]][[name]]

    # column ops not currently supported when using obj for table
    if (!is.null(changes)) {
      if (changes$type == "update") {
        tbl = applyTableChanges(oldTbl, changes)
      } else if (changes$type == "createRow") {
        tbl = addRow(oldTbl, changes$change$index, changes$change$count)
      } else if (changes$type == "removeRow") {
        tbl = delRow(oldTbl, changes$change$index, changes$change$count)
      } else if (changes$type == "createCol") {
        tbl = addCol(oldTbl, changes$change$index, changes$change$count)
      } else if (changes$type == "removeCol") {
        tbl = delCol(oldTbl, changes$change$index, changes$change$count)        
      } else {
        tbl = oldTbl
      }
    } else {
      tbl = oldTbl
    }
  
    tbl
  })
}