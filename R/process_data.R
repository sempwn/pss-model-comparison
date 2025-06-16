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
#' @importFrom dplyr filter group_by summarise across
#' @importFrom tidyselect where
#' @importFrom lubridate ymd is.Date
#' @importFrom forcats as_factor
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
    dplyr::group_by(year_quarter,model,run) |>
    dplyr::summarise(dplyr::across(
      tidyselect::where(~ !lubridate::is.Date(.x)),sum)) |>
    dplyr::mutate(year_quarter = forcats::as_factor(year_quarter))
}
