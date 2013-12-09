library(shiny)
library(shinyTable)

#' Define server logic required to generate simple table
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyServer(function(input, output, session) {
  cachedTbl <- NULL
  
  validate <- function(tbl){
    updateTableStyle(session, "tbl", "valid", 
                     which(as.numeric(tbl$num2) < 50), 2)
    updateTableStyle(session, "tbl", "warning", 
                     which(as.numeric(tbl$num2) >= 50 & 
                             as.numeric(tbl$num2) < 100), 2)
    updateTableStyle(session, "tbl", "invalid", 
                     which(as.numeric(tbl$num2) >= 100), 2)    
  }
  
  output$tbl <- renderHtable({
    if (is.null(input$tbl)){
      rows <- 5
      # Seed the element with some data initially
      tbl <- data.frame(list(num1=1:rows, 
                      num2=(1:rows)*20,
                      letter=LETTERS[1:(rows)]))
      rownames(tbl) <- LETTERS[2:(rows+1)]
      validate(tbl)
      
      cachedTbl <<- tbl      
      return(tbl)
    } else{
      # Updates from client. The server has been made aware and can do some
      # validation or updates here, then send back the revised table. In this
      # case, we'll filter any number >= 100 in the first column.
      tbl <- input$tbl
      
      # Any non-numeric data should be replaced with the cached data.
      tbl[is.na(as.integer(as.character(tbl[,1]))),1] <- 
          as.character(cachedTbl[is.na(as.integer(as.character(tbl[,1]))),1])
   
      validate(tbl)
      
      tbl[as.integer(as.character(tbl[,1])) >= 100,1] <- 99
      cachedTbl <<- tbl
      return(tbl)
    }
  })  
})