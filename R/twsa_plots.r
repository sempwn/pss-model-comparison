#' Create a  Sensitivity Analysis  heatmap plot
#'
#' @description
#' Generates a heatmap for Tornado-Waterfall Sensitivity Analysis (TWSA) results,
#' visualizing changes in outcomes across a 2D parameter space. The fill colour
#' represents the specified variable, and labels are added for each grid cell.
#'
#' @param data A data frame containing TWSA results, with columns `x_scale`, `y_scale`,
#'   and the variable specified by `fill_var`.
#' @param fill_var A string giving the name of the column in `data` to use for the fill colour.
#' @param x_labels A character vector of labels to display along the x-axis.
#' @param y_labels A character vector of labels to display along the y-axis.
#' @param x_title A string specifying the x-axis title.
#' @param y_title A string specifying the y-axis title.
#'
#' @details
#' The colour scale is symmetric around zero and uses a diverging palette to
#' distinguish between positive and negative values. The legend labels correspond
#' to "Favours PSS", "Scenarios equal", and "Favours counterfactual".
#'
#' @return A `ggplot` object representing the TWSA heatmap plot.
#'
#' @examples
#' \dontrun{
#' plot <- twsa_heatmap_plot(my_data, "incremental_overdoses_scaled",
#'   x_labels = seq(-1, 1, 0.25),
#'   y_labels = seq(-1, 1, 0.25),
#'   x_title = "Parameter X",
#'   y_title = "Parameter Y"
#' )
#' print(plot)
#' }
#'
#' @export
twsa_heatmap_plot <- function(data, fill_var, x_labels, y_labels, x_title,
                              y_title) {
  x_scale <- y_scale <- .data <- NULL
  normalized_breaks <- c(-1, -.75, -.5, -.25, 0, .25, .5, .75, 1)
  # Calculate limits and breaks based on data
  max_abs_value <- max(abs(data[[fill_var]]), na.rm = TRUE)
  # Round up to nearest 5
  limit_value <- ceiling(max_abs_value / 5) * 5
  limits <- c(-limit_value, limit_value)
  breaks <- c(-limit_value, 0, limit_value)

  plot <- ggplot2::ggplot(data, ggplot2::aes(
    x = x_scale, y = y_scale,
    fill = .data[[fill_var]]
  )) +
    ggplot2::theme_bw() +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_gradientn(
      colours = c("#4393c3", "#f7f7f7", "#e08214"),
      limits = limits,
      breaks = breaks,
      labels = c("Favours PSS", "Scenarios equal", "Favours counterfactual"),
      guide = ggplot2::guide_colourbar(
        direction = "horizontal",
        title = NULL
      )
    ) +
    ggplot2::geom_text(aes(label = round(.data[[fill_var]], 0)),
      color = "black", size = 1.8, fontface = "bold"
    ) +
    ggplot2::scale_x_continuous(breaks = normalized_breaks, labels = x_labels) +
    ggplot2::scale_y_continuous(breaks = normalized_breaks, labels = y_labels) +
    ggplot2::labs(x = x_title, y = y_title) +
    ggplot2::theme(
      axis.title.x = ggplot2::element_text(size = 8, hjust = 0.5),
      axis.title.y = ggplot2::element_text(size = 8, hjust = 0.5),
      axis.text = ggplot2::element_text(size = 7, color = "black"),
      plot.margin = grid::unit(c(0, 0.35, 0, 0.35), "cm"),
      legend.position = "bottom",
      legend.key.width = grid::unit(1.5, "cm"),
      legend.text = ggplot2::element_text(size = 8)
    ) +
    ggplot2::coord_fixed()

  return(plot)
}

#' Process data for sensitivity analysis plotting
#'
#' @description
#' Takes a TWSA result object and formats it into a tibble with `x_scale` and
#' `y_scale` coordinates covering a full square grid from -1 to 1, suitable
#' for plotting with `twsa_heatmap_plot()`.
#'
#' @param data_obj A data frame or matrix containing TWSA result values,
#'   with columns `n_inc_odf_scaled` and `n_inc_odn_scaled`.
#'
#' @details
#' The function generates a 17x17 grid (289 points) for plotting, corresponding
#' to combinations of x and y scaling factors from -1 to 1. The column
#' `incremental_overdoses_scaled` is computed as the sum of `n_inc_odf_scaled`
#' and `n_inc_odn_scaled`.
#'
#' @return A tibble with columns:
#' \itemize{
#'   \item \code{x_scale} — numeric x-coordinate for the grid
#'   \item \code{y_scale} — numeric y-coordinate for the grid
#'   \item \code{n_inc_odf_scaled} — scaled incremental overdoses (ODF)
#'   \item \code{n_inc_odn_scaled} — scaled incremental overdoses (ODN)
#'   \item \code{incremental_overdoses_scaled} — total scaled incremental overdoses
#' }
#'
#' @examples
#' \dontrun{
#' processed <- process_twsa_data(my_results)
#' head(processed)
#' }
#'
#' @export
process_twsa_data <- function(data_obj) {
  n_inc_odf_scaled <- n_inc_odn_scaled <- NULL
  # Generate 17x17 grid coordinates from -1 to 1 (required to produce a square grid)
  x_coords <- seq(-1, 1, length.out = 17)
  y_coords <- seq(-1, 1, length.out = 17)

  grid <- expand.grid(x_scale = x_coords, y_scale = y_coords)
  temp_data <- cbind(grid, data_obj)

  temp_data |>
    dplyr::select(
      "x_scale", "y_scale", "n_inc_odf_scaled",
      "n_inc_odn_scaled"
    ) |>
    dplyr::mutate(
      incremental_overdoses_scaled = n_inc_odf_scaled + n_inc_odn_scaled
    ) |>
    dplyr::as_tibble()
}

#' Create labels for odd-indexed elements
#'
#' @description
#' Produces a vector of labels using only the odd-indexed elements from the
#' provided vector, optionally replacing the first label with a base-case
#' label containing its value.
#'
#' @param vector A character or numeric vector from which labels will be created.
#' @param base_label A string giving the label to use for the first element,
#'   with its value in parentheses. Defaults to `"Base"`.
#'
#' @return A character vector containing labels for odd-indexed elements of `vector`.
#'
#' @examples
#' create_odd_labels(seq(1, 9))
#' create_odd_labels(seq(1, 9), base_label = "Reference")
#'
#' @export
create_odd_labels <- function(vector, base_label = "Base") {
  odd_indices <- seq(1, length(vector), by = 2)
  labels <- as.character(vector[odd_indices])
  labels[1] <- paste0(base_label, " (", labels[1], ")")
  return(labels)
}
