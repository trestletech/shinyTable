library(shiny)
library(shinyTable)


#' Define server logic required to generate simple table
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyServer(function(input, output, session) {
  # TODO: 
  #   - create and running twice - input doesn't appear to be updated until
  #     outputs are rendered
  #   - cache table is returned as all character
  #   - applyChange warning 
  
  values = reactiveValues()
  
  values$cachedTbl <- NULL
  
  loadData <- reactive({
    if (!is.null(input$file))
      read.csv(input$file, header=TRUE)
  })
  
  output$tbl <- renderHtable({
    if (is.null(input$tbl) && is.null(values$cachedTbl) && 
          !is.null(loadData())){
      tbl <- loadData()
      values$cachedTbl <<- tbl
      print("Create"); print(tbl)
      return(tbl)
    } else if (!is.null(input$tbl)) {
      values$cachedTbl <<- input$tbl
      print("Cache input"); print(input$tbl)
      return(input$tbl)
    } else if (!is.null(values$cachedTbl)) {
      print("Cache table"); print(values$cachedTbl)
      return(values$cachedTbl)
    }
  })
  
  output$grid <- renderTable({
    if (!is.null(values$cachedTbl)) {
      print("Calc before"); print(values$cachedTbl)
      grd = values$cachedTbl * 2
      print("Calc after"); print(grd)
      grd
    }
  })
})