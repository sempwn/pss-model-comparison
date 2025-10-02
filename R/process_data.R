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

#' Scale a column between -1 and 1 and rename it
#'
#' This function rescales the values of a specified numeric column in a data frame
#' to the range \[-1, 1\] and saves the result in a new column with the given name.
#'
#' @param dataframe A data frame containing the column to be rescaled.
#' @param col A string giving the name of the column to rescale.
#' @param new_col A string giving the name of the new column to store the rescaled values.
#'
#' @return A data frame with the new rescaled column added.
#' @examples
#' df <- data.frame(x = 1:10)
#' scale_and_rename_columns(df, "x", "x_scaled")
#'
#' @noRd
scale_and_rename_columns <- function(dataframe, col, new_col) {
  if (!col %in% names(dataframe)) {
    stop("Column '", col, "' not found in dataframe.")
  }
  if (!is.numeric(dataframe[[col]])) {
    stop("Column '", col, "' must be numeric.")
  }

  x <- dataframe[[col]]
  rng <- range(x, na.rm = TRUE)
  if (rng[1] == rng[2]) {
    warning("Column '", col, "' has constant values. Returning zeros.")
    dataframe[[new_col]] <- 0
  } else {
    dataframe[[new_col]] <- 2 * (x - rng[1]) / (rng[2] - rng[1]) - 1
  }

  return(dataframe)
}
