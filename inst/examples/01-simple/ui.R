library(shiny)
library(shinyTable)
#' Define UI for application that demonstrates a simple Handsontable
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Simple Shiny Table!"),
  
  sidebarPanel(
    #sliderInput("slider", "Number of rows:", 1, 26, 5),
    #HTML("<hr />"),
    helpText(HTML("A simple table with validation. The first column must be a number and if it's >= 100, it will be assigned the value of 99. Other columns can be anything.
                   Additionally, the second column has server-side styling applied and will highlight as 'invalid' any value &gt;= 100, and will 'warn' on values &gt;= 50.
                  <p>Created using <a href = \"http://github.com/trestletech/shinyTable\">shinyTable</a>."))
  ),
  
  # Show the simple table
  mainPanel(
    htable("tbl", colHeaders="provided")
  )
))