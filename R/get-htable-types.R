#' Calculate HTable-Compatible Type Names
#' 
#' Given a data.frame, extract the classes of each column and convert them to 
#' the nomenclature used by Handsontable.
#' @param data The data.frame to analyze.
#' @author Jeff Allen \email{jeff@@trestletech.com}
getHtableTypes <- function(data){
  types <- as.character(lapply(data, class))
  
  types <- sapply(types, function(type){
    switch(type,
           integer="numeric",
           numeric="numeric",
           character="text",
           logical="checkbox",
           factor="text",
           Date="date",
           "text")
  })
  
  as.character(types)
}