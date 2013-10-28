context("test_get_htable_types")
test_that("character works", {
  df <- data.frame(list(a=c("string", "here")), stringsAsFactors=FALSE)
  types <- getHtableTypes(df)
  expect_equal(types, "text")
})

test_that("character factor works", {
  df <- data.frame(list(a=c("string", "here")), stringsAsFactors=TRUE)
  types <- getHtableTypes(df)
  expect_equal(types, "text")
})

test_that("integer works", {
  df <- data.frame(list(a=1:2))
  types <- getHtableTypes(df)
  expect_equal(types, "text")
})

test_that("double works", {
  df <- data.frame(list(a=rnorm(2)))
  types <- getHtableTypes(df)
  expect_equal(types, "text")
})

test_that("logical works", {
  df <- data.frame(list(a=c(TRUE, FALSE)))
  types <- getHtableTypes(df)
  expect_equal(types, "checkbox")
})

test_that ("date works", {
  df <- data.frame(list(a=as.Date(c("2007-06-22", "2004-02-13"))))
  types <- getHtableTypes(df)
  expect_equal(types, "date")
  
})

test_that ("mixed works", {
  df <- data.frame(list(
      a=as.Date(c("2007-06-22", "2004-02-13")),
      b=1:2,
      c=rnorm(2),
      d=c("String", "here"),
      e=c(TRUE, FALSE)
    ))
  types <- getHtableTypes(df)
  expect_equal(types, c("date", "text", "text", "text", "checkbox"))
})

test_that("others treated as character", {
  df <- data.frame(list(a=1:2))
  class(df$a) <- "custom"
  types <- getHtableTypes(df)
  expect_equal(types, "text")
})

test_that("numeric matrix works", {
  mat <- matrix(rnorm(25), ncol=5)
  types <- getHtableTypes(mat)
  expect_equal(types, "text")
})
