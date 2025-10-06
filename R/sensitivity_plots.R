#' Plot Model Difference Heatmap
#'
#' @description
#' Creates a bivariate heatmap comparing the difference in total deaths between
#' two models ("OTEM" and "BCROM"), including a custom legend laid out as a 3×3 grid.
#'
#' @param result A list containing OAT results with `x_label`, `y_label`,
#'   `x_tick_labels`, `y_tick_labels`, and `data`.
#' @param sensitivity_analysis Optional name of the element within `result` containing OAT results.
#' Can be either `"pop_mort"` or `"oat_ret"`
#'   Defaults to `"oat_ret"`.
#'
#' @return A patchwork object combining the main heatmap and custom legend.
#' @export
#'
plot_model_difference_heatmap <- function(result, sensitivity_analysis = "oat_ret") {


  # ---- Main execution flow ----
  oat <- extract_oat(result, sensitivity_analysis)
  df <- prepare_heatmap_data(oat$data)
  df <- categorize_difference(df)
  palette <- define_palette()

  p_main <- create_main_plot(df, palette,
                             x_label = oat$x_label,
                             y_label = oat$y_label,
                             x_ticks = oat$x_tick_labels,
                             y_ticks = oat$y_tick_labels)

  p_legend <- create_legend_plot(palette)

  combine_plots(p_main, p_legend)
}


# ---- Internal helper functions ----
#' @noRd
extract_oat <- function(result, sensitivity_analysis) {
  oat <- result[[sensitivity_analysis]]
  list(
    x_label = oat[["x_label"]],
    y_label = oat[["y_label"]],
    x_tick_labels = oat[["x_tick_labels"]],
    y_tick_labels = oat[["y_tick_labels"]],
    data = oat[["data"]]
  )
}

#' @noRd
prepare_heatmap_data <- function(data) {
  data |>
    dplyr::group_by(model) |>
    dplyr::mutate(
      baseline = total_deaths[x_scale == 0 & y_scale == 0],
      adj_total = total_deaths - baseline
    ) |>
    dplyr::ungroup() |>
    dplyr::select(x_scale, y_scale, model, adj_total) |>
    tidyr::pivot_wider(names_from = "model", values_from = "adj_total") |>
    dplyr::mutate(diff = otem - bcrom)
}

#' @noRd
categorize_difference <- function(df) {
  df |>
    dplyr::mutate(
      sign = ifelse(diff >= 0, "OTEM>BCROM", "BCROM>OTEM"),
      magnitude = cut(
        abs(diff),
        breaks = quantile(abs(diff), probs = seq(0, 1, length.out = 4), na.rm = TRUE),
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
create_main_plot <- function(df, palette, x_label, y_label, x_ticks, y_ticks) {
  ggplot2::ggplot(df, ggplot2::aes(x = x_scale, y = y_scale, fill = category)) +
    ggplot2::geom_tile(color = "white") +
    ggplot2::geom_text(ggplot2::aes(label = label_text), size = 3) +
    ggplot2::scale_fill_manual(values = palette, guide = "none") +
    ggplot2::scale_x_continuous(breaks = c(-1, 0, 1), labels = x_ticks) +
    ggplot2::scale_y_continuous(breaks = c(-1, 0, 1), labels = y_ticks) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = x_label, y = y_label, title = "")
}

#' @noRd
create_legend_plot <- function(palette) {
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
      axis.text.x = ggplot2::element_text(size = 8),
      axis.text.y = ggplot2::element_text(angle = 90, hjust = 0.5, size = 5)
    )
}

#' @noRd
combine_plots <- function(main_plot, legend_plot) {
  layout <- c(
    patchwork::area(t = 1, l = 1, b = 5, r = 5),
    patchwork::area(t = 4, l = 5, b = 5, r = 8)
  )
  main_plot + legend_plot + patchwork::plot_layout(design = layout)
}
