
<!-- README.md is generated from README.Rmd. Please edit that file -->

A lightweight R package for interfacing with the
[n3rgy](https://data.n3rgy.com/consumer/home) consumer API to access UK
smart meter electricity data.

Before using this package you will need to have followed the
instructions at the link above, providing n3rgy with the MPxN and MAC
numbers for your smart meter.

## Installation

``` r
install.packages("remotes")
remotes::install_github("odaniel1/n3Rgy")
```

## Example

Get information about your electricity tariff:

``` r
library(n3Rgy)
# Examples WILL NOT RUN without a valid MAC number
my_mac <- "<insert your MAC here>"

tariff <- n3rgy_tariff(my_mac, from = "2023-08-01", to = "2023-08-01")

tariff$standing_charge
```

    #>            timestamp standing_charge_p
    #> startDate 2023-08-01              56.7

``` r
head(tariff_example$price_per_kWh)
```

    #>             timestamp price_per_kWh_p
    #> 1 2023-08-01 00:00:00          31.053
    #> 2 2023-08-01 00:30:00          31.053
    #> 3 2023-08-01 01:00:00          31.053
    #> 4 2023-08-01 01:30:00          31.053
    #> 5 2023-08-01 02:00:00          31.053
    #> 6 2023-08-01 02:30:00          31.053

Or get your electricity consumption over time:

``` r
consumption <- n3rgy_consumption(my_mac, from = "2023-08-01", to = "2023-08-01")

library(ggplot2)

ggplot(consumption) +
  geom_col(aes(timestamp, consumption_kWh)) +
  theme_minimal()
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />
