# calculate deaths and overdoses averted

calculate deaths and overdoses averted

## Usage

``` r
add_averted_columns(model_data)
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

tibble
