# combined sensitivity analysis plots
result <- load_sensitivity_analysis_data()
names(result)
names(result[["pop_mort"]])
colnames(result[["pop_mort"]][["data"]])

library(dplyr)
library(ggplot2)
library(patchwork)

x_label <- result[["oat_ret"]][["x_label"]]
y_label <- result[["oat_ret"]][["y_label"]]
x_tick_labels <- c("Max Benefit", "", "No Benefit")
y_tick_labels <- c("Max Benefit", "", "No Benefit")
heatmap_data <- result[["oat_ret"]][["data"]] |>
  dplyr::group_by(model) %>%
  dplyr::mutate(
    baseline = total_deaths[x_scale == 0 & y_scale == 0],
    adj_total = total_deaths - baseline
  ) |>
  dplyr::ungroup() |>
  dplyr::select(x_scale, y_scale, model, adj_total) |>
  tidyr::pivot_wider(
    names_from = "model",
    values_from = "adj_total"
  ) |>
  dplyr::mutate(diff = otem - bcrom)

# Cut into 4 categories: direction (sign) × magnitude
heatmap_data <- heatmap_data |>
  mutate(
    sign = ifelse(diff >= 0, "OTEM>BCROM", "BCROM>OTEM"),
    magnitude = cut(abs(diff),
                    breaks = quantile(abs(diff), probs = seq(0, 1, length.out = 4),
                                      na.rm = TRUE),
                    labels = c("small", "medium", "large"),
                    include.lowest = TRUE
                    ),
    category = paste(sign, magnitude, sep = "_")
  ) |>
  arrange(y_scale, x_scale) |>
  mutate(
    x_index = as.integer(factor(x_scale, levels = sort(unique(x_scale)))),
    y_index = as.integer(factor(y_scale, levels = sort(unique(y_scale)))),
    label_text = ifelse((x_index + y_index) %% 2 == 0, round(diff), "")
  )

# Define 3x3 palette (rows = sign, cols = magnitude)
# First row BCROM>OTEM (blue), second row OTEM>BCROM (red)
palette_matrix <- matrix(
  c("#deebf7", "#9ecae1", "#3182bd",   # BCROM>OTEM small→large
    "#fee5d9", "#fcae91", "#cb181d"),  # OTEM>BCROM small→large
  nrow = 2, byrow = TRUE
)

names_palette <- c(
  "BCROM>OTEM_small"  = palette_matrix[1,1],
  "BCROM>OTEM_medium" = palette_matrix[1,2],
  "BCROM>OTEM_large"  = palette_matrix[1,3],
  "OTEM>BCROM_small"  = palette_matrix[2,1],
  "OTEM>BCROM_medium" = palette_matrix[2,2],
  "OTEM>BCROM_large"  = palette_matrix[2,3]
)

# Main heatmap
p_main <- ggplot2::ggplot(heatmap_data,
                          ggplot2::aes(x = x_scale, y = y_scale, fill = category)) +
  ggplot2::geom_tile(color = "white") +
  ggplot2::geom_text(aes(label = label_text), size = 3) +
  ggplot2::scale_fill_manual(values = names_palette, guide = "none") +
  ggplot2::scale_x_continuous(breaks = c(-1, 0, 1), labels = x_tick_labels) +
  ggplot2::scale_y_continuous(breaks = c(-1, 0, 1), labels = y_tick_labels) +
  ggplot2::theme_minimal() +
  ggplot2::labs(
    x = x_label,
    y = y_label,
    title = ""
  )

# Create custom legend as a mini heatmap
legend_df <- expand.grid(
  mag_bin = c("small", "medium", "large"),
  sign = c("OTEM>BCROM", "BCROM>OTEM")  # order so BCROM is on top
) %>%
  mutate(category = paste(sign, mag_bin, sep = "_"),
         sign_label = dplyr::case_when(
           sign == "BCROM>OTEM" ~ "BCROM>\nOTEM",
           sign == "OTEM>BCROM" ~ "OTEM>\nBCROM",
           TRUE ~ sign
         ))

p_legend <- ggplot2::ggplot(legend_df,
                            ggplot2::aes(x = mag_bin, y = sign_label, fill = category)) +
  ggplot2::geom_tile() +
  ggplot2::scale_fill_manual(values = names_palette, guide = "none") +
  ggplot2::coord_equal() +
  ggplot2::theme_void() +
  ggplot2::labs(x = "", y = "") +
  ggplot2::theme(
    axis.title = element_text(size = 10),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(angle = 90, hjust = 0.5, size = 5)
  )

# Combine main plot with custom legend
layout <- c(
  patchwork::area(t = 1, l = 1, b = 5, r = 5),
  patchwork::area(t = 4, l = 5, b = 5, r = 8)
)

final_plot <- p_main + p_legend +
  patchwork::plot_layout(design = layout)
show(final_plot)
