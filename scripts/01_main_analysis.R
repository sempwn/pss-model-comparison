library(here)
library(dplyr)
library(ggplot2)

source(here("R","data.R"))
source(here("R","process_data.R"))
source(here("R","plots.R"))

model_data <- load_data()

plot_data <- calculate_year_quarter_data(model_data)
for(outcome in c("PSS drug_deaths","no PSS overdoses","no PSS drug_deaths",
                 "PSS overdoses" )){
  g <- plot_outcome_by_quarter(plot_data,outcome = outcome)
  show(g)
  ggsave(here("results",glue::glue("{outcome} model quarter comparison.png")))
}
