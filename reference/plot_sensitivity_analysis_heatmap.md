# Plot sensitivity analysis heatmaps

This function generates a heatmap visualization of sensitivity analysis
results, showing the impact of varying model parameters on total deaths
(or another outcome) for a given model. Positive values represent deaths
averted, while negative values represent deaths abetted. The heatmap
uses a diverging color scale (red white blue) with qualitative legend
labels for interpretability.

## Usage

``` r
plot_sensitivity_analysis_heatmap(
  result,
  sensitivity_analysis = "oat_ret",
  model_name = "otem",
  breaks = NULL
)
```

## Arguments

- result:

  A list containing sensitivity analysis outputs. Must include an
  element named according to `sensitivity_analysis` that contains:

  - `data`: A data frame with columns `model`, `x_scale`, `y_scale`, and
    `total_deaths`.

  - `x_label`, `y_label`: Character strings for axis labels.

  - `x_tick_labels`, `y_tick_labels`: Optional vectors of tick labels
    for the x and y axes.

- sensitivity_analysis:

  Character string specifying which sensitivity analysis result to use
  from `result`. Defaults to `"oat_ret"`.

- model_name:

  Character string specifying the model to plot within the sensitivity
  analysis data. Defaults to `"otem"`.

- breaks:

  Numeric vector of length 2 giving the minimum and maximum values for
  the color scale. If `NULL` (default), the limits are determined from
  the observed range of `category` (i.e., reversed total deaths).

## Value

A `ggplot` object representing the sensitivity analysis heatmap.

## Details

The function filters the sensitivity analysis data for the specified
model, reverses the sign of total deaths so that positive values
indicate deaths averted, and assigns integer indices for the x and y
positions. A diverging color gradient is used, centered at zero, with
red corresponding to abetted (negative) and blue corresponding to
averted (positive) values.

The legend includes qualitative labels ("Abetted -" and "Averted +")
along with the numeric range, aiding interpretation of model outcomes.

## See also

[`plot_model_difference_heatmap()`](https://sempwn.github.io/pss-model-comparison/reference/plot_model_difference_heatmap.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Example usage:
result <- list(
  oat_ret = list(
    data = data.frame(
      model = "otem",
      x_scale = rep(1:3, each = 3),
      y_scale = rep(1:3, 3),
      total_deaths = rnorm(9)
    ),
    x_label = "Parameter A",
    y_label = "Parameter B",
    x_tick_labels = c("Low", "Med", "High"),
    y_tick_labels = c("Low", "Med", "High")
  )
)

plot_sensitivity_analysis_heatmap(result)
} # }
```
