\name{applyChange}
\alias{applyChange}
\title{Apply a single change to the table.}
\usage{
  applyChange(table, change, trim = TRUE)
}
\arguments{
  \item{table}{The htable data.frame}

  \item{changes}{An array of length 4 of changes to apply,
  in the form of [row, col, oldValue, newValue] using
  0-based-indexing}

  \item{trim}{if \code{TRUE}, will trim any leading or
  trailing whitespace from the relevant values.}
}
\value{
  The data.frame provided with the change applied.
}
\description{
  Apply a single change to the table.
}
\author{
  Jeff Allen \email{jeff@trestletech.com}
}

