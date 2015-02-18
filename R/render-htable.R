.oldTables <- new.env()
.cycleCount <- new.env()
.tblChanges <- new.env()

#' Render a Handsontable Element
#' 
#' Render a Handsontable Shiny output.
#' @param expr The expression to be evaluated which should produce a data.frame
#' @param env The environment in which \code{expr} should be evaluated.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
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
    
    if (is.null(shinysession$clientData[[
      paste("output_", name, "_init", sep="")]]) || 
      is.null(.tblChanges[[shinysession$token]][[name]])) {
      # Must be initializing or server updated table, send whole table.
      
      if (is.null(data)){
        return(NULL)
      }
      
      .oldTables[[shinysession$token]][[name]] <- data
      
      types <- getHtableTypes(data)
      
      return(list(
        data = data,
        types = types,
        headers = colnames(data),
        rownames = rownames(data),
        cycle = .cycleCount[[shinysession$token]][[name]]
      ))
    } else {
      orig = .oldTables[[shinysession$token]][[name]]
      
      # input stores the state captured currently on the client. Just send the
      # delta
      if (is.null(orig)){
        print("Null oldTbl")
        return(NULL)
      }
      
      if (is.null(data)){
        print("Null Data")
        return(NULL)
      }

      # check for cell updates
      if (!is.na(Position(function(x) x$type %in% c("update"), 
                            .tblChanges[[shinysession$token]][[name]]))) {
        delta <- calcHtableDelta(orig, data)
        
        # Avoid the awkward serialization of a row-less matrix in RJSONIO
        if (nrow(delta) == 0){
          delta <- NULL
        }
      } else {
        delta <- NULL
      }
      
      # check for column or row changes
      cols = NULL
      deltaCol = NULL
      if (!is.na(Position(function(x) x$type %in% c("createCol", "removeCol"), 
                            .tblChanges[[shinysession$token]][[name]]))) {
        cols = colnames(data)

        for(i in Position(function(x) x$type %in% c("createCol", "removeCol"), 
                          .tblChanges[[shinysession$token]][[name]])) {
          x = .tblChanges[[shinysession$token]][[name]][[i]]
          deltaCol = c(deltaCol, ifelse(x$type == "createCol", 1, -1) * 
                         seq(x$change$index, x$change$index + x$change$count - 1))
        }
      }
      rws = NULL
      deltaRow = NULL
      if (!is.na(Position(function(x) x$type %in% c("createRow", "removeRow"), 
                            .tblChanges[[shinysession$token]][[name]]))) {
        rws = rownames(data)

        for(i in Position(function(x) x$type %in% c("createRow", "removeRow"), 
                          .tblChanges[[shinysession$token]][[name]])) {
          x = .tblChanges[[shinysession$token]][[name]][[i]]
          deltaRow = c(deltaRow, ifelse(x$type == "createRow", 1, -1) * 
                         seq(x$change$index, x$change$index + x$change$count - 1))
        }
      }
      
      # attempt to convert input to origial classes
      .oldTables[[shinysession$token]][[name]] <- setHtableClass(data, orig)
      
      #TODO: support updating of types, colnames, rownames, etc.
    
      shinysession$session$sendCustomMessage(
        "htable-change",
        list(id = name,
             changes = delta,
             colchanges = deltaCol,
             rowchanges = deltaRow,
             headers = cols,
             rownames = rws,
             cycle = .cycleCount[[shinysession$token]][[name]]))
      
      # Don't return any data, changes have already been sent.
      return(list(cycle=.cycleCount[[shinysession$token]][[name]]))
    }
  }
}
