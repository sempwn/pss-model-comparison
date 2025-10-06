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
  `...1` <- NULL
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

#' Load and combine sensitivity analysis data from OTEM and BCROM models
#'
#' This function loads sensitivity analysis data from two modeling frameworks
#' (OTEM and BCROM), standardizes variable names, and merges them into a
#' unified structure with corresponding axis labels for plotting or further analysis.
#'
#' The function ensures that both OTEM and BCROM provide matching sensitivity
#' data tables for each scenario. It attaches appropriate x and y axis labels
#' to each dataset for downstream use in figures or reports.
#'
#' @return A named list of sensitivity analysis results, where each element is
#'   itself a list containing:
#'   \describe{
#'     \item{data}{A combined tibble with OTEM and BCROM results, including columns
#'     `x_scale`, `y_scale`, `total_deaths`, and `model`.}
#'     \item{x_label}{A character string describing the x-axis label for the scenario.}
#'     \item{y_label}{A character string describing the y-axis label for the scenario.}
#'   }
#'   The list is keyed by scenario identifiers (e.g., `"pop_mort"`, `"oat_ret"`).
#'
#' @seealso [combine_sensitivity_data()], [load_otem_sensitivity_analysis_data()],
#'   [load_bcrom_sensitivity_analysis_data()], [get_sensitivity_data_labels()]
#'
#' @export
load_sensitivity_analysis_data <- function(){
  labels <- get_sensitivity_data_labels()
  otem_data <- load_otem_sensitivity_analysis_data()
  bcrom_data <- load_bcrom_sensitivity_analysis_data()
  combined_data <- list()
  for(d in names(otem_data)){
    otem_data[[d]] <- dplyr::rename(
      otem_data[[d]],
      "total_deaths" = "n_inc_odf_scaled"
    )
    if(!(d %in% names(bcrom_data))){
      stop("bcrom and otem sensitivity data tables must match")
    }
    combined_data[[d]] <- list(
      data = combine_sensitivity_data(otem_data[[d]],bcrom_data[[d]]),
      x_label = labels[[d]][['x']],
      y_label = labels[[d]][['y']],
      x_tick_labels = labels[[d]][['x_tick_labels']],
      y_tick_labels = labels[[d]][['y_tick_labels']]
    )
  }

  return(combined_data)
}

#' Combine sensitivity analysis data from OTEM and BCROM
#'
#' Internal helper function that merges sensitivity analysis results
#' from OTEM and BCROM models into a single tibble. Adds a `model`
#' column to identify the source.
#'
#' @param otem_data A tibble of OTEM sensitivity analysis results with
#'   columns `x_scale`, `y_scale`, and `total_deaths`.
#' @param bcrom_data A tibble of BCROM sensitivity analysis results with
#'   columns `x_scale`, `y_scale`, and `total_deaths`.
#'
#' @return A tibble with rows from both OTEM and BCROM combined, including
#'   columns `x_scale`, `y_scale`, `total_deaths`, and `model`.
#'
#' @noRd
combine_sensitivity_data <- function(otem_data,bcrom_data){
  model <- NULL
  otem_data <- otem_data |> dplyr::select("x_scale","y_scale","total_deaths") |>
    dplyr::mutate(model = "otem")
  bcrom_data <- bcrom_data |> dplyr::select("x_scale","y_scale","total_deaths") |>
    dplyr::mutate(model = "bcrom")

  dplyr::bind_rows(otem_data,bcrom_data)
}

