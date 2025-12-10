# Load and combine sensitivity analysis data from OTEM and BCROM models

This function loads sensitivity analysis data from two modeling
frameworks (OTEM and BCROM), standardizes variable names, and merges
them into a unified structure with corresponding axis labels for
plotting or further analysis.

## Usage

``` r
load_sensitivity_analysis_data()
```

## Value

A named list of sensitivity analysis results, where each element is
itself a list containing:

- data:

  A combined tibble with OTEM and BCROM results, including columns
  `x_scale`, `y_scale`, `total_deaths`, and `model`.

- x_label:

  A character string describing the x-axis label for the scenario.

- y_label:

  A character string describing the y-axis label for the scenario.

The list is keyed by scenario identifiers (e.g., `"pop_mort"`,
`"oat_ret"`).

## Details

The function ensures that both OTEM and BCROM provide matching
sensitivity data tables for each scenario. It attaches appropriate x and
y axis labels to each dataset for downstream use in figures or reports.
