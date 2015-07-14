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
    stop("Unsupported object type. Can't extract column types.")
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

# Convert to specified class
# 
# @param x vector
# @param cls character
# @return converted vector
# @seealso https://stackoverflow.com/questions/9214819/supply-a-vector-to-classes-of-dataframe
# @author Jonathan Owen, jonathanro@@gmail.com
toCls = function(x, cls) tryCatch(do.call(paste("as", cls, sep = "."), list(x)),
                                  warning = function(w) do.call(as.character, list(x)))

# Covert htable output matrix to data.frame using classes of model data.frame
# 
# @param data htable matrix
# @param old original data.frame
# @return data.frame
# @seealso https://stackoverflow.com/questions/9214819/supply-a-vector-to-classes-of-dataframe
# @author Jonathan Owen, jonathanro@@gmail.com
setHtableClass = function(data, old) {
  if (class(old) == "matrix") {
    toCls(data, class(old[1, 1]))
  } else {
    data = as.data.frame(data, stringsAsFactors = FALSE)
    
    cls = sapply(old, class)
    
    # assume all cols are numeric, will be down coverted to character in toCls
    # is there a better way to track which columns were added or removed?
    if (length(cls) != ncol(data))
      cls = rep("numeric", ncol(data))
    
    data = replace(data, values = Map(toCls, data, cls))
  }
  data
}