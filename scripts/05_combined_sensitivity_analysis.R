# combined sensitivity analysis plots
library(pss.model.comparison)
library(here)

result <- load_sensitivity_analysis_data()
difference_breaks <- get_low_medium_high_breaks(result)
total_breaks <- get_max_min_breaks(result)
for (sensitivity_analysis in c("pop_mort", "oat_ret")) {
  g <- plot_model_difference_heatmap(result, sensitivity_analysis,
    breaks = difference_breaks
  )
  show(g)
  ggsave(
    here(
      "results", "round_two", "sensitivity_analyses",
      paste0("sa_comparison_", sensitivity_analysis, ".png")
    ),
    dpi = 400,
    width = 10,
    height = 8
  )

  for (model_name in c("bcrom", "otem")) {
    g <- plot_sensitivity_analysis_heatmap(
      result,
      model_name = model_name,
      sensitivity_analysis = sensitivity_analysis,
      breaks = total_breaks
    )
    show(g)
    ggsave(
      here(
        "results", "round_two", "sensitivity_analyses",
        paste0("sa_", sensitivity_analysis, "_", model_name, ".png")
      ),
      dpi = 400,
      width = 10,
      height = 8
    )
  }
}
