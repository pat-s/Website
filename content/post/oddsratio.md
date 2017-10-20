---
date: 2016-11-01T16:30:23+01:00
image: oddsratio3.png
lastmod: 2016-11-01
math: false
summary: Usually, this calculation is done by setting all predictors to their mean
  value, predict the response, change the desired predictor to a new value and predict
  the response again. These actions results in two log odds values, respectively,
  which are transformed into odds by exponentiating them. Finally, the odds ratio
  can be calculated from these two odds values.
tags: 
- logistic regression
- oddsratio
- r-bloggers
title: Introducing R Package 'oddsratio'
---

You are dealing with statistical models (GLMs or GAMs) with a binomial response variable? Then the `oddsratio` package will improve your analysis routine!

This package simplifies the calculation of odds ratios in binomial models. For GAMs, it also provides you with the power to insert your results into the smooth functions of your predictors! But let's start with some basics...

*- This post refers to package version 0.3.0 -*

# GLM

## The concept of odds ratio calculation

The standard approach to calculate odds ratios in Generalized Linear Models (GLMs) is to exponentiate the function coefficients using `exp(coef(model))`. Since the coefficients are returned in log odds, exponentiating converts them to odds. But wait! We want odds ratios showing the change in odds for a specific predictor change! Usually you just create a vector which stores the increments of your predictors you want to calculate odds ratios for. Next, you have to remove the first value of the `coef` output (which is usually the intercept) because you only want to calculate odds ratios for your predictors! Then you multiply the coefficients with your increment values.

But wait again!? How do we get a ratio ('odds ratio') by multiplying two values? Well, this is a mathematical thing. Behind the scences you are doing a `exp()`call on a substraction of log odds: `log odds1 - log odds2` where `log odds1` is just "one unit" (+1) larger than `log odds2`. This difference is your coefficient. Applying `exp()` on a substraction results in a division. Subsequently, the result is a ratio of `odds1` by `odds2`. If you then set an increment value to multiply your coefficient with, this "one unit increase/difference" (+1) is multiplied by this value and then `exp()` is applied on it. This means that if you set an increment value of `5`, the "new" coefficient (corresponding to a change of `5`) is simply five times the coefficients of `1` (which was returned by your model summary).

If your predictor is not numeric but an indicator variable with certain levels (like `rank` in the example), it does not make sense to set increments since the calculated coefficients just refer to your base factor level, here being `rank1`. In practice this makes sense because you can just say "being `rank1` increases/decreases the odds of the event to happen by x % compared to `rank2`. So you just set the increment to `1` to calculate the basic odds ratio between the respective levels. Note that you need to set as much "1s" as there are levels of your indicator variable!

All these steps result in the following code:

```{r}
# Example data
dat <- read.csv("http://www.ats.ucla.edu/stat/data/binary.csv")
dat$rank <- factor(dat$rank)
fit.glm <- glm(admit ~ gre + gpa + rank, data = dat, family = "binomial")

incr <- c(100, 2, 1, 1, 1)
exp(coef(fit.glm)[-1] * incr)
```

```bash
gre       gpa       rank2     rank3     rank4 
1.2541306 4.9931906 0.5089310 0.2617923 0.2119375
```


Here, the increments of our numeric predictors are `100` and `2`. The annoying part of this approach is that you have to specify as many "1s" as there are levels of your indicator variable - and you have to take care not to misplace the parentheses in the `exp()` call! Other possible errors might be to miss the `[-1]` for the intercept or increment/predictor misplacement within the `incr` vector.
And yes, this was just the 'easy' procedure for GLMs - the GAM approach is way more extensive.

## The 'oddsratio' approach

All what was shown before can be done better - in my opinion!

```{r}
library(oddsratio)
suppressMessages(library(cowplot)) # for plot theme

calc.oddsratio.glm(data = dat, model = fit.glm, incr = list(gre = 100, gpa = 2))
```

```bash
  predictor oddsratio CI.low (2.5 %) CI.high (97.5 %)          increment
1       gre     1.254          1.014            1.558                100
2       gpa     4.993          1.378           18.696                  2
3     rank2     0.509          0.272            0.945 Indicator variable
4     rank3     0.262          0.132            0.512 Indicator variable
5     rank4     0.212          0.091            0.471 Indicator variable
```


Note how the column names of `CI.low` and `CI.high` are automatically adjusted.

