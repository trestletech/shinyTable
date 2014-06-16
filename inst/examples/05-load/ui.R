library(shiny)
library(shinyTable)
#' Define UI for application that demonstrates a simple Handsontable
#' @author Jeff Allen \email{jeff@@trestletech.com}
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Simple Shiny Table!"),

  sidebarPanel(
    helpText(HTML("A simple editable matrix used as a calculation input.
                  <p>Created using <a href = \"http://github.com/trestletech/shinyTable\">shinyTable</a>.")),
    textInput("file", "File Name", value="data.csv")
  ),

  # Show the simple table
  mainPanel(
    htable("tbl", colHeaders = "provided", contextMenu = TRUE),
    br(),
    tableOutput("grid")
  )
))