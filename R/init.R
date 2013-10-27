.global <- new.env()

initResourcePaths <- function() {
  if (is.null(.global$loaded)) {
    shiny::addResourcePath(
      prefix = 'shinyTable',
      directoryPath = system.file('www', package='shinyTable'))
    .global$loaded <- TRUE
  }
  includeCSS(system.file("bundled-css.css", package="shinyTable"))
  
}