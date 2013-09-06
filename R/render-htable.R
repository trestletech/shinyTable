#' Render a Handsontable Element
#' 
#' Render a Handsontable Shiny output.
#' @param expr The expression to be evaluated which should produce a data.frame
#' @param env The environment in which \code{expr} should be evaluated.
#' @param quoated Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' @export
renderHtable <- function(expr, env = parent.frame(), 
                        quoted = FALSE){
  func <- exprToFunction(expr, env, quoted)
  function() {
    data <- func()
    
    #TODO: surely a faster way to convert data.frame to array of arrays...
    arrayData <- t(apply(data, 1, as.character))
    cnames <- colnames(data)
    types <- as.character(lapply(data, typeof))
    
    types[types == "double"] <- "numeric"
    types[types == "integer"] <- "numeric"
    types[types == "character"] <- ""
    
    return(list(
      data = arrayData,
      colnames = cnames,
      types = types
    ))
  }
}