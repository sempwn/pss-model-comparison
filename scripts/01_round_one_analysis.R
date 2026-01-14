library(here)
library(dplyr)
library(ggplot2)
library(fs)
library(pss.model.comparison)

# relabel outcomes for plotting
relabel_outcomes <- c(
  "Baseline deaths" = "PSS drug_deaths",
  "Counterfactual deaths" = "no PSS drug_deaths",
  "Baseline drug poisoning events" = "PSS overdoses",
  "Counterfactual drug poisoning events" = "no PSS overdoses",
  "Cumulative deaths averted" = "cumulative deaths averted",
  "Cumulative drug poisoning\n events averted" = "cumulative overdoses averted"
)

outcomes <- names(relabel_outcomes)

model_data <- load_data()

# outcomes by quarter
plot_data <- calculate_year_quarter_data(model_data) |>
  add_averted_columns() |>
  rename(!!!relabel_outcomes)

for (outcome in outcomes) {
  if (outcome == "Cumulative drug poisoning\n events averted") {
    legend_position <- c(0.2, 0.9)
  } else {
    legend_position <- "none"
  }

  g <- plot_outcome_by_quarter(plot_data,
    outcome = outcome,
    legend_position = legend_position
  )
  show(g)
  outcome_file_label <- path_sanitize(outcome)
  ggsave(here(
    "results", "round_one",
    glue::glue("{outcome_file_label} model quarter comparison.png")
  ))
  ggsave(here(
    "results", "round_one",
    glue::glue("{outcome_file_label} model quarter comparison.pdf")
  ))
}

year_quarter_summary <- model_data |>
  calculate_year_quarter_data() |>
  add_averted_columns() |>
  summarise_year_quarter_data()

print(year_quarter_summary)

print("Total deaths averted by model: ")
print(summarise_events_averted(model_data, event = "deaths"))

print("Total overdoses averted by model: ")
print(summarise_events_averted(model_data, event = "overdoses"))
