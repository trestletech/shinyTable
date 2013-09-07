.initializedElements <- new.env()

#' Render a Handsontable Element
#' 
#' Render a Handsontable Shiny output.
#' @param expr The expression to be evaluated which should produce a data.frame
#' @param env The environment in which \code{expr} should be evaluated.
#' @param quoated Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#' @importFrom shiny exprToFunction
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' @export
renderHtable <- function(expr, env = parent.frame(), 
                        quoted = FALSE){
  func <- exprToFunction(expr, env, quoted)
  function(shinysession, name, ...) {
    data <- func()
    
    # Store the server-side data.frame in input
    shinysession$.input$set(name, data)
    
    # Only want to add this observer once -- so we'll only add it if the input
    # doesn't yet exist, indicating that this is the first time it was run.
    #print(.initializedElements)
    if (is.null(.initializedElements[[name]])) {
      .initializedElements[[name]] <- TRUE
      
      # Setup reactive listeners around client data
      observe({
        isolate(tbl <- shinysession$.input$get(name))
        
        changes <- shinysession$clientData[[paste("output_",name,"_changes", sep="")]]  
        
        tbl <- applyTableChanges(tbl, changes)
        
        shinysession$.input$set(name, tbl)
        
      }, priority=9999)
    }
    
    
    #TODO: surely a faster way to convert data.frame to array of arrays...
    arrayData <- t(apply(data, 1, as.character))
    cnames <- colnames(data)
    types <- getHtableTypes(data)
    
    return(list(
      data = arrayData,
      colnames = cnames,
      types = types
    ))
  }
}