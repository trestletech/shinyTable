#' Update the styling of a cell
#' 
#' Update the style of a particular cell.
#' @param session The associated shiny session
#' @param tableID The ID of the table we are to update
#' @param class The class to set for this table element. You are free to define
#'   your own CSS to dictate the styling for any class. Three class names are
#'   provided with shinyTable: 'valid' (the default), 'invalid', and 'warning'.
#' @param row The row number of the cell (1-indexed).
#' @param col The column number of the cell to update (1-indexed)
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' @export
updateTableStyle <- function(session, tableID, class, row, col){
  if (!length(row) || !length(col)){
    return(NULL)
  }  
  
  style <- list (row=row-1, col=col-1, cssClass=class)
  session$sendCustomMessage("htable-style", 
                             list(id=tableID, 
                                  style=style))
}