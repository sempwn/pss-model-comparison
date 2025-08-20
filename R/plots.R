#' Plot Outcome by Year-Quarter and Model
#'
#' Creates a boxplot of a specified outcome variable by `year_quarter`,
#' grouped and colored by `model`. This is useful for comparing outcomes
#' (e.g., overdose deaths) across different models over time.
#'
#' @param plot_data A data frame containing at least the columns `year_quarter`,
#'   the specified `outcome`, and `model`. The `year_quarter` column should be
#'   a factor or character indicating time periods, and `model` should specify
#'   the model group.
#' @param outcome A character string specifying the name of the outcome column
#'   in `plot_data` to be plotted. Defaults to `"PSS drug_deaths"`.
#'
#' @return A `ggplot2` object representing the boxplot of the specified outcome
#'   by `year_quarter` and `model`.
#'
#' @examples
#' \dontrun{
#' plot_data <- data.frame(
#'   year_quarter = rep(c("2020 Q1", "2020 Q2"), each = 10),
#'   model = rep(c("Model A", "Model B"), times = 10),
#'   `PSS drug_deaths` = rpois(20, 10)
#' )
#' plot_outcome_by_quarter(plot_data)
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_boxplot theme_classic
#' @importFrom stringr str_replace_all
#' @export
plot_outcome_by_quarter <- function(plot_data, outcome = "PSS drug_deaths") {
  year_quarter <- model <- .data <- NULL
  outcome_label <- stringr::str_replace_all(outcome, "_", " ")
  g <- plot_data |>
    ggplot2::ggplot(ggplot2::aes(
      x = year_quarter, y = .data[[outcome]],
      fill = model
    )) +
    ggplot2::geom_boxplot() +
    ggplot2::theme_classic() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

  return(g)
}


#' Plot cumulative deaths averted across models and runs
#'
#' This function takes simulated model output and produces a line plot of
#' cumulative deaths averted over time. Deaths averted are calculated as the
#' difference between the number of drug-related deaths under a
#' counterfactual scenario with no PSS and the number of deaths under the
#' PSS intervention. The results are grouped by model and simulation run,
#' and cumulative sums are plotted as semi-transparent lines to visualize
#' uncertainty across runs.
#'
#' @param model_data A data frame containing model simulation output with the
#'   following required columns:
#'   \itemize{
#'     \item `date` — time variable (Date or numeric).
#'     \item `no PSS drug_deaths` — number of deaths in the counterfactual
#'       scenario with no PSS intervention.
#'     \item `PSS drug_deaths` — number of deaths in the PSS intervention scenario.
#'     \item `model` — model identifier (factor or character).
#'     \item `run` — simulation run identifier (numeric or character).
#'   }
#'
#' @return A `ggplot` object showing cumulative deaths averted over time,
#'   stratified by model with multiple simulation runs shown as faint lines.
#'
#' @examples
#' \dontrun{
#' # Example model data (toy example)
#' df <- data.frame(
#'   date = rep(seq.Date(as.Date("2020-01-01"), by = "month", length.out = 12), 2),
#'   `no PSS drug_deaths` = rpois(24, 10),
#'   `PSS drug_deaths` = rpois(24, 7),
#'   model = rep(c("Model A", "Model B"), each = 12),
#'   run = rep(1:2, each = 12)
#' )
#'
#' plot_deaths_averted_lines(df)
#' }
#'
#' @export
plot_deaths_averted_lines <- function(model_data) {
  date <- deaths_averted <- model <- run <- NULL
  `no PSS drug_deaths` <- `PSS drug_deaths` <- NULL

  model_data |>
    dplyr::mutate(deaths_averted = `no PSS drug_deaths` - `PSS drug_deaths`) |>
    dplyr::group_by(model, run) |>
    dplyr::arrange(date) |>
    dplyr::mutate(deaths_averted = cumsum(deaths_averted)) |>
    dplyr::select(model, run, date, deaths_averted) |>
    ggplot2::ggplot() +
    ggplot2::geom_line(
      ggplot2::aes(
        x = date, y = deaths_averted, color = model,
        group = interaction(run, model)
      ),
      alpha = 0.05
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(legend.position = "bottom") +
    ggplot2::guides(colour = ggplot2::guide_legend(override.aes = list(alpha = 1)))
}