By using `calc.oddsratio.glm()` you get a nicely formatted output. When setting up the function arguments you avoid false references of increments by providing the information in a named list (`gre = 100`, `gpa = 2`). Also, automatically confident intervals (CI) of odds ratios are calculated and returned. So you can directly see how "safe" your odds ratio calculation is based on the underlying fitted model for the specific predictor.

For GLMs the default CI is 95%, i.e. the lower border is 2.5% and the upper one is 97.5%. You can easily specify your own CI using the `CI` argument:


```{r}
calc.oddsratio.glm(data = dat, model = fit.glm, 
                   incr = list(gre = 100, gpa = 2), CI = .70)
```

```bash
  predictor oddsratio CI.low (15 %) CI.high (85 %)          increment
1       gre     1.254         1.120          1.406                100
2       gpa     4.993         2.520          9.984                  2
3     rank2     0.509         0.366          0.706 Indicator variable
4     rank3     0.262         0.183          0.374 Indicator variable
5     rank4     0.212         0.136          0.325 Indicator variable
```

# GAM

For Generalized Additive Models (GAMs) the odds ratio calculation is done different. Due to the non-linear behavior of this model type, odds ratios of specific increment steps are different for every value combination and not constant throughout the value range of each predictor as for GLMs. For example, the odds ratio of two arbitrary values `3` and `10` with their difference of `7` is different to the odds ratio of `22` and `29`. This is based on the different coefficient slopes of GAMs between these two value combinations (non-linear!). For GLMs, the slope would be the same ('linear') and hence also the odds ratios.

Let's show some examples! (Data source: <a href="https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/predict.gam.html">?mgcv::predict.gam</a>)

```{r}
suppressPackageStartupMessages(library(mgcv))
set.seed(1234)
n <- 200
sig <- 2
dat <- gamSim(1, n = n,scale = sig, verbose = FALSE)
dat$x4 <- as.factor(c(rep("A", 50), rep("B", 50), rep("C", 50), rep("D", 50)))
fit.gam <- mgcv::gam(y ~ s(x0) + s(I(x1^2)) + s(x2) + offset(x3) + x4, data = dat)
```

Calculating odds ratios for GAMs is somewhat exhausting and more 'complicated' as for GLMs for which you just call `exp(coef(model))`. For GAMs, you can only calculate the odds ratio of one predictor at a time. First, you call `predict()` with your starting value, let's call it `value1`. Next, you do the same again, now using `value2` of your predictor. You can either call predict on only one observation or on all if you fix all other values! The logic is that you call `predict()` on your prediction data for which the only difference between the two calls is your change from `value1` to `value2` of your predictor while all other values stay the same.

After that, you have your two log odds coefficients corresponding to your specific value change of your chosen predictor. Next, you can call `exp()` on this substraction (`value2` - `value1`) to receive your odds ratio value (as it is done for GLMs).

If you do not understand this theory in depth, do not worry - `calc.oddsratio.gam()` does the work for you! What counts in the first place is to be able to correctly interpret the odds ratios.

```{r}
calc.oddsratio.gam(data = dat, model = fit.gam, pred = "x2", 
                   values = c(0.099, 0.198))
```

```bash
  predictor value1 value2 oddsratio CI.low (2.5%) CI.high (97.5%)
1        x2  0.099  0.198  50.34194      52.87883        47.92677
```

Using `calc.oddsratio.gam()` you just specify your fitted model and your predictor, provide your values to calculate the odds ratio for and you receive your result!

"Hmmm - so I have to call the function x times if I want multiple odds ratios of the same predictor?"
Well, actually yes - but that is the moment when the `slice` comes to stage!

`calc.oddsratio.gam()` supports the calculation of multiple odds ratios for one predictor using `slice = TRUE`. This option splits the value range of the predictor by percentage steps (specified in the `percentage` argument). So if you want, for example, to calculate odds ratios for 20% quantiles of your predictors value range, you proceed as follows:

```{r}
calc.oddsratio.gam(data = dat, model = fit.gam, pred = "x2", 
                   percentage = 20, slice = TRUE)
```

