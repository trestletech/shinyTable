library(shiny)
library(shinyTable)

#' Define server logic required to generate simple table
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyServer(function(input, output, session) {
  output$tbl <- renderHtable({
    rows <- 5
    # Seed the element with some data initially
    tbl <- data.frame(list(num1=1:rows, 
                    num2=(1:rows)*20,
                    letter=LETTERS[1:(rows)]))
    return(tbl)
  })
  
  output$clickText <- renderPrint({
    input$tblClick
  })
})