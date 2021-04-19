Recreational Fishing Trends in North Carolina (1990-2019)
========================================================
author: Ardath Dixon, Annie Harshbarger, Eva May
date: Spring 2021
autosize: true

<img src="./BlackSeaBass.jpg" title="plot of chunk title page" alt="plot of chunk title page" width="45%" style="display: block; margin: auto 0 auto auto;" />

First Slide
========================================================

Overall description

- What the data is
- Where we got it
- What we hope to show

Slide With Code
========================================================


 



```r
head(fish.tidy)
```

```
# A tibble: 6 x 6
  DATE       MONTH  YEAR MODE_FX AREA_X TOT_CAT
  <date>     <chr> <dbl>   <dbl>  <dbl>   <dbl>
1 1990-01-01 Jan    1990       3      1 203578.
2 1990-01-01 Jan    1990       3      1   9693.
3 1990-01-01 Jan    1990       3      1   3987.
4 1990-01-01 Jan    1990       7      5 153212.
5 1990-01-01 Jan    1990       7      1  82510.
6 1990-01-01 Jan    1990       7      1  25388.
```

Total Catch 1990-2019
========================================================


![plot of chunk ggplot](FinalPresentation-figure/ggplot-1.png)

Time Series Trends - All Fish
========================================================

![plot of chunk unnamed-chunk-4](FinalPresentation-figure/unnamed-chunk-4-1.png)

Time Series Trends - Bluefish
========================================================

![plot of chunk unnamed-chunk-5](FinalPresentation-figure/unnamed-chunk-5-1.png)

Time Series Trends - Black Sea Bass
========================================================

![plot of chunk unnamed-chunk-6](FinalPresentation-figure/unnamed-chunk-6-1.png)

Slide with Statistics
========================================================


```
tau = 0.49, 2-sided pvalue =< 2.22e-16
```

Forecasting
========================================================

![plot of chunk unnamed-chunk-8](FinalPresentation-figure/unnamed-chunk-8-1.png)

Discussion
========================================================
Text of why stuff happened.
