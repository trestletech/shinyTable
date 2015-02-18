library(shiny)
library(shinyTable)

#' Define server logic required to generate simple table
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyServer(function(input, output, session) {
  cachedMat <- NULL
  cachedDf <- NULL
  
  output$mat <- renderHtable({
    if (is.null(input$mat) && is.null(cachedMat)){
      rows <- 5
      # Seed the element with some data initially
      tbl <- round(matrix(rnorm(rows^2), ncol=rows), 5)
      colnames(tbl) = paste0("A", 1:5)
      
      # So RJSONIO clips numeric data after a few digits? 'Cause why would
      # anyone want more than a few digits of resolution anyways?
      # (Can we get a real JSON parser for R yet?) </rant>
      
      cachedMat <<- tbl
      print(tbl)
      return(tbl)
    } else if (!is.null(input$mat)) {
      cachedMat <<- input$mat
      print(input$mat)
      return(input$mat)
    }
  })
  
  output$df <- renderHtable({
    if (is.null(input$df) && is.null(cachedDf)){
      rows <- 5
      # Seed the element with some data initially
      tbl <- data.frame(round(matrix(rnorm(rows^2), ncol=rows), 5))
      colnames(tbl) = paste0("B", 1:5)
      
      # So RJSONIO clips numeric data after a few digits? 'Cause why would
      # anyone want more than a few digits of resolution anyways?
      # (Can we get a real JSON parser for R yet?) </rant>
      
      cachedDf <<- tbl
      print(tbl)
      return(tbl)
    } else if (!is.null(input$df)) {
      cachedDf <<- input$df
      print(input$df)
      return(input$df)
    }
  }) 
})