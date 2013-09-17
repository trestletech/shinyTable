library(shiny)
library(shinyTable)

#' Define server logic required to generate simple table
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyServer(function(input, output, session) {
  cachedTbl <- NULL
  
  output$tbl <- renderHtable({
    if (is.null(input$tbl)){
      rows <- 5
      # Seed the element with some data initially
      tbl <- data.frame(list(num1=as.character(1:rows), 
                      num2=as.character((1:rows)+5),
                      letter=LETTERS[1:(rows)]))
      
      cachedTbl <<- tbl
      return(tbl)
    } else{
      # Updates from client. The server has been made aware and can do some
      # validation or updates here, then send back the revised table. In this
      # case, we'll filter any number >= 100 in the first column.
      tbl <- input$tbl
      
      # Any non-numeric data should be replaced
      tbl[is.na(as.integer(as.character(tbl[,1]))),1] <- 
          as.character(cachedTbl[is.na(as.integer(as.character(tbl[,1]))),1])
      
      print(tbl)
      
      #tbl[as.integer(as.character(tbl[,1])) >= 100,1] <- 99
      cachedTbl <<- tbl
      return(tbl)
    }
  })  
})