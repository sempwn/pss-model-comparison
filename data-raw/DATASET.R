## compile all data in data-raw into an internal dataset that can be ingested
## by package functions

DATASET <- list()

# rounds data
for(round in c("one","two")){
  round_label <- paste0("round_",round)
  bcrom_data_file <- here("data-raw",round_label,
                          "BCROM_comparison_outputs.csv")
  otem_data_file <- here("data-raw",round_label,
                         "OTEM_comparison_outputs.csv")
  bcrom_data <- readr::read_csv(bcrom_data_file)
  otem_data <- readr::read_csv(otem_data_file)
  DATASET[[round_label]][["bcrom"]] <- bcrom_data
  DATASET[[round_label]][["otem"]] <- otem_data
}

# sensitivity analysis data
#
# OTEM sensitivity analysis
df_twsa_div_pop_mort <- get(load(file = here("data-raw/round_two/sensitivity_analysis",
                                             "incremental_twsa_div_pop_mort.RData")))
df_twsa_pss_mort_oat_ret <- get(load(file = here("data-raw/round_two/sensitivity_analysis",
                                                 "incremental_twsa_pss_mort_oat_ret.RData")))
DATASET[["sensitivity"]][["otem"]][["pop_mort"]] <- df_twsa_div_pop_mort
DATASET[["sensitivity"]][["otem"]][["oat_ret"]] <- df_twsa_pss_mort_oat_ret

# BCROM sensitivity analysis
bcrom_pop_mort <- readr::read_csv(here("data-raw","round_two","sensitivity_analysis",
                                 "BCROM_sensitivity_diversion_deaths.csv"))
bcrom_oat_ret <- readr::read_csv(here("data-raw","round_two","sensitivity_analysis",
                                "BCROM_sensitivity_retention_deaths.csv"))
DATASET[["sensitivity"]][["bcrom"]][["pop_mort"]] <- bcrom_pop_mort
DATASET[["sensitivity"]][["bcrom"]][["oat_ret"]] <- bcrom_oat_ret

usethis::use_data(DATASET, overwrite = TRUE, internal = TRUE, compress = "xz")
