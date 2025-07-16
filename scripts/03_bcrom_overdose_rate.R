library(here)
library(dplyr)
library(ggplot2)
library(pss.model.comparison)

model_data <- load_data(round = "two") |>
  filter(model == "bcrom")

# rate of observed overdoses to all model inferred overdoses from the
# bcrom model
overdose_rates <- model_data |>
  mutate(observed_overdoses = `PSS ambulance overdoses` + `no PSS ambulance overdoses`,
         all_overdoses = `PSS overdoses` + `no PSS overdoses`) |>
  group_by(year,month) |>
  summarise(observed_overdose_rate = mean(observed_overdoses / all_overdoses) ) |>
  ungroup() |>
  mutate(date = lubridate::ymd(glue::glue("{year}-{month}-01"))) |>
  filter(date >= lubridate::ymd("2020-03-01"))

g <- overdose_rates |>
  ggplot(aes(x=date,y=observed_overdose_rate)) +
  geom_line() +
  geom_vline(xintercept = lubridate::ymd("2020-03-01"),linetype="dashed") +
  coord_cartesian(ylim=c(0,1)) +
  scale_y_continuous(labels = scales::percent) +
  ylab("Rate of paramedic-attended/nto all overdoses")
show(g)
ggsave(here("results","round_one","bcrom_overdose_rates.png"))

overdose_rates |> readr::write_csv(
  here("results","round_one","bcrom_overdose_rates.csv")
)
