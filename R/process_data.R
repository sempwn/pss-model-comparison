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
calculate_year_quarter_data <- function(model_data) {
  date <- year_quarter <- model <- run <- NULL
  model_data |>
    dplyr::filter(date > lubridate::ymd("2020-03-01")) |>
    dplyr::group_by(year_quarter, model, run) |>
    dplyr::summarise(dplyr::across(
      tidyselect::where(~ !lubridate::is.Date(.x)), sum
    )) |>
    dplyr::mutate(year_quarter = forcats::as_factor(year_quarter))
}

#' Summarize model outputs by year and quarter
#'
#' Aggregates quarterly model results (such as overdoses and deaths) across
#' simulations or parameter draws using the median and associated uncertainty
#' interval. This summary provides a concise quarterly view of modeled outcomes
#' from the output of [calculate_year_quarter_data()].
#'
#' The function groups results by `year_quarter` and `model`, applies
#' median with uncertainty to each column, and returns a subset
#' of key outcome variables for reporting or visualization.
#'
#' @param year_quarter_data A data frame or tibble returned by
#'   [calculate_year_quarter_data()], containing simulated quarterly outcomes
#'   with columns such as `year_quarter`, `model`, `PSS overdoses`,
#'   `no PSS overdoses`, `PSS drug_deaths`, `no PSS drug_deaths`,
#'   and cumulative measures of deaths and overdoses averted.
#'
#' @return A tibble summarizing median (and uncertainty) estimates for each
#'   model and year-quarter combination. Includes the following columns:
#'   \describe{
#'     \item{year_quarter}{Year-quarter identifier (e.g., `"2024-Q2"`).}
#'     \item{model}{Model name or identifier (e.g., `"BCROM"`, `"OTEM"`).}
#'     \item{PSS overdoses}{Median and uncertainty interval for overdoses
#'     under the PSS scenario.}
#'     \item{no PSS overdoses}{Median and uncertainty interval for overdoses
#'     under the counterfactual (no PSS) scenario.}
#'     \item{PSS drug_deaths}{Median and uncertainty interval for overdose
#'     deaths under the PSS scenario.}
#'     \item{no PSS drug_deaths}{Median and uncertainty interval for overdose
#'     deaths under the counterfactual (no PSS) scenario.}
#'     \item{cumulative deaths averted}{Cumulative estimate of overdose deaths
#'     averted by PSS implementation.}
#'     \item{cumulative overdoses averted}{Cumulative estimate of overdoses
#'     averted by PSS implementation.}
#'   }
#'
#'
#' @seealso [calculate_year_quarter_data()]
#'
#' @importFrom dplyr group_by summarise across where select
#'
#' @return A tibble with summarized quarterly model results.
#' @export
summarise_year_quarter_data <- function(year_quarter_data, digits = 3) {
  year_quarter <- model <- NULL
  `cumulative deaths averted` <- `cumulative overdoses averted` <- NULL
  `no PSS drug_deaths` <- `PSS drug_deaths` <- NULL
  `no PSS overdoses` <- `PSS overdoses` <- NULL
  year_quarter_data |>
    dplyr::group_by(year_quarter, model) |>
    dplyr::summarise(
      dplyr::across(
        dplyr::where(is.numeric), ~median_with_uncertainty(.,digits = digits)
      )
    ) |>
    dplyr::select(
      year_quarter, model, `PSS overdoses`, `no PSS overdoses`,
      `no PSS drug_deaths`, `PSS drug_deaths`,
      `cumulative deaths averted`, `cumulative overdoses averted`
    )
}

#' @noRd
#' @param digits number of significant figures
#' @importFrom stats median
#' @importFrom stats quantile
median_with_uncertainty <- function(x, digits = 3) {
  m <- median(x)
  lc <- quantile(x, 0.05)
  uc <- quantile(x, 0.95)
  prettify_uncertainty(m, lc, uc, digits = digits)
}

#' calculate deaths and overdoses averted
#' @inheritParams calculate_year_quarter_data
#' @return tibble
#' @export
add_averted_columns <- function(model_data) {
  model <- run <- `deaths averted` <- `overdoses averted` <- NULL
  `no PSS drug_deaths` <- `PSS drug_deaths` <- `no PSS overdoses` <- `PSS overdoses` <- NULL
  model_data |>
    dplyr::group_by(model, run) |>
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
#' @param reverse A boolean whether variable needs to be reversed, default is F
#' @param digits number of digits for re-scaled data to round to, default is 3
#'
#' @return A data frame with the new rescaled column added.
#' @examples
#' df <- data.frame(x = 1:10)
#' scale_and_rename_columns(df, "x", "x_scaled")
#'
#' @noRd
scale_and_rename_columns <- function(dataframe, col, new_col, reverse = F,
                                     digits = 4) {
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
    dataframe[[new_col]] <- round(2 * (x - rng[1]) / (rng[2] - rng[1]) - 1, digits = digits)
  }

  if(reverse){
    dataframe[[new_col]] <- -1 * dataframe[[new_col]]
  }

  return(dataframe)
}
