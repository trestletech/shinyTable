#' Calculate HTable-Compatible Type Names
#'
#' Given a data.frame, extract the classes of each column and convert them to
#' the nomenclature used by Handsontable.
#' @param data The data.frame to analyze.
#' @author Jeff Allen \email{jeff@@trestletech.com}
getHtableTypes <- function(data){
  if (is.matrix(data)){
    types <- typeof(data)
  } else if (is.data.frame(data)){
    types <- as.character(lapply(data, class))
  } else{
    stop("Unsupported object type:", class(data), "Can't extract column types.")
  }

  types <- sapply(types, function(type){
    switch(type,
           integer="text",
           double="text",
           numeric="text",
           character="text",
           logical="checkbox",
           factor="text",
           Date="date",
           "text")
  })

  as.character(types)
}