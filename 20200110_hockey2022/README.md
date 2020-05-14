
# Hockey 2022

The correlation of the Ice Hockey qualification points for the winter
olympics 2022 in Beijin and the mean year temperature of the country.

As expected, the correlation is negative, meaning that colder countries
perform best. However I would say that there is a bit of the Simpson
paradox in some groups.

## Data sources

  - [Hockey 2022](https://en.wikipedia.org/wiki/Ice_hockey_at_the_2022_Winter_Olympics_%E2%80%93_Men%27s_qualification)
  - [Temperatures](https://en.wikipedia.org/wiki/List_of_countries_by_average_yearly_temperature)

## Usage

Note: You need an enviromental variable that defines the source of the
data to this
[file](https://docs.google.com/spreadsheets/d/1z2n1Et35uw7suynGf9IYMB_gBXRdR3hQ5lnC03IdVgo).

``` r
source("script.R")
```

    ## Finding R package dependencies ... Done!
    ## Finding R package dependencies ... Done!
    ## Finding R package dependencies ... Done!
    ## Finding R package dependencies ... Done!

![](correlation_plot.png)
