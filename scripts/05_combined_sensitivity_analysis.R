# combined sensitivity analysis plots
library(here)

result <- load_sensitivity_analysis_data()

for (sensitivity_analysis in c("pop_mort", "oat_ret")) {
  g <- plot_model_difference_heatmap(result, sensitivity_analysis)
  show(g)
  ggsave(here(
    "results", "round_two", "sensitivity_analyses",
    paste0("sa_comparison_", sensitivity_analysis, ".png")
  ))
}
