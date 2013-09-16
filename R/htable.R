#' Render a Handsontable
#' 
#' Render a Handsontable in an application page.
#' @param outputId The ID of the \code{glOutput} associated with this element
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' @export
htable <- function(outputId){
  tryCatch({
    # Try adding the input handler, it will stop if there's already a handler.
    # Perhaps should consider adding an exists() function for input handlers.
    addInputType("htable", function(val, shinysession, name){
      changes <- val[[1]]
      
      oldTbl <- .oldTables[[shinysession$token]][[name]]
      
      tbl <- applyTableChanges(oldTbl, changes)
      
      tbl
    })
  }, error=function(e){})
  
  tagList(
    singleton(tags$head(
      initResourcePaths(),
      tags$script(src = 'shinyTable/shinyTable.js'),
      tags$script(src = 'shinyTable/jquery.handsontable.full.js'),
      tags$link(rel = 'stylesheet',
                type = 'text/css',
                href = 'shinyTable/jquery.handsontable.full.css')
    )),
    div(id=outputId, class="shiny-htable") 
  )
}