.global <- new.env()

initResourcePaths <- function() {
  if (is.null(.global$loaded)) {
    shiny::addResourcePath(
      prefix = 'shinyTable',
      directoryPath = system.file('www', package='shinyTable'))
    .global$loaded <- TRUE
  }
  HTML("")
}