``` bash
  predictor value1 value2 perc1 perc2 oddsratio CI.low (2.5%) CI.high (97.5%)
1        x2  0.017  0.212     0    20   3254.67       1801.96         5878.52
2        x2  0.212  0.408    20    40      0.02          0.01            0.02
3        x2  0.408  0.604    40    60      0.24          0.27            0.22
4        x2  0.604  0.800    60    80      0.12          0.11            0.13
5        x2  0.800  0.995    80   100      0.09          0.17            0.05
```

You get the values which were taken for the odds ratio calculation (`value1`, `value2`), which percentage of the predictor distribution they correspond to (`perc1`, `perc2`), the calculate odds ratio and its confident interval borders.

*Note that in package version 0.3.0 the CI of GAMs is fixed to 95% and cannot be modified.*

## Plot GAM(M) smoothing functions

Right now, the only (quick) possibility to plot the smoothing functions of a GAM(M) in R was by using the built-in `plot()` function. Since I prefer using `ggplot2` for all kind of plotting, I implemented the somehow fiddly procedure of plotting GAM smoothing functions using `ggplot()` in `pl.smooth.gam()`:

```{r}
pl.smooth.gam(fit.gam, pred = "x2", title = "Predictor 'x2'")
```

{{< figure src="/img/oddsratio1.png" title="Example plot of a GAM smooth function using `ggplot2`" >}}

## Add odds ratio information into smoothing function plot

So now, we have the odds ratios and we have a plot of the smoothing function. Why not combine both? We can do so using `add.oddsratio.into.plot()`! Its main arguments are (i) a `ggplot` plotting object containing the smooth function (from `pl.smooth.gam()`) and a data frame returned from `calc.oddsratio.gam()` containing information about the predictor and the respective values we want to insert.

```{r}
plot.object <- pl.smooth.gam(fit.gam, pred = "x2", title = "Predictor 'x2'")
or.object1 <- calc.oddsratio.gam(data = dat, model = fit.gam, pred = "x2", 
                                 values = c(0.099, 0.198))
                               
# insert first odds ratios into plot
plot.object <- add.oddsratio.into.plot(plot.object, or.object1, or.yloc = 3,
                                       values.xloc = 0.04, line.size = 0.5, 
                                       line.type = "dotdash", text.size = 6,
                                       values.yloc = 0.5, arrow.col = "red")
```

{{< figure src="/img/oddsratio2.png" title="GAM smoothing function with inserted odds ratio information" >}}

The odds ratio information is always centered between the two vertical lines. Hence it only looks nice if the gap between the two chosen values (here `0.099` and `0.198`) is large enough. If the smoothing line crosses your inserted text, you can correct it by adjusting `or.yloc`. This argument sets the y-location of the inserted odds ratio information. Depending on the number of digits of your chosen values (here 3), you might also need to adjust the x-axis location of the two values so that these do not interfer with the vertical line.

Let's add another odds ratio into this plot! This time we simply take the already produced plot as an input to `add.oddsratio.into.plot()` and use a new odds ratio object:

```{r}
or.object2 <- calc.oddsratio.gam(data = dat, model = fit.gam, pred = "x2", 
                                 values = c(0.4, 0.6))
                                  
# add or.object2 into plot                                  
add.oddsratio.into.plot(plot.object, or.object2, or.yloc = 2.1, values.yloc = 2,
                        line.col = "green4", text.col = "black",
                        rect.col = "green4", rect.alpha = 0.2,
                        line.alpha = 1, line.type = "dashed",
                        arrow.xloc.r = 0.01, arrow.xloc.l = -0.01,
                        arrow.length = 0.01, rect = TRUE)  
```

{{< figure src="/img/oddsratio3.png" title="GAM smoothing function with information on two odds ratio intervals" >}}


Quite some adjustments were made for this insertion: I adjusted `values.yloc` because we have only one digit this time. Also, `or.yloc` was set to a lower value than in the first example to avoid an interference with the smoothing function. A green shaded rectangle was added using `rect = TRUE` and I set the arrow color to `black`. Length and position of the arrows very slightly modified using `arrow.length`, `arrow.xloc.r` and `arrow.xloc.l`. If you do not like arrows, simply turn them off using `arrow = FALSE`. The same logic applies to the shaded rectangle `rect = FALSE` and the inserted values `values = FALSE`. 

# Installation

You can install the package from CRAN by

```{r, eval = FALSE}
install.packages("oddsratio")
```

or from Github using

```{r, eval = FALSE}
devtools::install_github("pat-s/oddsratio", build_vignettes = TRUE)
```

