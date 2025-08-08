library(dplyr)

test_that("add_averted_columns computes cumulative averted columns", {
  input <- tibble::tibble(
    model = c("A", "A", "A", "B", "B"),
    run = c(1, 1, 1, 2, 2),
    `no PSS drug_deaths` = c(10, 20, 30, 5, 10),
    `PSS drug_deaths` = c(8, 15, 20, 2, 4),
    `no PSS overdoses` = c(100, 200, 300, 50, 100),
    `PSS overdoses` = c(90, 180, 290, 45, 95)
  )

  result <- add_averted_columns(input)

  # Check cumulative differences
  expect_equal(
    result |> filter(model == "A", run == 1) |> pull(`cumulative deaths averted`),
    c(2, 7, 17)
  )

  expect_equal(
    result |> filter(model == "B", run == 2) |> pull(`cumulative overdoses averted`),
    c(5, 10)
  )
})

test_that("add_averted_columns preserves original structure", {
  input <- tibble::tibble(
    model = c("X", "X"),
    run = c(1, 1),
    `no PSS drug_deaths` = c(10, 20),
    `PSS drug_deaths` = c(5, 10),
    `no PSS overdoses` = c(50, 100),
    `PSS overdoses` = c(25, 60)
  )

  result <- add_averted_columns(input)

  expect_true(all(c("cumulative deaths averted", "cumulative overdoses averted") %in% names(result)))
  expect_equal(nrow(result), 2)
})