#' Sensitivity data axis labels
#'
#' Provides human-readable axis labels for sensitivity analysis scenarios.
#' Each scenario is mapped to descriptive labels for the x and y axes.
#'
#' @return A named list of lists, where each element corresponds to a
#'   scenario (e.g., `"pop_mort"`, `"oat_ret"`) and contains elements:
#'   \describe{
#'     \item{x}{Character string describing the x-axis.}
#'     \item{y}{Character string describing the y-axis.}
#'   }
#'
#' @noRd
get_sensitivity_data_labels <- function(){
  list(
    "pop_mort" = list(
      "x" = "Incident OUD cases resulting from PSS diversion",
      "y" = "Mortality risk for individuals\nusing diverted PSS",
      "x_tick_labels" = c("Base","","High"),
      "y_tick_labels" = c("Rx-PSS", "Base", "Unreg Opioid")
    ),
    "oat_ret" = list(
      "x" = "PSS effect on OAT retention",
      "y" = "PSS effect on mortality",
      "x_tick_labels" = c("Max Benefit", "", "No Benefit"),
      "y_tick_labels" = c("Max Benefit", "", "No Benefit")
    )
  )
}

#' Load OTEM sensitivity analysis data
#'
#' Loads and processes OTEM sensitivity analysis results from `.RData` files.
#' These data correspond to scenario-specific analyses of opioid-related
#' mortality and OAT retention effects under policy-sensitive settings (PSS).
#'
#' @details This function reads raw `.RData` files, extracts the embedded
#'   data frames, and processes them using [process_twsa_data()].
#'
#' @return A named list with two elements:
#'   \describe{
#'     \item{pop_mort}{Processed OTEM data for the `"pop_mort"` scenario.}
#'     \item{oat_ret}{Processed OTEM data for the `"oat_ret"` scenario.}
#'   }
#'
#' @importFrom here here
#' @noRd
load_otem_sensitivity_analysis_data <- function(){
  df_twsa_div_pop_mort <- get(load(file = here("data/raw/round_two/sensitivity_analysis",
                   "incremental_twsa_div_pop_mort.RData")))
  df_twsa_pss_mort_oat_ret <- get(load(file = here("data/raw/round_two/sensitivity_analysis",
                   "incremental_twsa_pss_mort_oat_ret.RData")))

  # Process outputs from TWSA analysis and add labels
  df_twsa_div_pop_mort <- process_twsa_data(df_incremental_twsa_div_pop_mort)
  df_twsa_pss_mort_oat_ret <- process_twsa_data(df_incremental_twsa_pss_mort_oat_ret)

  return(list(
    "pop_mort" = df_twsa_div_pop_mort,
    "oat_ret" = df_twsa_pss_mort_oat_ret
  ))
}

#' Load BCROM sensitivity analysis data
#'
#' Loads sensitivity analysis results from the BCROM model, stored as `.csv`
#' files. The datasets correspond to mortality and retention scenarios, and
#' are scaled and renamed for consistency with OTEM results.
#'
#' @details Input CSVs include raw variables (e.g., `oud_incidence`,
#'   `retention_rate`, `mortality_ratio`) which are scaled and mapped to
#'   `x_scale` and `y_scale` using [scale_and_rename_columns()].
#'
#' @return A named list with two elements:
#'   \describe{
#'     \item{pop_mort}{Processed BCROM data for the `"pop_mort"` scenario.}
#'     \item{oat_ret}{Processed BCROM data for the `"oat_ret"` scenario.}
#'   }
#'
#' @importFrom here here
#' @noRd
load_bcrom_sensitivity_analysis_data <- function(){
  pop_mort <- readr::read_csv(here("data","raw","round_two","sensitivity_analysis",
                                   "BCROM_sensitivity_diversion_deaths.csv"))
  oat_ret <- readr::read_csv(here("data","raw","round_two","sensitivity_analysis",
                                   "BCROM_sensitivity_retention_deaths.csv"))

  pop_mort <- pop_mort |>
    scale_and_rename_columns("oud_incidence","x_scale") |>
    scale_and_rename_columns("diversion_mortality_ratio","y_scale")

  oat_ret <- oat_ret |>
    scale_and_rename_columns("retention_rate","x_scale") |>
    scale_and_rename_columns("mortality_ratio","y_scale")

  return(list(
    "pop_mort" = pop_mort,
    "oat_ret" = oat_ret
  ))
}
