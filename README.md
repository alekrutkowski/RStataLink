# RStataLink -- R package for calling Stata from R interactively
Aleksander Rutkowski  
`r format(Sys.Date(), "%d %B %Y")`  

## Features

Execute smaller or larger bits and pieces of Stata code **interactively** from R 
in a [Stata](http://www.stata.com/) "server" i.e. not in a batch mode:

- avoid repeated costly operations, e.g. open Stata and load data in Stata **only once**
and do subsequent operations requiring R<->Stata interaction without
re-opening and re-loading
- easy R<->Stata **data exchange** (import/export)
- easy Stata r() and e() **"results" extraction** (macros, scalars, matrices, coefficients
and standard errors), shaped for convenient consumption in R
- **concurrency** "primitive" ([future](https://en.wikipedia.org/wiki/Futures_and_promises)-like)
and parallel `apply()`-style functions for executing Stata code in a concurrent/parallel
manner in a "cluster" of multiple Stata instances (regular and load-balancing versions)
- should work **cross-platform** -- pure R and pure Stata code (but developed and tested on
MS Windows only)

Make your work with Stata more
[functional](https://en.wikipedia.org/wiki/Functional_programming)!

Similar but unrelated project: <https://github.com/lbraglia/RStata>. It seems
to offer only batch mode i.e. not interactive.

## How it works

Stata "server" is a Stata instance running an infinite loop and waiting for new jobs
showing up in a specific directory/folder. Thus, the R<->Stata communication is
disk-based so it can take place only locally (within a single computer) or through a
shared network drive (across computers).

In the latter case (the shared drive approach), Stata would still need to be
opened by R with `startStata()` or `startStataCluster()` on the "server" computer
(e.g. via SSH). The generated `StataID` object(s) (see `i` or `cl`
below) need(s) to be serialised (e.g. with `saveRDS()`) and transmitted in some way
to a remote "client" computer to be deserialised (e.g. with `readRDS()`).
The entire path to the shared network drive directory (see argument `compath` in
`startStata()`) should be the same on both computers ("server" and "client").

## Installation


```r
if ('devtools' %in% installed.packages()[,"Package"])
	devtools::install_github('alekrutkowski/RStataLink') else
	stop('You need package "devtools"!')
```

## Usage examples

Tell R where Stata is (can be also per-call -- using argument `start_cmd` in `startStata()` --
but that would be less convenient):


```r
# A virtualised app in my case, therefore such a complicated path, should be simpler normally:
options(statapath=paste('"C:\\Program Files (x86)\\Microsoft Application Virtualization Client\\sfttray.exe"',
                        '/launch "StataMP 14 (64-bit) [V] 14.0bd001"'))
```

### A single Stata instance functionality demo

For the Stata code pieces use a string with a newline
character (\\n), or multi-line string, or a character vector (that will be converted to a
multi-line string):


```r
library(RStataLink)
i <- startStata()
```

```
##      Stata "server" started successfully.
```

```r
i
```

```
##      StataID object:
##      
##       Stata "server" id:
##       Yy7 
##       (you can see it in the top of the Stata window)
##      
##       Full path to the Stata "server" <--> R
##       data exchange directory (folder):
##       C:\Users\rutkoal\AppData\Local\Temp\1\RtmpyER5em/Yy7 
##      
##       Should Stata close if this directory disappears:
##       no
```

```r
r1 <- doInStata(i, 'display 100 + 15.7', results = NULL)
r1  # results = NULL means no import of Stata e() or r() results
```

```
##      $log
##      . display 100 + 15.7
##      115.7
```

```r
# Use in Stata a built-in demo dataset on cars
# and make a simple regression with robust standard errors
# (the 3 lines of code could be also done with 3 consecutive doInStata calls)
r2 <- doInStata(i,
				'sysuse auto, clear
				regress price weight trunk, robust
				ereturn list')
r2$log
```

```
##      . sysuse auto, clear
##      (1978 Automobile Data)
##      
##      .                                 regress price weight trunk, robust
##      
##      Linear regression                               Number of obs     =         74
##                                                      F(2, 71)          =      16.69
##                                                      Prob > F          =     0.0000
##                                                      R-squared         =     0.2943
##                                                      Root MSE          =     2512.5
##      
##      ------------------------------------------------------------------------------
##                   |               Robust
##             price |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
##      -------------+----------------------------------------------------------------
##            weight |   2.266182   .6227162     3.64   0.001     1.024521    3.507842
##             trunk |  -60.03885   88.23694    -0.68   0.498    -235.9783    115.9006
##             _cons |   148.5533   947.5387     0.16   0.876    -1740.785    2037.892
##      ------------------------------------------------------------------------------
##      
##      .                                 ereturn list
##      
##      scalars:
##                        e(N) =  74
##                     e(df_m) =  2
##                     e(df_r) =  71
##                        e(F) =  16.69201624215745
##                       e(r2) =  .2942577843486112
##                     e(rmse) =  2512.482807011177
##                      e(mss) =  186872936.3792214
##                      e(rss) =  448192459.7424002
##                     e(r2_a) =  .2743777219358961
##                       e(ll) =  -682.8181749520038
##                     e(ll_0) =  -695.7128688987767
##                     e(rank) =  3
##      
##      macros:
##                  e(cmdline) : "regress price weight trunk, robust"
##                    e(title) : "Linear regression"
##                e(marginsok) : "XB default"
##                      e(vce) : "robust"
##                   e(depvar) : "price"
##                      e(cmd) : "regress"
##               e(properties) : "b V"
##                  e(predict) : "regres_p"
##                    e(model) : "ols"
##                e(estat_cmd) : "regress_estat"
##                  e(vcetype) : "Robust"
##      
##      matrices:
##                        e(b) :  1 x 3
##                        e(V) :  3 x 3
##             e(V_modelbased) :  3 x 3
##      
##      functions:
##                   e(sample)
```

```r
r2$results  # this (below) looks similar to "ereturn list" in Stata (above)
```

```
##      $e_class
##      List of 4
##       $ scalars :List of 12
##        ..$ N   : num 74
##        ..$ df_m: num 2
##        ..$ df_r: num 71
##        ..$ F   : num 16.7
##        ..$ r2  : num 0.294
##        ..$ rmse: num 2512
##        ..$ mss : num 1.87e+08
##        ..$ rss : num 4.48e+08
##        ..$ r2_a: num 0.274
##        ..$ ll  : num -683
##        ..$ ll_0: num -696
##        ..$ rank: num 3
##       $ macros  :List of 11
##        ..$ cmdline   : chr "regress price weight trunk, robust"
##        ..$ title     : chr "Linear regression"
##        ..$ marginsok : chr "XB default"
##        ..$ vce       : chr "robust"
##        ..$ depvar    : chr "price"
##        ..$ cmd       : chr "regress"
##        ..$ properties: chr "b V"
##        ..$ predict   : chr "regres_p"
##        ..$ model     : chr "ols"
##        ..$ estat_cmd : chr "regress_estat"
##        ..$ vcetype   : chr "Robust"
##       $ matrices:List of 3
##        ..$ b           :
##         weight trunk _cons
##      y1   2.27   -60   149
##      attr(,"class")
##      [1] "matrix"      "StataMatrix"
##      
##        ..$ V           :
##               weight   trunk  _cons
##      weight    0.388   -46.5   -435
##      trunk   -46.457  7785.8  24214
##      _cons  -435.200 24213.6 897830
##      attr(,"class")
##      [1] "matrix"      "StataMatrix"
##      
##        ..$ V_modelbased:
##                weight     trunk     _cons
##      weight  4.14e-08 -5.05e-06 -5.54e-05
##      trunk  -5.05e-06  1.37e-03 -3.53e-03
##      _cons  -5.54e-05 -3.53e-03  2.29e-01
##      attr(,"class")
##      [1] "matrix"      "StataMatrix"
##      
##       $ modeldf :Classes 'Stata_b_se' and 'data.frame':	3 obs. of  2 variables:
##               coef  stderr
##      weight   2.27   0.623
##      trunk  -60.04  88.237
##      _cons  148.55 947.539
##      
##       - attr(*, "class")= chr "StataResults"
##      
##      $r_class
##      List of 3
##       $ scalars :List of 1
##        ..$ level: num 95
##       $ macros  :List of 1
##        ..$ citype: chr "normal"
##       $ matrices:List of 1
##        ..$ table:
##               weight    trunk     _cons
##      b      2.27e+00  -60.039   148.553
##      se     6.23e-01   88.237   947.539
##      t      3.64e+00   -0.680     0.157
##      pvalue 5.15e-04    0.498     0.876
##      ll     1.02e+00 -235.978 -1740.785
##      ul     3.51e+00  115.901  2037.892
##      df     7.10e+01   71.000    71.000
##      crit   1.99e+00    1.994     1.994
##      eform  0.00e+00    0.000     0.000
##      attr(,"class")
##      [1] "matrix"      "StataMatrix"
##      
##       - attr(*, "class")= chr "StataResults"
```

```r
# Use in Stata an R demo dataset on flowers
# modify it (temporarily in Stata with preserve...restore,
# see http://www.stata.com/help.cgi?preserve)
# and do a simple regression:
data(iris)
r3 <- doInStata(i, code = 
                'describe
				gen ln_sepallength = log(sepallength)
				reg ln_sepallength sepalwidth petallength petalwidth',
				df = iris,
				preserve_restore = TRUE)
r3$log
```

```
##      
##      . describe
##      
##      Contains data
##        obs:           150                          
##       vars:             5                          
##       size:         3,900                          
##      ------------------------------------------------------------------------------
##                    storage   display    value
##      variable name   type    format     label      variable label
##      ------------------------------------------------------------------------------
##      sepallength     float   %9.0g                 Sepal.Length
##      sepalwidth      float   %9.0g                 Sepal.Width
##      petallength     float   %9.0g                 Petal.Length
##      petalwidth      float   %9.0g                 Petal.Width
##      species         str10   %10s                  Species
##      ------------------------------------------------------------------------------
##      Sorted by: 
##           Note: Dataset has changed since last saved.
##      
##      .                                 gen ln_sepallength = log(sepallength)
##      
##      .                                 reg ln_sepallength sepalwidth petallength petalwidth
##      
##            Source |       SS           df       MS      Number of obs   =       150
##      -------------+----------------------------------   F(3, 146)       =    304.61
##             Model |  2.56104326         3  .853681087   Prob > F        =    0.0000
##          Residual |  .409175062       146  .002802569   R-squared       =    0.8622
##      -------------+----------------------------------   Adj R-squared   =    0.8594
##             Total |  2.97021832       149  .019934351   Root MSE        =    .05294
##      
##      ------------------------------------------------------------------------------
##      ln_sepalle~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
##      -------------+----------------------------------------------------------------
##        sepalwidth |   .1070129   .0112169     9.54   0.000     .0848444    .1291813
##       petallength |   .1166281    .009546    12.22   0.000      .097762    .1354943
##        petalwidth |  -.0842665   .0214666    -3.93   0.000    -.1266919   -.0418411
##             _cons |   1.090994   .0422063    25.85   0.000      1.00758    1.174408
##      ------------------------------------------------------------------------------
```

```r
# If data is exported to Stata with df = ...
# a (possibly modified) Stata dataset is imported back
# into R unless argument import_df = FALSE is
# specified in doInStata()
str(r3$df)
```

```
##      'data.frame':	150 obs. of  6 variables:
##       $ sepallength   : num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
##       $ sepalwidth    : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
##       $ petallength   : num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
##       $ petalwidth    : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
##       $ species       : chr  "setosa" "setosa" "setosa" "setosa" ...
##       $ ln_sepallength: num  1.63 1.59 1.55 1.53 1.61 ...
```

```r
r3$results$e_class  # again, the estimated results from e() are available:
```

```
##      List of 4
##       $ scalars :List of 12
##        ..$ N   : num 150
##        ..$ df_m: num 3
##        ..$ df_r: num 146
##        ..$ F   : num 305
##        ..$ r2  : num 0.862
##        ..$ rmse: num 0.0529
##        ..$ mss : num 2.56
##        ..$ rss : num 0.409
##        ..$ r2_a: num 0.859
##        ..$ ll  : num 230
##        ..$ ll_0: num 81.3
##        ..$ rank: num 4
##       $ macros  :List of 10
##        ..$ cmdline   : chr "regress ln_sepallength sepalwidth petallength petalwidth"
##        ..$ title     : chr "Linear regression"
##        ..$ marginsok : chr "XB default"
##        ..$ vce       : chr "ols"
##        ..$ depvar    : chr "ln_sepallength"
##        ..$ cmd       : chr "regress"
##        ..$ properties: chr "b V"
##        ..$ predict   : chr "regres_p"
##        ..$ model     : chr "ols"
##        ..$ estat_cmd : chr "regress_estat"
##       $ matrices:List of 2
##        ..$ b:
##         sepalwidth petallength petalwidth _cons
##      y1      0.107       0.117    -0.0843  1.09
##      attr(,"class")
##      [1] "matrix"      "StataMatrix"
##      
##        ..$ V:
##                  sepalwidth petallength petalwidth     _cons
##      sepalwidth    1.26e-04    3.24e-05  -4.58e-05 -0.000451
##      petallength   3.24e-05    9.11e-05  -1.96e-04 -0.000206
##      petalwidth   -4.58e-05   -1.96e-04   4.61e-04  0.000326
##      _cons        -4.51e-04   -2.06e-04   3.26e-04  0.001781
##      attr(,"class")
##      [1] "matrix"      "StataMatrix"
##      
##       $ modeldf :Classes 'Stata_b_se' and 'data.frame':	4 obs. of  2 variables:
##                     coef  stderr
##      sepalwidth   0.1070 0.01122
##      petallength  0.1166 0.00955
##      petalwidth  -0.0843 0.02147
##      _cons        1.0910 0.04221
##      
##       - attr(*, "class")= chr "StataResults"
```

```r
# Since we did preserve...restore in Stata
# while operating on the iris data,
# the data on cars is still there
doInStata(i, 'describe', results=NULL)
```

```
##      $log
##      . describe
##      
##      Contains data from Q:\Stata140.001\ado\base/a/auto.dta
##        obs:            74                          1978 Automobile Data
##       vars:            12                          13 Apr 2014 17:45
##       size:         3,182                          (_dta has notes)
##      ------------------------------------------------------------------------------
##                    storage   display    value
##      variable name   type    format     label      variable label
##      ------------------------------------------------------------------------------
##      make            str18   %-18s                 Make and Model
##      price           int     %8.0gc                Price
##      mpg             int     %8.0g                 Mileage (mpg)
##      rep78           int     %8.0g                 Repair Record 1978
##      headroom        float   %6.1f                 Headroom (in.)
##      trunk           int     %8.0g                 Trunk space (cu. ft.)
##      weight          int     %8.0gc                Weight (lbs.)
##      length          int     %8.0g                 Length (in.)
##      turn            int     %8.0g                 Turn Circle (ft.)
##      displacement    int     %8.0g                 Displacement (cu. in.)
##      gear_ratio      float   %6.2f                 Gear Ratio
##      foreign         byte    %8.0g      origin     Car type
##      ------------------------------------------------------------------------------
##      Sorted by: foreign
```

```r
# Also r-class Stata results can be collected:
r4 <- doInStata(i, 'summarize price \n return list',
				results = 'r')  # Stata r-class results only
r4
```

```
##      $log
##      . summarize price 
##      
##          Variable |        Obs        Mean    Std. Dev.       Min        Max
##      -------------+---------------------------------------------------------
##             price |         74    6165.257    2949.496       3291      15906
##      
##      .  return list
##      
##      scalars:
##                        r(N) =  74
##                    r(sum_w) =  74
##                     r(mean) =  6165.256756756757
##                      r(Var) =  8699525.974268789
##                       r(sd) =  2949.495884768919
##                      r(min) =  3291
##                      r(max) =  15906
##                      r(sum) =  456229
##      
##      
##      $results
##      $results$r_class
##      List of 1
##       $ scalars:List of 8
##        ..$ N    : num 74
##        ..$ sum_w: num 74
##        ..$ mean : num 6165
##        ..$ Var  : num 8699526
##        ..$ sd   : num 2949
##        ..$ min  : num 3291
##        ..$ max  : num 15906
##        ..$ sum  : num 456229
##       - attr(*, "class")= chr "StataResults"
```

```r
# A non-blocking call to Stata -- perform some long-running job
system.time({f <- doInStata(i, 'sleep 8000 // in milliseconds in Stata
							display "hello"',
							future = TRUE,
							results = NULL)})
```

```
##         user  system elapsed 
##            0       0       0
```

```r
# do some work in R in the meantime:
Sys.sleep(2)
# collect the results from Stata if ready
# (if not ready, you must wait -- it's blocking this time,
# note the approximate time difference: 8 - 2 = 6):
system.time({r5 <- getStataFuture(f)})
```

```
##         user  system elapsed 
##         0.54    0.04    5.96
```

```r
r5
```

```
##      $log
##      . sleep 8000 // in milliseconds in Stata
##      
##      .                                                         display "hello"
##      hello
```

```r
# Say good-bye to Stata:
stopStata(i)
```

### A multiple Stata instance functionality demo


```r
library(RStataLink)
# The length of cl (the number of Stata instances) will depend
# on the number of cores detected by parallel::detectCores()
# (but you can override it)
cl <- startStataCluster()
```

```
##      Stata "server" started successfully.
##      Stata "server" started successfully.
```

```r
# It's just a simple list overall:
class(cl)
```

```
##      [1] "list"
```

```r
# Have a look at the first element:
cl[[1]]
```

```
##      StataID object:
##      
##       Stata "server" id:
##       HoF 
##       (you can see it in the top of the Stata window)
##      
##       Full path to the Stata "server" <--> R
##       data exchange directory (folder):
##       C:\Users\rutkoal\AppData\Local\Temp\1\RtmpyER5em/HoF 
##      
##       Should Stata close if this directory disappears:
##       no
```

```r
# A trivial example - a series of different regressions with
# only one explanatory variable each:
m <- paste('regress sepallength',
				 c('sepalwidth',
				   'petallength',
				   'petalwidth'))
cat(m, sep = '\n')
```

```
##      regress sepallength sepalwidth
##      regress sepallength petallength
##      regress sepallength petalwidth
```

```r
c1 <- doInStataCluster(cl,
					   # X = a vector (atomic or list) of tasks/jobs
					   # expressed as a character vector
					   # or a list of character vectors (which will be
					   # collapsed into string each)
					   X = m,
					   nolog = TRUE,
					   df = iris,
					   import_df = FALSE)
# A load-balancing version -- use if some jobs/tasks
# are much longer than others (iris data already loaded
# so no need for df = iris):
c2 <- doInStataClusterLB(cl,
					   X = m,
					   nolog = TRUE)
identical(c1, c2)
```

```
##      [1] TRUE
```

```r
# Collect the results:
library(magrittr) # for the super cool pipe operator %>%
c1 %>%
	lapply(function(x) x$results$e_class$modeldf) %>%
	do.call(rbind, .)
```

```
##                        coef     stderr
##      sepalwidth  -0.2233611 0.15508093
##      _cons        6.5262227 0.47889633
##      petallength  0.4089223 0.01889134
##      _cons1       4.3066034 0.07838896
##      petalwidth   0.8885802 0.05137355
##      _cons2       4.7776294 0.07293476
```

```r
# Say good-bye to all the Statas opened by R
# (clear = TRUE so that each Stata allows you
# to discard the imported iris data):
stopStataCluster(cl, clear = TRUE)
```

