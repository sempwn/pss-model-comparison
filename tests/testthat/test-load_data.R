library(testthat)
library(readr)
library(dplyr)
library(lubridate)
library(here)
library(withr)
library(glue)

test_that("load_data reads, combines, and processes BCROM and OTEM files", {
  with_tempdir({
    # Simulate expected folder structure
    dir.create("data/raw/round_one", recursive = TRUE)

    # Create mock BCROM CSV file
    bcrom_mock <- tibble::tibble(
      `...1` = 1:2,
      year = c(2020, 2021),
      month = c(1, 4),
      value_bcrom = c(10, 20)
    )
    write_csv(bcrom_mock, "data/raw/round_one/BCROM_comparison_outputs.csv")

    # Create mock OTEM CSV file
    otem_mock <- tibble::tibble(
      year = c(2020, 2021),
      month = c(1, 4),
      value_otem = c(30, 40)
    )
    write_csv(otem_mock, "data/raw/round_one/OTEM_comparison_outputs.csv")

    # Override here::here() to use tempdir path
    mock_here <- function(...) file.path(getwd(), ...)
    with_mocked_bindings(
      `here::here` = mock_here,
      {
        result <- load_data(round = "one")

        # Check combined data has expected rows and columns
        expect_s3_class(result, "tbl_df")
        expect_equal(nrow(result), 4)
        expect_true("model" %in% names(result))
        expect_true("date" %in% names(result))
        expect_true("year_quarter" %in% names(result))

        # Check model assignment
        expect_equal(sum(result$model == "bcrom"), 2)
        expect_equal(sum(result$model == "otem"), 2)

        # Check that "...1" was removed
        expect_false("...1" %in% names(result))

        # Check correct date construction
        expected_dates <- ymd(c("2020-01-01", "2021-04-01", "2020-01-01", "2021-04-01"))
        expect_equal(sort(result$date), sort(expected_dates))
      }
    )
  })
})

test_that("load_data errors when files are missing", {
  with_tempdir({
    dir.create("data/raw/round_one", recursive = TRUE)

    # Only create one of the two files
    write_csv(tibble(year = 2020, month = 1, value = 1),
              "data/raw/round_one/BCROM_comparison_outputs.csv")

    mock_here <- function(...) file.path(getwd(), ...)
    with_mock(
      `here::here` = mock_here,
      {
        expect_error(load_data(round = "one"))
      }
    )
  })
})
