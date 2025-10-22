test_that("get_sensitivity_data_labels returns correct structure", {
  labels <- get_sensitivity_data_labels()
  expect_type(labels, "list")
  expect_named(labels, c("pop_mort", "oat_ret"))

  expect_named(labels$pop_mort, c("x_label", "y_label", "x_tick_labels", "y_tick_labels", "baseline"))
  expect_type(labels$pop_mort$x_label, "character")
  expect_type(labels$pop_mort$y_label, "character")
})

test_that("combine_sensitivity_data merges correctly", {
  otem <- tibble::tibble(
    x_scale = c(0.1, 0.2),
    y_scale = c(0.3, 0.4),
    total_deaths = c(100, 200)
  )
  bcrom <- tibble::tibble(
    x_scale = c(0.5, 0.6),
    y_scale = c(0.7, 0.8),
    total_deaths = c(300, 400)
  )

  combined <- combine_sensitivity_data(otem, bcrom)

  expect_s3_class(combined, "tbl_df")
  expect_named(combined, c("x_scale", "y_scale", "total_deaths", "model"))
  expect_setequal(unique(combined$model), c("otem", "bcrom"))
})



test_that("load_sensitivity_analysis_data returns expected structure", {
  result <- load_sensitivity_analysis_data()

  expect_type(result, "list")
  expect_named(result, c("pop_mort", "oat_ret"))
  for (s in names(result)) {
    scenario <- result[[s]]
    expect_named(scenario, c("data", "x_label", "y_label", "x_tick_labels", "y_tick_labels", "baseline"))
    expect_s3_class(scenario$data, "tbl_df")
    expect_true(all(c("x_scale", "y_scale", "total_deaths", "model") %in% names(scenario$data)))
    expect_type(scenario$x_label, "character")
    expect_type(scenario$y_label, "character")
  }
})

test_that("load_bcrom_sensitivity_analysis_data scales and renames columns", {
  result <- load_bcrom_sensitivity_analysis_data()

  expect_named(result, c("pop_mort", "oat_ret"))
  expect_true(all(c("x_scale", "y_scale") %in% names(result$pop_mort)))
  expect_true(all(c("x_scale", "y_scale") %in% names(result$oat_ret)))
})
