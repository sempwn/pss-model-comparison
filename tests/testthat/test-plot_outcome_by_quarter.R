library(testthat)
library(ggplot2)
library(dplyr)

test_that("plot_outcome_by_quarter returns a ggplot object", {
  df <- tibble::tibble(
    year_quarter = factor(rep(c("2020 Q1", "2020 Q2"), each = 5)),
    model = rep(c("Model A", "Model B"), times = 5),
    `PSS drug_deaths` = rpois(10, lambda = 10)
  )

  p <- plot_outcome_by_quarter(df)
  expect_s3_class(p, "ggplot")
})

test_that("plot_outcome_by_quarter uses the correct outcome variable", {
  df <- tibble::tibble(
    year_quarter = rep(c("2021 Q1", "2021 Q2"), each = 6),
    model = rep(c("X", "Y"), times = 6),
    custom_outcome = rnorm(12, 5, 2)
  )

  p <- plot_outcome_by_quarter(df, outcome = "custom_outcome")

  # Check that the outcome is used in the y aesthetic
  expect_true("custom_outcome" %in% rlang::as_label(p$mapping$y))
})

test_that("plot_outcome_by_quarter handles year_quarter as character", {
  df <- tibble::tibble(
    year_quarter = rep(c("2022 Q3", "2022 Q4"), each = 4),
    model = rep(c("M1", "M2"), times = 4),
    `PSS drug_deaths` = rpois(8, 15)
  )
  df$year_quarter <- as.character(df$year_quarter)

  p <- plot_outcome_by_quarter(df)

  expect_s3_class(p, "ggplot")
  expect_true("year_quarter" %in% names(p$data))
})

test_that("plot_outcome_by_quarter handles empty data", {
  df <- tibble::tibble(
    year_quarter = character(),
    model = character(),
    `PSS drug_deaths` = numeric()
  )

  expect_error(plot_outcome_by_quarter(df), regexp = NA)
})


