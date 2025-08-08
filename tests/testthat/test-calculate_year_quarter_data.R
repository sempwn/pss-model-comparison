library(testthat)
library(dplyr)
library(lubridate)
library(forcats)

test_that("calculate_year_quarter_data filters and groups correctly", {
  # Create dummy input data
  input <- tibble::tibble(
    date = as.Date(c("2020-02-01", "2020-04-01", "2020-04-15", "2021-01-10")),
    year_quarter = c("2020 Q1", "2020 Q2", "2020 Q2", "2021 Q1"),
    model = c("A", "A", "A", "B"),
    run = c(1, 1, 1, 2),
    value1 = c(10, 20, 30, 40),
    value2 = c(1, 2, 3, 4)
  )

  result <- calculate_year_quarter_data(input)

  # Check that pre-March 2020 row is filtered out
  expect_false(any(result$year_quarter == "2020 Q1"))

  # Check grouping and summing
  expect_equal(nrow(result), 2)
  expect_equal(
    result |> filter(year_quarter == "2020 Q2", model == "A", run == 1) |> pull(value1),
    50  # 20 + 30
  )
  expect_equal(
    result |> filter(year_quarter == "2020 Q2", model == "A", run == 1) |> pull(value2),
    5  # 2 + 3
  )

  # Check that year_quarter is a factor
  expect_s3_class(result$year_quarter, "factor")
})

test_that("calculate_year_quarter_data handles no rows after filter", {
  input <- tibble::tibble(
    date = as.Date(c("2020-01-01", "2020-02-01")),
    year_quarter = c("2020 Q1", "2020 Q1"),
    model = c("A", "A"),
    run = c(1, 1),
    value1 = c(5, 5)
  )

  result <- calculate_year_quarter_data(input)
  expect_equal(nrow(result), 0)
  expect_s3_class(result, "tbl")
})

