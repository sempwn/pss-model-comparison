#' Load and Combine BCROM and OTEM Model Output Data
#'
#' @description
#' This function reads in CSV files containing output from the BCROM and OTEM models,
#' processes and combines the data into a single tibble. It adds a `model` column
#' to distinguish the data sources and constructs a `date` column from the `year` and
#' `month` columns.
#' @param round character, either "one" or "two"
#' @return A tibble containing the combined data from the BCROM and OTEM models, with
#' an added `model` column and a parsed `date` column.
#'
#' @details
#' The function expects the files `BCROM_comparison_outputs.csv` and
#' `OTEM_comparison_outputs.csv` to be located in `data/raw/` relative to the project root,
#' as determined by the `here` package.
#'
#' The following transformations are applied:
#' \itemize{
#'   \item The `...1` column is removed from the BCROM dataset if present.
#'   \item A `model` column is added with values `"bcrom"` or `"otem"`.
#'   \item A `date` column is constructed by combining `year` and `month` with a dummy day `"01"`.
#' }
#'
#' @importFrom here here
#'
#' @examples
#' \dontrun{
#' data <- load_data()
#' head(data)
#' }
#'
#' @export
load_data <- function(round="one"){
  bcrom_data_file <- here("data","raw",paste0("round_",round),
                                "BCROM_comparison_outputs.csv")
  otem_data_file <- here("data","raw",paste0("round_",round),
                               "OTEM_comparison_outputs.csv")
  bcrom_data <- readr::read_csv(bcrom_data_file)
  otem_data <- readr::read_csv(otem_data_file)

  bcrom_data <- bcrom_data |>
    dplyr::mutate(model = "bcrom") |>
    dplyr::select(!`...1`)
  otem_data <- otem_data |>
    dplyr::mutate(model = "otem")
  all_data <- bcrom_data |>
    dplyr::bind_rows(otem_data)
  all_data <- all_data |>
    dplyr::mutate(date = lubridate::ymd(glue::glue("{year}-{month}-01")),
                  year_quarter = lubridate::quarter(date, type = "year_start/end"))
  return(all_data)
}
