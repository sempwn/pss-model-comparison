# Plot cumulative deaths averted across models and runs

This function takes simulated model output and produces a line plot of
cumulative deaths averted over time. Deaths averted are calculated as
the difference between the number of drug-related deaths under a
counterfactual scenario with no PSS and the number of deaths under the
PSS intervention. The results are grouped by model and simulation run,
and cumulative sums are plotted as semi-transparent lines to visualize
uncertainty across runs.

## Usage

``` r
plot_deaths_averted_lines(model_data)
```

## Arguments

- model_data:

  A data frame containing model simulation output with the following
  required columns:

  - `date` — time variable (Date or numeric).

  - `no PSS drug_deaths` — number of deaths in the counterfactual
    scenario with no PSS intervention.

  - `PSS drug_deaths` — number of deaths in the PSS intervention
    scenario.

  - `model` — model identifier (factor or character).

  - `run` — simulation run identifier (numeric or character).

## Value

A `ggplot` object showing cumulative deaths averted over time,
stratified by model with multiple simulation runs shown as faint lines.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example model data (toy example)
df <- data.frame(
  date = rep(seq.Date(as.Date("2020-01-01"), by = "month", length.out = 12), 2),
  `no PSS drug_deaths` = rpois(24, 10),
  `PSS drug_deaths` = rpois(24, 7),
  model = rep(c("Model A", "Model B"), each = 12),
  run = rep(1:2, each = 12)
)

plot_deaths_averted_lines(df)
} # }
```
