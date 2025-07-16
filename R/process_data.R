#' Summarize Model Data by Year-Quarter
#'
#' Filters, groups, and summarizes model output data by year-quarter, model, and run.
#'
#' This function takes a data frame of model output, filters out dates before March 1, 2020,
#' groups the data by `year_quarter`, `model`, and `run`, then sums all numeric (non-Date) columns
#' within those groups. The `year_quarter` variable is converted to a factor.
#'
#' @param model_data A data frame containing model output. Must include columns:
#'   - `date`: a Date object,
#'   - `year_quarter`: a grouping variable (e.g., "2021 Q2"),
#'   - `model`: model identifier,
#'   - `run`: simulation run identifier,
#'   along with numeric variables to be summarized.
#'
#' @return A grouped and summarized tibble with one row per combination of `year_quarter`, `model`, and `run`.
#'   All non-Date columns are summed. `year_quarter` is returned as a factor.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' calculate_year_quarter_data(model_data)
#' }
calculate_year_quarter_data <- function(model_data){
  date <- year_quarter <- model <- run <- NULL
  model_data |>
    dplyr::filter(date > lubridate::ymd("2020-03-01")) |>
    dplyr::group_by(year_quarter, model, run) |>
    dplyr::summarise(dplyr::across(
      tidyselect::where(~ !lubridate::is.Date(.x)),sum)) |>
    dplyr::mutate(year_quarter = forcats::as_factor(year_quarter))
}

#' calculate deaths and overdoses averted
#' @inheritParams calculate_year_quarter_data
#' @return tibble
#' @export
add_averted_columns <- function(model_data){
  model <- run <- `deaths averted` <- `overdoses averted` <- NULL
  `no PSS drug_deaths` <- `PSS drug_deaths` <- `no PSS overdoses` <- `PSS overdoses` <- NULL
  model_data |>
    dplyr::group_by(model,run) |>
    dplyr::mutate(
      `cumulative deaths averted` = cumsum(`no PSS drug_deaths` - `PSS drug_deaths`),
      `cumulative overdoses averted` = cumsum(`no PSS overdoses` - `PSS overdoses`)
      )
}
