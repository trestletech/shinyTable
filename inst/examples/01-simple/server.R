library(shiny)
library(shinyTable)

#' Define server logic required to generate simple table
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyServer(function(input, output, session) {
  output$tbl <- renderHtable({
    if (is.null(input$tbl)){
      # Seed the element with some data initially
      data.frame(list(num1=1:input$slider, num2=(1:input$slider)+5, 
                      letter=LETTERS[1:(input$slider)]))
    } else{
      # Updates from client. The server has been made aware and can do some
      # validation or updates here, then send back the revised table. In this
      # case, we'll filter any number >= 100 in the first column.
      tbl <- input$tbl
      tbl[as.integer(tbl[,1]) >= 100,1] <- 99
      tbl
    }
  })
  
  
})