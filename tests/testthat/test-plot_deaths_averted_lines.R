test_that("plot_deaths_averted_lines returns a ggplot object", {
  df <- data.frame(
    date = rep(seq.Date(as.Date("2020-01-01"), by = "month", length.out = 6), 2),
    `no PSS drug_deaths` = rep(seq(from=5, to = 10, length.out = 6), 2),
    `PSS drug_deaths` = rep(seq(from=2, to = 3, length.out = 6), 2),
    model = rep(c("Model A", "Model B"), each = 6),
    run = rep(1:2, each = 6),
    check.names = FALSE
  )

  p <- plot_deaths_averted_lines(df)
  expect_s3_class(p, "ggplot")
})

test_that("plot_deaths_averted_lines computes cumulative deaths correctly", {
  no_pss_deaths <- c(10, 15, 20)
  pss_deaths <- c(5, 7, 8)
  df <- data.frame(
    date = rep(seq_len(3), 1),
    `no PSS drug_deaths` = no_pss_deaths,
    `PSS drug_deaths` = pss_deaths,
    model = rep("Model A", 3),
    run = rep(1, 3),
    check.names = FALSE
  )

  p <- plot_deaths_averted_lines(df)
  # Extract built data from ggplot
  built <- ggplot2::ggplot_build(p)
  y_vals <- built$data[[1]]$y

  expected <- cumsum(no_pss_deaths - pss_deaths)
  expect_equal(y_vals, expected)
})



test_that("plot_deaths_averted_lines has correct aesthetics", {
  df <- data.frame(
    date = rep(seq_len(3), 1),
    `no PSS drug_deaths` = c(10, 15, 20),
    `PSS drug_deaths` = c(5, 7, 8),
    model = rep("Model A", 3),
    run = rep(1, 3),
    check.names = FALSE
  )

  p <- plot_deaths_averted_lines(df)
  built <- ggplot2::ggplot_build(p)

  # Check that aesthetics include x=date, y=deaths_averted, colour=model
  mapping <- p$layers[[1]]$mapping
  expect_equal(rlang::as_name(mapping$x), "date")
  expect_equal(rlang::as_name(mapping$y), "deaths_averted")
  expect_equal(rlang::as_name(mapping$colour), "model")
})
