# Load and Combine BCROM and OTEM Model Output Data

This function reads in CSV files containing output from the BCROM and
OTEM models, processes and combines the data into a single tibble. It
adds a `model` column to distinguish the data sources and constructs a
`date` column from the `year` and `month` columns.

## Usage

``` r
load_data(round = "one")
```

## Arguments

- round:

  character, either "one" or "two"

## Value

A tibble containing the combined data from the BCROM and OTEM models,
with an added `model` column and a parsed `date` column.

## Details

The function expects the files `BCROM_comparison_outputs.csv` and
`OTEM_comparison_outputs.csv` to be located in `data/raw/` relative to
the project root, as determined by the `here` package.

The following transformations are applied:

- The `...1` column is removed from the BCROM dataset if present.

- A `model` column is added with values `"bcrom"` or `"otem"`.

- A `date` column is constructed by combining `year` and `month` with a
  dummy day `"01"`.

## Examples

``` r
if (FALSE) { # \dontrun{
data <- load_data()
head(data)
} # }
```
