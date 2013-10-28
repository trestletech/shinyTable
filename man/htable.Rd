\name{htable}
\alias{htable}
\title{Render a Handsontable}
\usage{
  htable(outputId, clickId = NULL,
    headers = c("enabled", "disabled", "provided"))
}
\arguments{
  \item{outputId}{The ID of the \code{glOutput} associated
  with this element}

  \item{clickId}{If not NULL, will expose a new input using
  the given name which provides a named list giving the row
  and column numbers of the currently selected cell(s) in
  the table (1-indexed). Additionally, it will provice `r2`
  and `c2` variables to specify the "stop" row and columns,
  which may be relevant if a range of cells are selected.
  Or all will be NA if no cell is selected.}

  \item{headers}{Sets the way column headers should be
  displayed on the table.  \code{enabled} implies that the
  default column names (progression through the alphabet)
  should be used. \code{disabled} implies that column
  headings should be disabled completely. \code{provided}
  implies that the column names should be extracted from
  the R object being displayed.}
}
\description{
  Render a Handsontable in an application page.
}
\author{
  Jeff Allen \email{jeff@trestletech.com}
}

