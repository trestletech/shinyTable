library(shiny)
library(shinyTable)
#' Define UI for application that demonstrates a simple Handsontable
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Simple Shiny Table!"),
  
  sidebarPanel(
  
    HTML("<hr />"),
    helpText(HTML("Created using <a href = \"http://github.com/trestletech/shinyTable\">shinyTable</a>. <p>Example based on 'bivar' example by Daniel Adler."))
  ),
  
  # Show the simple table
  mainPanel(
    htableOutput("tbl")
  )
))