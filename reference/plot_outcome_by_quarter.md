# Plot Outcome by Year-Quarter and Model

Creates a boxplot of a specified outcome variable by `year_quarter`,
grouped and colored by `model`. This is useful for comparing outcomes
(e.g., overdose deaths) across different models over time.

## Usage

``` r
plot_outcome_by_quarter(plot_data, outcome = "PSS drug_deaths")
```

## Arguments

- plot_data:

  A data frame containing at least the columns `year_quarter`, the
  specified `outcome`, and `model`. The `year_quarter` column should be
  a factor or character indicating time periods, and `model` should
  specify the model group.

- outcome:

  A character string specifying the name of the outcome column in
  `plot_data` to be plotted. Defaults to `"PSS drug_deaths"`.

## Value

A `ggplot2` object representing the boxplot of the specified outcome by
`year_quarter` and `model`.

## Examples

``` r
if (FALSE) { # \dontrun{
plot_data <- data.frame(
  year_quarter = rep(c("2020 Q1", "2020 Q2"), each = 10),
  model = rep(c("Model A", "Model B"), times = 10),
  `PSS drug_deaths` = rpois(20, 10)
)
plot_outcome_by_quarter(plot_data)
} # }
```
