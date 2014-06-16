library(shiny)
library(shinyTable)

#' Define server logic required to generate simple table
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyServer(function(input, output, session) {
  # TODO: create and calc steps are running twice
  #   cache table is returned as all character

  values = reactiveValues()

  values$cachedTbl <- NULL

  output$tbl <- renderHtable({
    if (is.null(input$tbl)){
      rows <- 5
      # Seed the element with some data initially
      tbl <- round(matrix(rnorm(rows^2), ncol=rows), 5)

      # So RJSONIO clips numeric data after a few digits? 'Cause why would
      # anyone want more than a few digits of resolution anyways?
      # (Can we get a real JSON parser for R yet?) </rant>

      values$cachedTbl <<- tbl
      print("Create"); print(tbl)
      return(tbl)
    } else{
      values$cachedTbl <<- input$tbl
      print("Cache"); print(input$tbl)
      return(input$tbl)
    }
  })

  output$grid <- renderTable({
    if (!is.null(values$cachedTbl)) {
      grd = values$cachedTbl * 2
      print("Calc"); print(grd)
      grd
    }
  })
})