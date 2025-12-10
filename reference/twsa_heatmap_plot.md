# Create a Sensitivity Analysis heatmap plot

Generates a heatmap for Tornado-Waterfall Sensitivity Analysis (TWSA)
results, visualizing changes in outcomes across a 2D parameter space.
The fill colour represents the specified variable, and labels are added
for each grid cell.

## Usage

``` r
twsa_heatmap_plot(data, fill_var, x_labels, y_labels, x_title, y_title)
```

## Arguments

- data:

  A data frame containing TWSA results, with columns `x_scale`,
  `y_scale`, and the variable specified by `fill_var`.

- fill_var:

  A string giving the name of the column in `data` to use for the fill
  colour.

- x_labels:

  A character vector of labels to display along the x-axis.

- y_labels:

  A character vector of labels to display along the y-axis.

- x_title:

  A string specifying the x-axis title.

- y_title:

  A string specifying the y-axis title.

## Value

A `ggplot` object representing the TWSA heatmap plot.

## Details

The colour scale is symmetric around zero and uses a diverging palette
to distinguish between positive and negative values. The legend labels
correspond to "Favours PSS", "Scenarios equal", and "Favours
counterfactual".

## Examples

``` r
if (FALSE) { # \dontrun{
plot <- twsa_heatmap_plot(my_data, "incremental_overdoses_scaled",
  x_labels = seq(-1, 1, 0.25),
  y_labels = seq(-1, 1, 0.25),
  x_title = "Parameter X",
  y_title = "Parameter Y"
)
print(plot)
} # }
```
