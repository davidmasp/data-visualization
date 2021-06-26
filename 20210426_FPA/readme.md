# Distribution of the causes of fires throughout the year :fire:

Distribution of the day of detection of ~1M fires in the US throughout the year. Stratified for some selected causes. High values represent seasons where many fires of a particular type were detected. The firework fires for instance show a sharp accumulation in the vicinity of the 4th of July.

The shaded (in color) area represents the mode of that specific distribution
and 35% of the instances to the left and to the right. The colored zone is thus
"centered" on the mode. Although in some cases the value should go to December
as the day of the year should be more like a cycle this is not possible with my
current implementation. I also thought it would be hard to read.

## Quick links:
* [Data from kaggle](https://www.kaggle.com/rtatman/188-million-us-wildfires)
* [Code in github](https://github.com/davidmasp/data-visualization/tree/master/20210426_FPA)
* [Get the NFT of this vizz at hic et nunc](https://www.hicetnunc.xyz/objkt/152393)

## Data

The raw data contains 1.88 Million US Wildfires reported by
Fire Program Analysis (FPA) system. They span from 1992 to 2015
and are classified by location, cause and other metrics.

* It is accessible in [kaggle](https://www.kaggle.com/rtatman/188-million-us-wildfires)
* The format of the data is [`sqlite`](https://www.sqlite.org/index.html).

```
kaggle datasets download -d rtatman/188-million-us-wildfires
```

The version of the data that I used can be verified using this:

```R
> tools::md5sum(files = "data/FPA_FOD_20170508.sqlite")
      data/FPA_FOD_20170508.sqlite 
"568e679d022f6df0dc1d23a139cdc2ce"
```
