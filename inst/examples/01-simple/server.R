library(shiny)
library(shinyTable)

#' Define server logic required to generate simple table
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyServer(function(input, output) {
  output$tbl <- renderHtable({
    data.frame(list(num1=1:input$slider, num2=(1:input$slider)+5, letter=LETTERS[1:(input$slider)]))
  })
})