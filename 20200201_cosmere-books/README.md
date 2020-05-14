
## The Cosmere - Book Length Viz

The [Cosmere](https://coppermind.net/wiki/Cosmere) is a epic fantasy
fictional universe designed by the author [Brandon
Sanderson](https://www.brandonsanderson.com/).

The author has revelead that he plans to write more than [40
novels](https://www.reddit.com/r/Stormlight_Archive/comments/5j8bkb/no_spoilersstate_of_the_sanderson_2016/dbgizmb/).
Currently only [23](https://coppermind.net/wiki/Cosmere) books are
published.

## Visualisation

In this visualization I want to represent reading time for each of the
books plus total number of words (which is the same thing) but grouped
for each independent Series.

There’s also some standalone categories for the books that are not part
of any saga yet.

## Data

I gathered the data mainly from [here]() but also other sources.

All the data is available in this public
[gsheet](https://docs.google.com/spreadsheets/d/1vi3ZIA-aka0meB8rOLKByZWHnci1ow2kQ0eez35E_T4/edit?usp=sharing)
document.

## Usage

To use, just run inside R:

``` r
source("script.R")
```

![](figures/figurecosmere-1.png)<!-- -->

<details>

<summary>You will need to install the following
<bold>dependencies</bold> first:</summary> <br>

  - curl
  - dplyr
  - forcats
  - fs
  - ggplot2
  - glue
  - magrittr
  - patchwork
  - purrr
  - scales
  - vroom

</details>
