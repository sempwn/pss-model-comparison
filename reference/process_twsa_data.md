# Process data for sensitivity analysis plotting

Takes a TWSA result object and formats it into a tibble with `x_scale`
and `y_scale` coordinates covering a full square grid from -1 to 1,
suitable for plotting with
[`twsa_heatmap_plot()`](https://sempwn.github.io/pss-model-comparison/reference/twsa_heatmap_plot.md).

## Usage

``` r
process_twsa_data(data_obj)
```

## Arguments

- data_obj:

  A data frame or matrix containing TWSA result values, with columns
  `n_inc_odf_scaled` and `n_inc_odn_scaled`.

## Value

A tibble with columns:

- `x_scale` — numeric x-coordinate for the grid

- `y_scale` — numeric y-coordinate for the grid

- `n_inc_odf_scaled` — scaled incremental overdoses (ODF)

- `n_inc_odn_scaled` — scaled incremental overdoses (ODN)

- `incremental_overdoses_scaled` — total scaled incremental overdoses

## Details

The function generates a 17x17 grid (289 points) for plotting,
corresponding to combinations of x and y scaling factors from -1 to 1.
The column `incremental_overdoses_scaled` is computed as the sum of
`n_inc_odf_scaled` and `n_inc_odn_scaled`.

## Examples

``` r
if (FALSE) { # \dontrun{
processed <- process_twsa_data(my_results)
head(processed)
} # }
```
