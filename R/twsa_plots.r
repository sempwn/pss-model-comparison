# Function to create TWSA plots
twsa_heatmap_plot <- function(data, fill_var, x_labels, y_labels, x_title, y_title, filename) {
  # Calculate limits and breaks based on data
  max_abs_value <- max(abs(data[[fill_var]]), na.rm = TRUE)
  # Round up to nearest 5
  limit_value <- ceiling(max_abs_value / 5) * 5
  limits <- c(-limit_value, limit_value)
  breaks <- c(-limit_value, 0, limit_value)

  plot <- ggplot(data, aes(x = x_scale, y = y_scale, fill = .data[[fill_var]])) +
    theme_bw() +
    geom_tile() +
    scale_fill_gradientn(
      colours = c("#4393c3", "#f7f7f7", "#e08214"),
      limits = limits,
      breaks = breaks,
      labels = c("Favours PSS", "Scenarios equal", "Favours counterfactual"),
      guide = guide_colourbar(
        direction = "horizontal",
        title = NULL
      )
    ) +
    geom_text(aes(label = round(.data[[fill_var]], 0)), color = "black", size = 1.8, fontface = "bold") +
    scale_x_continuous(breaks = c(-1, -.75, -.5, -.25, 0, .25, .5, .75, 1), labels = x_labels) +
    scale_y_continuous(breaks = c(-1, -.75, -.5, -.25, 0, .25, .5, .75, 1), labels = y_labels) +
    labs(x = x_title, y = y_title) +
    theme(
      axis.title.x = element_text(size = 8, hjust = 0.5),
      axis.title.y = element_text(size = 8, hjust = 0.5),
      axis.text = element_text(size = 7, color = "black"),
      plot.margin = grid::unit(c(0, 0.35, 0, 0.35), "cm"),
      legend.position = "bottom",
      legend.key.width = grid::unit(1.5, "cm"),
      legend.text = element_text(size = 8)
    ) +
    coord_fixed()

  # Save plot
  ggsave(plot, filename = filename, width = 6, height = 6, dpi = 600)

  return(plot)
}

# Data processing for TWSA plots
process_twsa_data <- function(data_obj) {
  # Generate 17x17 grid coordinates from -1 to 1 (required to produce a square grid)
  x_coords <- seq(-1, 1, length.out = 17)
  y_coords <- seq(-1, 1, length.out = 17)

  grid <- expand.grid(x_scale = x_coords, y_scale = y_coords)
  temp_data <- cbind(grid, data_obj)

  temp_data %>%
    select("x_scale", "y_scale", "n_inc_odf_scaled", "n_inc_odn_scaled") %>%
    mutate(
      incremental_overdoses_scaled = n_inc_odf_scaled + n_inc_odn_scaled
    ) %>%
    as_tibble()
}

## Create label vectors
create_odd_labels <- function(vector, base_label = "Base") {
  odd_indices <- seq(1, length(vector), by = 2)
  labels <- as.character(vector[odd_indices])
  labels[1] <- paste0(base_label, " (", labels[1], ")")
  return(labels)
}
