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
plot_outcome_by_quarter <- function(plot_data,outcome = "PSS drug_deaths"){
  year_quarter <- model <- NULL
  outcome_label <- stringr::str_replace_all(outcome,"_"," ")
  g <- plot_data |>
    ggplot2::ggplot(ggplot2::aes(x=year_quarter,y=.data[[outcome]],
                                 fill=model)) +
    ggplot2::geom_boxplot() +
    ggplot2::theme_classic() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

  return(g)
}
