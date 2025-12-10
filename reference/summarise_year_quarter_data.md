# Summarize model outputs by year and quarter

Aggregates quarterly model results (such as overdoses and deaths) across
simulations or parameter draws using the median and associated
uncertainty interval. This summary provides a concise quarterly view of
modeled outcomes from the output of
[`calculate_year_quarter_data()`](https://sempwn.github.io/pss-model-comparison/reference/calculate_year_quarter_data.md).

## Usage

``` r
summarise_year_quarter_data(year_quarter_data, digits = 3)
```

## Arguments

- year_quarter_data:

  A data frame or tibble returned by
  [`calculate_year_quarter_data()`](https://sempwn.github.io/pss-model-comparison/reference/calculate_year_quarter_data.md),
  containing simulated quarterly outcomes with columns such as
  `year_quarter`, `model`, `PSS overdoses`, `no PSS overdoses`,
  `PSS drug_deaths`, `no PSS drug_deaths`, and cumulative measures of
  deaths and overdoses averted.

## Value

A tibble summarizing median (and uncertainty) estimates for each model
and year-quarter combination. Includes the following columns:

- year_quarter:

  Year-quarter identifier (e.g., `"2024-Q2"`).

- model:

  Model name or identifier (e.g., `"BCROM"`, `"OTEM"`).

- PSS overdoses:

  Median and uncertainty interval for overdoses under the PSS scenario.

- no PSS overdoses:

  Median and uncertainty interval for overdoses under the counterfactual
  (no PSS) scenario.

- PSS drug_deaths:

  Median and uncertainty interval for overdose deaths under the PSS
  scenario.

- no PSS drug_deaths:

  Median and uncertainty interval for overdose deaths under the
  counterfactual (no PSS) scenario.

- cumulative deaths averted:

  Cumulative estimate of overdose deaths averted by PSS implementation.

- cumulative overdoses averted:

  Cumulative estimate of overdoses averted by PSS implementation.

A tibble with summarized quarterly model results.

## Details

The function groups results by `year_quarter` and `model`, applies
median with uncertainty to each column, and returns a subset of key
outcome variables for reporting or visualization.

## See also

[`calculate_year_quarter_data()`](https://sempwn.github.io/pss-model-comparison/reference/calculate_year_quarter_data.md)
