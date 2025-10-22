
#' Plot sensitivity analysis heatmaps
#'
#' This function generates a heatmap visualization of sensitivity analysis results,
#' showing the impact of varying model parameters on total deaths (or another outcome)
#' for a given model. Positive values represent deaths averted, while negative values
#' represent deaths abetted. The heatmap uses a diverging color scale (red white blue)
#' with qualitative legend labels for interpretability.
#'
#' @param result A list containing sensitivity analysis outputs. Must include an element
#'   named according to \code{sensitivity_analysis} that contains:
#'   \itemize{
#'     \item \code{data}: A data frame with columns \code{model}, \code{x_scale},
#'       \code{y_scale}, and \code{total_deaths}.
#'     \item \code{x_label}, \code{y_label}: Character strings for axis labels.
#'     \item \code{x_tick_labels}, \code{y_tick_labels}: Optional vectors of tick labels
#'       for the x and y axes.
#'   }
#' @param sensitivity_analysis Character string specifying which sensitivity analysis
#'   result to use from \code{result}. Defaults to \code{"oat_ret"}.
#' @param model_name Character string specifying the model to plot within the sensitivity
#'   analysis data. Defaults to \code{"otem"}.
#' @param breaks Numeric vector of length 2 giving the minimum and maximum values
#'   for the color scale. If \code{NULL} (default), the limits are determined from the
#'   observed range of \code{category} (i.e., reversed total deaths).
#'
#' @details
#' The function filters the sensitivity analysis data for the specified model,
#' reverses the sign of total deaths so that positive values indicate deaths averted,
#' and assigns integer indices for the x and y positions. A diverging color gradient
#' is used, centered at zero, with red corresponding to abetted (negative) and blue
#' corresponding to averted (positive) values.
#'
#' The legend includes qualitative labels ("Abetted -" and "Averted +") along with
#' the numeric range, aiding interpretation of model outcomes.
#'
#' @return A \code{ggplot} object representing the sensitivity analysis heatmap.
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' result <- list(
#'   oat_ret = list(
#'     data = data.frame(
#'       model = "otem",
#'       x_scale = rep(1:3, each = 3),
#'       y_scale = rep(1:3, 3),
#'       total_deaths = rnorm(9)
#'     ),
#'     x_label = "Parameter A",
#'     y_label = "Parameter B",
#'     x_tick_labels = c("Low", "Med", "High"),
#'     y_tick_labels = c("Low", "Med", "High")
#'   )
#' )
#'
#' plot_sensitivity_analysis_heatmap(result)
#' }
#'
#' @seealso [plot_model_difference_heatmap()]
#' @export
plot_sensitivity_analysis_heatmap <- function(result, sensitivity_analysis = "oat_ret",
                                          model_name = "otem", breaks = NULL) {
  model <- total_deaths <- NULL
  x_scale <- y_scale <- x_index <- y_index <-
  # ---- Main execution flow ----
  scenario_data <- result[[sensitivity_analysis]]
  df <- scenario_data$data |>
    dplyr::filter(model == model_name) |>
    dplyr::mutate(
      # reverse so +ve represents deaths averted
      total_deaths = -1*total_deaths,
      x_index = as.integer(factor(x_scale, levels = sort(unique(x_scale)))),
      y_index = as.integer(factor(y_scale, levels = sort(unique(y_scale)))),
      label_text = ifelse((x_index + y_index) %% 2 == 0, round(total_deaths), "")
      ) |>
    dplyr::rename("category" = "total_deaths")

  if(is.null(breaks)){
    breaks <- c(
      min(df$category),
      max(df$category)
    )
  }

  p_main <- create_main_plot(df,
                             x_label = scenario_data$x_label,
                             y_label = scenario_data$y_label,
                             x_ticks = scenario_data$x_tick_labels,
                             y_ticks = scenario_data$y_tick_labels) +
    ggplot2::scale_fill_gradient2(
      low = "red",
      mid = "white",
      high = "blue",
      midpoint = 0,
      limits = breaks,
      labels = c("Abetted (-)", "0", "Averted (+)"),
      breaks = c(breaks[1], 0, breaks[2])
    ) +
    ggplot2::labs(fill="")

  return(p_main)
}


