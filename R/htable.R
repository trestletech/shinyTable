#' Render a Handsontable
#' 
#' Render a Handsontable in an application page.
#' @param outputId The ID of the \code{glOutput} associated with this element
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' @export
htable <- function(outputId){
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