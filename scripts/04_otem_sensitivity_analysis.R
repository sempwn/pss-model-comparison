library(dplyr)
library(ggplot2)
library(grid)
library(here)
library(pss.model.comparison)

# Load data
load(file = here("data-raw/round_two/sensitivity_analysis",
                 "incremental_twsa_div_pop_mort.RData"))
load(file = here("data-raw/round_two/sensitivity_analysis",
                 "incremental_twsa_pss_mort_oat_ret.RData"))

# Extract OUD incidence numbers for labels (individuals and person-months)
v_inc_pss_div_non_inc_scaled <- round(df_incremental_twsa_div_pop_mort$n_inc_pss_div_non_inc_scaled[1:17])
v_inc_pss_div_non_tot_pm_scaled <- round(df_incremental_twsa_div_pop_mort$n_inc_pss_div_non_tot_pm_scaled[1:17])

# Process outputs from TWSA analysis and add labels
df_twsa_div_pop_mort <- process_twsa_data(df_incremental_twsa_div_pop_mort)

df_twsa_pss_mort_oat_ret <- process_twsa_data(df_incremental_twsa_pss_mort_oat_ret)

x_label_vector_inc_div_odd <- create_odd_labels(v_inc_pss_div_non_inc_scaled)
x_label_vector_tot_pm_div_odd <- create_odd_labels(v_inc_pss_div_non_tot_pm_scaled)
y_label_vector_odd <- c("Rx-PSS", "", "", "", "Base", "", "", "", "Unreg Opioid")
x_label_vector_pss_mort_oat_ret <- c("Max Benefit", rep("", 7), "No Benefit")
y_label_vector_pss_mort_oat_ret <- c("Max Benefit", rep("", 7), "No Benefit")

# Generate plots
# Drug deaths
plot_twsa_div_pop_mort_odf <- twsa_heatmap_plot(
  data = df_twsa_div_pop_mort,
  fill_var = "n_inc_odf_scaled",
  x_labels = x_label_vector_inc_div_odd,
  y_labels = y_label_vector_odd,
  x_title = "Incident OUD cases resulting from PSS diversion (individuals)",
  y_title = "Mortality risk for individuals using diverted PSS"
)
ggsave(here("results","round_two","sensitivity_analyses",
            "sa1_otem_incremental_drug_deaths_individuals.png"))

plot_twsa_div_pop_mort_odf_tot_pm <- twsa_heatmap_plot(
  data = df_twsa_div_pop_mort,
  fill_var = "n_inc_odf_scaled",
  x_labels = x_label_vector_tot_pm_div_odd,
  y_labels = y_label_vector_odd,
  x_title = "Incident OUD cases resulting from PSS diversion (person-months)",
  y_title = "Mortality risk for individuals using diverted PSS"
)
ggsave(here("results","round_two","sensitivity_analyses",
            "sa1_otem_incremental_drug_deaths_person_months.png"))

plot_twsa_pss_mort_oat_ret_odf <- twsa_heatmap_plot(
  data = df_twsa_pss_mort_oat_ret,
  fill_var = "n_inc_odf_scaled",
  x_labels = x_label_vector_pss_mort_oat_ret,
  y_labels = y_label_vector_pss_mort_oat_ret,
  x_title = "PSS effect on OAT retention",
  y_title = "PSS effect on mortality"
)
ggsave(here("results","round_two","sensitivity_analyses",
            "sa2_otem_incremental_drug_deaths.png"))


# Overdoses
plot_twsa_div_pop_mort_overdoses <- twsa_heatmap_plot(
  data = df_twsa_div_pop_mort,
  fill_var = "incremental_overdoses_scaled",
  x_labels = x_label_vector_inc_div_odd,
  y_labels = y_label_vector_odd,
  x_title = "Incident OUD cases resulting from PSS diversion (individuals)",
  y_title = "Mortality risk for individuals using diverted PSS"
)
ggsave(here("results","round_two","sensitivity_analyses",
            "sa1_otem_incremental_overdoses_individuals.png"))

plot_twsa_div_pop_mort_overdoses_tot_pm <- twsa_heatmap_plot(
  data = df_twsa_div_pop_mort,
  fill_var = "incremental_overdoses_scaled",
  x_labels = x_label_vector_tot_pm_div_odd,
  y_labels = y_label_vector_odd,
  x_title = "Incident OUD cases resulting from PSS diversion (person-months)",
  y_title = "Mortality risk for individuals using diverted PSS"
)
ggsave(here("results","round_two","sensitivity_analyses",
            "sa1_otem_incremental_overdoses_person_months.png"))

plot_twsa_pss_mort_oat_ret_overdoses <- twsa_heatmap_plot(
  data = df_twsa_pss_mort_oat_ret,
  fill_var = "incremental_overdoses_scaled",
  x_labels = x_label_vector_pss_mort_oat_ret,
  y_labels = y_label_vector_pss_mort_oat_ret,
  x_title = "PSS effect on OAT retention",
  y_title = "PSS effect on mortality"
)
ggsave(here("results","round_two","sensitivity_analyses",
            "sa2_otem_incremental_overdoses.png"))
