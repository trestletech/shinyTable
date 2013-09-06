library(shiny)
library(shinyTable)

#' Define server logic required to generate simple table
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyServer(function(input, output) {
  output$tbl <- renderHtable({
    data.frame(list(a=1:2, b=3:4, c=c("hi", "test")))
  })
})