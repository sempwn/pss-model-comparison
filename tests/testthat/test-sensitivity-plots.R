# test-plot_sensitivity_analysis_heatmap.R

test_that("plot_sensitivity_analysis_heatmap() returns a ggplot object", {
  # Mock sensitivity analysis data
  data <- data.frame(
    model = rep("otem", 9),
    x_scale = rep(1:3, each = 3),
    y_scale = rep(1:3, 3),
    total_deaths = seq(-10, -2)
  )

  result <- list(
    oat_ret = list(
      data = data,
      x_label = "Parameter A",
      y_label = "Parameter B",
      x_tick_labels = c("Low", "Med", "High"),
      y_tick_labels = c("Low", "Med", "High")
    )
  )

  p <- plot_sensitivity_analysis_heatmap(result)
  expect_s3_class(p, "ggplot")
})



test_that("plot_model_difference_heatmap() returns a ggplot object", {
  # Mock sensitivity analysis data
  data <- expand.grid(
    x_scale = -1:1, y_scale = -1:1,
    model = c("otem", "bcrom"), total_deaths = 1
    )

  result <- list(
    oat_ret = list(
      data = data,
      x_label = "Parameter A",
      y_label = "Parameter B",
      x_tick_labels = c("Low", "Med", "High"),
      y_tick_labels = c("Low", "Med", "High")
    )
  )

  p <- plot_model_difference_heatmap(result)
  expect_true(ggplot2::is_ggplot(p))
})

test_that("plot_sensitivity_analysis_heatmap() correctly reverses sign of total_deaths", {
  df <- data.frame(
    model = c("otem", "otem"),
    x_scale = c(1, 2),
    y_scale = c(1, 2),
    total_deaths = c(10, -5)
  )
  result <- list(
    oat_ret = list(
      data = df,
      x_label = "A",
      y_label = "B"
    )
  )

  p <- plot_sensitivity_analysis_heatmap(result)
  data_used <- ggplot2::layer_data(p, i = 2L)

  # Should reverse signs, so positive deaths become negative (and vice versa)
  expect_true(all(data_used$label[1] == -10 & data_used$label[2] == 5))
})

test_that("plot_sensitivity_analysis_heatmap() respects breaks argument", {
  df <- data.frame(
    model = "otem",
    x_scale = rep(1:3, each = 3),
    y_scale = rep(1:3, 3),
    total_deaths = runif(9, -10, 10)
  )
  result <- list(
    oat_ret = list(
      data = df,
      x_label = "Param A",
      y_label = "Param B"
    )
  )

  # Explicit breaks
  p <- plot_sensitivity_analysis_heatmap(result, breaks = c(-5, 5))
  scale_info <- ggplot2::ggplot_build(p)$plot$scales$get_scales("fill")
  expect_equal(scale_info$get_limits(), c(-5, 5))
})

test_that("plot_sensitivity_analysis_heatmap() infers breaks from data when NULL", {
  df <- data.frame(
    model = "otem",
    x_scale = rep(1:3, each = 3),
    y_scale = rep(1:3, 3),
    total_deaths = c(-1, 0, 1, -2, 2, -3, 3, -4, 4)
  )
  result <- list(
    oat_ret = list(
      data = df,
      x_label = "Param A",
      y_label = "Param B"
    )
  )

  p <- plot_sensitivity_analysis_heatmap(result, breaks = NULL)
  scale_info <- ggplot2::ggplot_build(p)$plot$scales$get_scales("fill")
  expect_equal(scale_info$get_limits(), c(-max(df$total_deaths), -min(df$total_deaths)))
})

test_that("plot_sensitivity_analysis_heatmap() filters only selected model", {
  df <- data.frame(
    model = rep(c("otem", "bcrom"), each = 4),
    x_scale = rep(1:2, 4),
    y_scale = rep(1:2, each = 4),
    total_deaths = seq(-4, 3)
  )

  result <- list(
    oat_ret = list(
      data = df,
      x_label = "X",
      y_label = "Y"
    )
  )

  p <- plot_sensitivity_analysis_heatmap(result, model_name = "bcrom")
  plot_data <- ggplot2::layer_data(p)
  expect_true(all(plot_data$x %in% df$x_scale[df$model == "bcrom"]))
})

test_that("supporting functions behave correctly", {
  df <- expand.grid(x_scale = 1:3, y_scale = 1:3,
                    model = c("otem", "bcrom"), total_deaths = 1)
  baseline <- c(1, 1)

  transformed <- transform_normalized_differences_data(df, baseline)
  expect_true("diff" %in% names(transformed))

  categorized <- categorize_difference(transformed, breaks = c(0, 1, 2, 3))
  expect_true(all(c("category", "x_index", "y_index") %in% names(categorized)))

  pal <- define_palette()
  expect_length(pal, 6)
  expect_true(all(grepl("OTEM|BCROM", names(pal))))
})

test_that("get_max_min_breaks() and get_low_medium_high_breaks() return correct quantiles", {
  df <- expand.grid(
    model = c("otem", "bcrom"),
    x_scale = 1:2,
    y_scale = 1:2
  )
  df[["total_deaths"]] <- c(1,1,3:8)

  result <- list(
    oat_ret = list(
      data = df,
      baseline = c(1, 1)
    )
  )

  # get_max_min_breaks
  minmax <- get_max_min_breaks(result)
  expect_length(minmax, 2)
  expect_equal(minmax[[1]], min(-df$total_deaths))
  expect_equal(minmax[[2]], max(-df$total_deaths))

  # get_low_medium_high_breaks
  breaks <- get_low_medium_high_breaks(result)
  expect_length(breaks, 4)
  expect_true(all(diff(breaks) >= 0))
})
