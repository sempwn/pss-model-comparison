library(testthat)
library(readr)
library(dplyr)
library(lubridate)
library(here)
library(withr)
library(glue)

test_that("load_data reads, combines, and processes BCROM and OTEM files", {

  result <- load_data(round = "one")


  # Check combined data has expected rows and columns
  expect_s3_class(result, "tbl_df")
  expect_true("model" %in% names(result))
  expect_true("date" %in% names(result))
  expect_true("year_quarter" %in% names(result))

  # Check models exist
  expect_equal(unique(result$model), c("bcrom", "otem"))

  # Check that "...1" was removed
  expect_false("...1" %in% names(result))
})


