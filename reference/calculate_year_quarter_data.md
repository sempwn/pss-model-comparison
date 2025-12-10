# Summarize Model Data by Year-Quarter

Filters, groups, and summarizes model output data by year-quarter,
model, and run.

## Usage

``` r
calculate_year_quarter_data(model_data)
```

## Arguments

- model_data:

  A data frame containing model output. Must include columns:

  - `date`: a Date object,

  - `year_quarter`: a grouping variable (e.g., "2021 Q2"),

  - `model`: model identifier,

  - `run`: simulation run identifier, along with numeric variables to be
    summarized.

## Value

A grouped and summarized tibble with one row per combination of
`year_quarter`, `model`, and `run`. All non-Date columns are summed.
`year_quarter` is returned as a factor.

## Details

This function takes a data frame of model output, filters out dates
before March 1, 2020, groups the data by `year_quarter`, `model`, and
`run`, then sums all numeric (non-Date) columns within those groups. The
`year_quarter` variable is converted to a factor.

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_year_quarter_data(model_data)
} # }
```