#' Plot Model Difference Heatmap
#'
#' @description
#' Creates a bivariate heatmap comparing the difference in total deaths between
#' two models ("OTEM" and "BCROM"), including a custom legend laid out as a 3x3 grid.
#'
#' @param result A list containing OAT results with `x_label`, `y_label`,
#'   `x_tick_labels`, `y_tick_labels`, and `data`.
#' @param sensitivity_analysis Optional name of the element within `result` containing OAT results.
#' Can be either `"pop_mort"` or `"oat_ret"`
#'   Defaults to `"oat_ret"`.
#' @param breaks vector of length 4 to define small, medium, and large
#' categories, default is `NULL`
#'
#' @return A patchwork object combining the main heatmap and custom legend.
#' @export
#'
plot_model_difference_heatmap <- function(result, sensitivity_analysis = "oat_ret",
                                          breaks = NULL) {


  # ---- Main execution flow ----
  scenario_data <- result[[sensitivity_analysis]]
  df <- transform_normalized_differences_data(scenario_data[["data"]],scenario_data[["baseline"]])
  df <- categorize_difference(df, breaks = breaks)
  palette <- define_palette()

  p_main <- create_main_plot(df,
                             x_label = scenario_data$x_label,
                             y_label = scenario_data$y_label,
                             x_ticks = scenario_data$x_tick_labels,
                             y_ticks = scenario_data$y_tick_labels,
                             palette = palette)

  p_legend <- create_legend_plot(palette)

  combine_plots(p_main, p_legend)
}


#' @noRd
transform_normalized_differences_data <- function(data,baseline) {
  model <- total_deaths <- x_scale <- y_scale <- adj_total <- NULL
  baseline_deaths <- NULL
  otem <- bcrom <- NULL
  data |>
    dplyr::group_by(model) |>
    dplyr::mutate(
      baseline_deaths = total_deaths[x_scale == baseline[1] & y_scale == baseline[2]],
      adj_total = total_deaths - baseline_deaths
    ) |>
    dplyr::ungroup() |>
    dplyr::select(x_scale, y_scale, model, adj_total) |>
    tidyr::pivot_wider(names_from = "model", values_from = "adj_total") |>
    dplyr::mutate(diff = otem - bcrom)
}

#' @param df dataframe with `diff`, `x_scale`, and `y_scale`
#' @param breaks vector of length 4 to define small, medium, and large
#' categories, default is `NULL`
#' @noRd
#' @importFrom stats quantile
categorize_difference <- function(df, breaks = NULL) {
  magnitude <- y_scale <- x_scale <- x_index <- y_index <- NULL
  if(is.null(breaks)){
    breaks <- quantile(abs(df[["diff"]]), probs = seq(0, 1, length.out = 4), na.rm = TRUE)
  }
  df |>
    dplyr::mutate(
      sign = ifelse(diff >= 0, "OTEM>BCROM", "BCROM>OTEM"),
      magnitude = cut(
        abs(diff),
        breaks = breaks,
        labels = c("small", "medium", "large"),
        include.lowest = TRUE
      ),
      category = paste(sign, magnitude, sep = "_")
    ) |>
    dplyr::arrange(y_scale, x_scale) |>
    dplyr::mutate(
      x_index = as.integer(factor(x_scale, levels = sort(unique(x_scale)))),
      y_index = as.integer(factor(y_scale, levels = sort(unique(y_scale)))),
      label_text = ifelse((x_index + y_index) %% 2 == 0, round(abs(diff)), "")
    )
}

