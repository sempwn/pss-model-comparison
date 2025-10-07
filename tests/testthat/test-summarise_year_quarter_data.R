library(testthat)
library(dplyr)
library(tibble)
library(withr)

test_that("summarise_year_quarter_data returns correct structure", {
  # Mock median_with_uncertainty
  local_mock(
    median_with_uncertainty = function(x) median(x, na.rm = TRUE)
  )

  input <- tibble(
    year_quarter = rep(c("2024-Q1", "2024-Q2"), each = 3),
    model = rep(c("OTEM", "BCROM", "OTEM"), times = 2),
    `PSS overdoses` = rnorm(6, 100, 10),
    `no PSS overdoses` = rnorm(6, 150, 15),
    `PSS drug_deaths` = rnorm(6, 10, 2),
    `no PSS drug_deaths` = rnorm(6, 20, 3),
    `cumulative deaths averted` = rnorm(6, 5, 1),
    `cumulative overdoses averted` = rnorm(6, 30, 5)
  )

  output <- summarise_year_quarter_data(input)

  expect_s3_class(output, "tbl_df")
  expect_named(
    output,
    c("year_quarter", "model", "PSS overdoses", "no PSS overdoses",
      "no PSS drug_deaths", "PSS drug_deaths",
      "cumulative deaths averted", "cumulative overdoses averted")
  )
})

test_that("summarise_year_quarter_data summarizes correctly", {
  local_mock(
    median_with_uncertainty = function(x) round(median(x), 1)
  )

  input <- tibble(
    year_quarter = rep("2025-Q1", 4),
    model = rep("OTEM", 4),
    `PSS overdoses` = c(10, 20, 30, 40),
    `no PSS overdoses` = c(50, 60, 70, 80),
    `PSS drug_deaths` = c(1, 2, 3, 4),
    `no PSS drug_deaths` = c(5, 6, 7, 8),
    `cumulative deaths averted` = c(0.1, 0.2, 0.3, 0.4),
    `cumulative overdoses averted` = c(2, 4, 6, 8)
  )

  result <- summarise_year_quarter_data(input)

  expect_equal(result$`PSS overdoses`, 25)
  expect_equal(result$`no PSS overdoses`, 65)
  expect_equal(result$`PSS drug_deaths`, 2.5)
  expect_equal(result$`no PSS drug_deaths`, 6.5)
})

test_that("summarise_year_quarter_data handles NA values", {
  local_mock(
    median_with_uncertainty = function(x) median(x, na.rm = TRUE)
  )

  input <- tibble(
    year_quarter = c("2025-Q1", "2025-Q1"),
    model = c("OTEM", "OTEM"),
    `PSS overdoses` = c(NA, 100),
    `no PSS overdoses` = c(200, NA),
    `PSS drug_deaths` = c(NA, 5),
    `no PSS drug_deaths` = c(NA, 10),
    `cumulative deaths averted` = c(NA, 1),
    `cumulative overdoses averted` = c(2, NA)
  )

  result <- summarise_year_quarter_data(input)
  expect_true(all(!is.na(result)))
})

test_that("summarise_year_quarter_data errors with missing required columns", {
  input <- tibble(
    quarter = c("2024-Q1", "2024-Q2"),
    model = c("OTEM", "BCROM"),
    value = c(10, 20)
  )

  expect_error(
    summarise_year_quarter_data(input),
    regexp = "Column `year_quarter` is not found",
    fixed = TRUE
  )
})
