library(testthat)
library(dplyr)

test_that("prettify_uncertainty outputs correctly formatted string", {
  result <- prettify_uncertainty(m = 123.456, lc = 100.1, uc = 150.9, digits = 2)
  expect_type(result, "character")
  expect_match(result, "120.* \\(95% UI: 100.* - 150.*\\)")

  result2 <- prettify_uncertainty(1.23456, 1.1111, 1.9999, digits = 3)
  expect_equal(result2, "1.23 (95% UI: 1.11 - 2)")
})

test_that("summarise_deaths_averted returns formatted output with median and quantiles", {
  input <- tibble(
    model = c("A", "A", "A", "B", "B"),
    run = c(1, 2, 3, 1, 2),
    `no PSS drug_deaths` = c(100, 110, 120, 80, 90),
    `PSS drug_deaths` = c(90, 100, 105, 70, 75)
  )

  result <- summarise_deaths_averted(input)

  # Check structure
  expect_s3_class(result, "tbl_df")
  expect_named(result, c("model", "m", "lc", "uc", "deaths_averted"))
  expect_equal(nrow(result), 2)

  # Check correct model names
  expect_true(all(c("A", "B") %in% result$model))

  # Check that prettify_uncertainty worked
  expect_true(all(grepl("95% UI", result$deaths_averted)))
})

test_that("summarise_deaths_averted works with different digits", {
  input <- tibble(
    model = rep("Z", 3),
    run = 1:3,
    `no PSS drug_deaths` = c(200.0235, 210, 220),
    `PSS drug_deaths` = c(180, 190, 200)
  )
  result <- summarise_deaths_averted(input, digits = 3)
  expect_match(result$deaths_averted, "^[0-9]{2}.*\\(95% UI:")
})

