# summarise deaths averted

summarise deaths averted

## Usage

``` r
summarise_events_averted(model_data, event = "deaths", digits = 2)
```

## Arguments

- model_data:

  output of
  [`load_data()`](https://sempwn.github.io/pss-model-comparison/reference/load_data.md)

- event:

  Either `"deaths"` or `"overdoses"`. Default is `"deaths"`

- digits:

  number of significant digits

## Value

[`dplyr::tibble()`](https://dplyr.tidyverse.org/reference/reexports.html)
