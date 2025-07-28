library(here)
library(dplyr)
library(ggplot2)
library(pss.model.comparison)

outcomes <- c(
  "PSS drug_deaths", "no PSS overdoses",
  "no PSS drug_deaths", "PSS overdoses",
  "cumulative deaths averted", "cumulative overdoses averted")

model_data <- load_data(round = "two")

# outcomes by quarter
plot_data <- calculate_year_quarter_data(model_data) |>
  add_averted_columns()
for(outcome in outcomes){
  g <- plot_outcome_by_quarter(plot_data,outcome = outcome)
  show(g)
  ggsave(here("results","round_two",
              glue::glue("{outcome} model quarter comparison.png")))
}