#' @noRd
define_palette <- function() {
  palette_matrix <- matrix(
    c("#deebf7", "#9ecae1", "#3182bd",   # BCROM>OTEM
      "#fee5d9", "#fcae91", "#cb181d"),  # OTEM>BCROM
    nrow = 2, byrow = TRUE
  )
  c(
    "BCROM>OTEM_small"  = palette_matrix[1,1],
    "BCROM>OTEM_medium" = palette_matrix[1,2],
    "BCROM>OTEM_large"  = palette_matrix[1,3],
    "OTEM>BCROM_small"  = palette_matrix[2,1],
    "OTEM>BCROM_medium" = palette_matrix[2,2],
    "OTEM>BCROM_large"  = palette_matrix[2,3]
  )
}

#' @noRd
create_main_plot <- function(df, x_label, y_label, x_ticks, y_ticks, palette = NULL) {
  x_scale <- y_scale <- category <- label_text <- NULL
  g <- ggplot2::ggplot(df, ggplot2::aes(x = x_scale, y = y_scale, fill = category)) +
    ggplot2::geom_tile(color = "white") +
    ggplot2::geom_text(ggplot2::aes(label = label_text), size = 3)

  if(!is.null(palette)){
    g <- g +
      ggplot2::scale_fill_manual(values = palette, guide = "none")
  }
    g <- g +
    ggplot2::scale_x_continuous(breaks = c(-1, 0, 1), labels = x_ticks) +
    ggplot2::scale_y_continuous(breaks = c(-1, 0, 1), labels = y_ticks) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = x_label, y = y_label, title = "")
}

#' @noRd
create_legend_plot <- function(palette) {
  mag_bin <- sign_label <- category <- NULL
  legend_df <- expand.grid(
    mag_bin = c("small", "medium", "large"),
    sign = c("OTEM>BCROM", "BCROM>OTEM")
  ) |>
    dplyr::mutate(
      category = paste(sign, mag_bin, sep = "_"),
      sign_label = dplyr::case_when(
        sign == "BCROM>OTEM" ~ "BCROM>\nOTEM",
        sign == "OTEM>BCROM" ~ "OTEM>\nBCROM",
        TRUE ~ sign
      )
    )

  ggplot2::ggplot(legend_df,
                  ggplot2::aes(x = mag_bin, y = sign_label, fill = category)) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_manual(values = palette, guide = "none") +
    ggplot2::coord_equal() +
    ggplot2::theme_void() +
    ggplot2::labs(x = "", y = "") +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(size = 5),
      axis.text.y = ggplot2::element_text(angle = 90, hjust = 0.5, size = 5)
    )
}

#' @noRd
combine_plots <- function(main_plot, legend_plot) {
  layout <- c(
    patchwork::area(t = 1, l = 1, b = 5, r = 8),
    patchwork::area(t = 4.5, l = 9, b = 5, r = 10)
  )
  main_plot + legend_plot + patchwork::plot_layout(design = layout)
}

#' get result breaks into small, medium, and large categories
#' @param result output of [load_sensitivity_analysis_data()]
#' @return vector of length 4 representing the 0th 33rd, 66th and 100th
#' percentiles
#' @export
get_low_medium_high_breaks <- function(result){
  diffs <- c()
  for(sensitivity_analysis in names(result)){
    scenario_data <- result[[sensitivity_analysis]]
    df <- transform_normalized_differences_data(scenario_data[["data"]],
                                                scenario_data[["baseline"]])
    diffs <- c(diffs,df[["diff"]])
  }

  quantile(abs(diffs), probs = seq(0, 1, length.out = 4), na.rm = TRUE)
}

#' get max and min deaths_averted from results
#' @param result output of [load_sensitivity_analysis_data()]
#' @return vector of length 2 representing min and max
#' @export
get_max_min_breaks <- function(result){
  total_deaths <- c()
  for(sensitivity_analysis in names(result)){
    scenario_data <- result[[sensitivity_analysis]][["data"]]
    total_deaths <- c(total_deaths, scenario_data[["total_deaths"]])
  }

  quantile(-total_deaths, probs = c(0, 1), na.rm = TRUE)
}
