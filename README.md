
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ialiquor

<!-- badges: start -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub
commit](https://img.shields.io/github/last-commit/nikdata/ialiquor)](https://github.com/nikdata/ialiquor/commit/main)
<!-- badges: end -->

The **{ialiquor}** package provides a summary of the monthly liquor
sales by county and by liquor type in the State of Iowa. This dataset
comes from the Iowa Data Portal and is limited to beverages classified
as [Class E](https://abd.iowa.gov/license-classifications). Class E
beverages (as according to Iowa) are:

> For grocery, liquor and convenience stores, etc. Allows for the sale
> of alcoholic liquor for off-premises consumption in original unopened
> containers. No sales by the drink. Sunday sales are included. Also
> allows wholesale sales to on-premises Class A, B, C and D liquor
> licensees but must have a TTB Federal Wholesale Basic Permit.

In other words, this dataset is limited to retailers that are
essentially selling “hard” liquor. This does not include data for beer
sales (which is a Class C license) or wine (which is a Class B license).

In Iowa, the state will purchase alcohol from vendors and then resell
the alcohol to retailers within the state. As such, there is a ‘cost’
that the state pays to the vendor and then there is ‘revenue’ to the
state based on the price sold to the retailer. It is important to keep
in mind that these revenue values are not indicative of the actual sale
price to the end customer.

**WIP**

## Installation

This package is not available on CRAN, but can be installed from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("nikdata/ialiquor", ref = "main")
```

## Usage

The {ialiquor} package provides a monthly summary (from January 2015 to
October 2020) of the alcohol (class E) sales in the State of Iowa.
Several attributes are available in the dataset such as county, county
population, the type (derived by me) of alcohol, the category of the
alcohol (as defined by the State of Iowa). Furthermore, numerical
summaries are available for cost, revenue, bottles sold, and volume.

### Preview of Liquor Sales

``` r
library(ialiquor)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
data('liquor_sales')

dplyr::glimpse(liquor_sales)
#> Rows: 280,736
#> Columns: 10
#> $ year          <dbl> 2015, 2015, 2015, 2015, 2015, 2015, 2015, 2015, 2015, 2…
#> $ year_month    <dttm> 2015-01-01, 2015-01-01, 2015-01-01, 2015-01-01, 2015-0…
#> $ county        <chr> "adair", "adair", "adair", "adair", "adair", "adair", "…
#> $ population    <dbl> 7145, 7145, 7145, 7145, 7145, 7145, 7145, 7145, 7145, 7…
#> $ type          <chr> "vodka", "other", "liqueur", "cocktail", "liqueur", "gi…
#> $ category      <chr> "100 proof vodka", "american alcohol", "american amaret…
#> $ state_cost    <dbl> 253.62, 54.00, 88.98, 182.40, 346.29, 99.57, 257.72, 31…
#> $ state_revenue <dbl> 380.70, 81.00, 133.50, 277.10, 519.45, 149.38, 388.12, …
#> $ bottles_sold  <dbl> 54, 6, 18, 26, 36, 24, 47, 5, 18, 36, 92, 633, 60, 25, …
#> $ volume        <dbl> 58.50, 4.50, 19.50, 45.50, 27.00, 15.00, 34.00, 3.75, 1…
```

### Potential Use Cases

  - Revenue by type
  - Total revenue per bottle to state by year
  - Total volume sold per person by year
