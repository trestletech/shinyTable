\name{htable}
\alias{htable}
\title{Render a Handsontable}
\usage{
  htable(outputId,
    headers = c("enabled", "disabled", "provided"))
}
\arguments{
  \item{outputId}{The ID of the \code{glOutput} associated
  with this element}

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

