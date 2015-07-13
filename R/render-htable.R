.oldTables <- new.env()
.cycleCount <- new.env()

#' Render a Handsontable Element
#' 
#' Render a Handsontable Shiny output.
#' @param expr The expression to be evaluated which should produce a data.frame
#' @param env The environment in which \code{expr} should be evaluated.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#' @importFrom shiny exprToFunction
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' @export
renderHtable <- function(expr, env = parent.frame(), 
                        quoted = FALSE){
  func <- exprToFunction(expr, env, quoted)
  
  function(shinysession, name, ...) {
    data <- func()
    
    # Identify columns that are factors
    factorInd <- as.integer(which(sapply(data, class) == "factor"))
    if (any(factorInd)){
      warning ("Factors aren't currently supported. Will convert using as.character().")
      
      # Doesn't work with multiple columns at once, so iterate.
      #TODO: Optimize
      for (col in factorInd){
        data[,col] <- as.character(data[,col])
      }
    }
    
    if (is.null(shinysession$clientData[[paste("output_",name,"_init", sep="")]])){
      # Must be initializing, send whole table.
      
      .oldTables[[shinysession$token]][[name]] <- data
      
      types <- getHtableTypes(data)
      
      return(list(
        data = data,
        types = types,
        headers = colnames(data),
        rownames = rownames(data),
        cycle = .cycleCount[[shinysession$token]][[name]]
      ))
    } else{
      # input stores the state captured currently on the client. Just send the 
      # delta
      if (is.null(.oldTables[[shinysession$token]][[name]])){
        print("Null oldTbl")
        return(NULL)
      }
      
      if (is.null(data)){
        print("Null Data")
        return(NULL)
      }
      
      delta <- calcHtableDelta(.oldTables[[shinysession$token]][[name]], data)
      
      .oldTables[[shinysession$token]][[name]] <- data
      
      #TODO: support updating of types, colnames, rownames, etc.
      
      shinysession$session$sendCustomMessage("htable-change", 
                                             list(id=name, 
                                                  changes=delta,
                                                  cycle=.cycleCount[[shinysession$token]][[name]]))
      
      # Don't return any data, changes have already been sent.
      return(list(cycle=.cycleCount[[shinysession$token]][[name]]))
    }
  }
}