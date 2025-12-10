# Create labels for odd-indexed elements

Produces a vector of labels using only the odd-indexed elements from the
provided vector, optionally replacing the first label with a base-case
label containing its value.

## Usage

``` r
create_odd_labels(vector, base_label = "Base")
```

## Arguments

- vector:

  A character or numeric vector from which labels will be created.

- base_label:

  A string giving the label to use for the first element, with its value
  in parentheses. Defaults to `"Base"`.

## Value

A character vector containing labels for odd-indexed elements of
`vector`.

## Examples

``` r
create_odd_labels(seq(1, 9))
#> [1] "Base (1)" "3"        "5"        "7"        "9"       
create_odd_labels(seq(1, 9), base_label = "Reference")
#> [1] "Reference (1)" "3"             "5"             "7"            
#> [5] "9"            
```
