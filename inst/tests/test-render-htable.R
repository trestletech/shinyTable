context("test_render-htable")
test_that("basic table renders", {
  df <- data.frame(list(
    a=1:3,
    b=seq(from=0, to=1, length.out=3),
    c=LETTERS[1:3]
  ))
#  tbl <- renderHtable({df})()
  
#  expect_equal(length(tbl), 3)
#  expect_true(all(names(tbl) %in% c("data", "colnames", "types")))
  
  # Check data
#  data <- tbl$data
#  expect_equal(typeof(data), "character")
#  expect_equal(data, 
#               matrix(c("1", "0.0", "A", "2", "0.5", "B", "3", "1.0", "C"), 
#                      ncol=3, byrow=TRUE))
  
  # Check colnames
#  expect_equal(tbl$colnames, c("a", "b", "c"))
  
  # Check types
#  expect_equal(tbl$types, getHtableTypes(df))
})