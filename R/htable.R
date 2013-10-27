#' Render a Handsontable
#' 
#' Render a Handsontable in an application page.
#' @param outputId The ID of the \code{glOutput} associated with this element
#' @param headers Sets the way column headers should be displayed on the table.
#'   \code{enabled} implies that the default column names (progression through
#'   the alphabet) should be used. \code{disabled} implies that column headings
#'   should be disabled completely. \code{provided} implies that the column
#'   names should be extracted from the R object being displayed.
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' @export
htable <- function(outputId, headers=c("enabled", "disabled", "provided")){
  
  headers <- match.arg(headers)
  
  tagList(
    singleton(tags$head(
      initResourcePaths(),
      tags$script(src = 'shinyTable/shinyTable.js'),
      tags$script(src = 'shinyTable/jquery.handsontable.full.js'),
      tags$link(rel = 'stylesheet',
                type = 'text/css',
                href = 'shinyTable/jquery.handsontable.full.css')
    )),
    div(id=outputId, class="shiny-htable", 
        `data-htable-headers`=headers) 
  )
}