# Plot Model Difference Heatmap

Creates a bivariate heatmap comparing the difference in total deaths
between two models ("OTEM" and "BCROM"), including a custom legend laid
out as a 3x3 grid.

## Usage

``` r
plot_model_difference_heatmap(
  result,
  sensitivity_analysis = "oat_ret",
  breaks = NULL
)
```

## Arguments

- result:

  A list containing OAT results with `x_label`, `y_label`,
  `x_tick_labels`, `y_tick_labels`, and `data`.

- sensitivity_analysis:

  Optional name of the element within `result` containing OAT results.
  Can be either `"pop_mort"` or `"oat_ret"` Defaults to `"oat_ret"`.

- breaks:

  vector of length 4 to define small, medium, and large categories,
  default is `NULL`

## Value

A patchwork object combining the main heatmap and custom legend.
