
## Introduction to `{targets}` and `{ddspWQ}` Data Science Sessions

The [`{ddspWQ}`](https://github.com/a-jone5/ddspWQ) package is a low dependency package designed to help
interact with the [‘Defra Data Services Platform Water Quality
Archive’](https://environment.data.gov.uk/water-quality/view/doc/reference)

The [`{targets}`](https://github.com/ropensci/targets/) package helps create quick, 
reproducible analysis by creating pipelines of tasks which only need updating if they change and
and the promotion of functional programming.


## Prerequisites

for this demo you will need to install the latest release of `{ddspWQ}`:

``` r
install.packages("devtools")
library(devtools)
install_github("a-jone5/ddspWQ")
library(ddspWQ)
```

`{targets}` can be installed from cran

``` r
install.packages(targets)
```

you will also need to clone this repository. Go to the terminal and type:

``` r
git clone https://github.com/a-jone5/wq_targets_setup
```

Also, it is helpful to use this document alongside the recording of the presentation
for more detailed explanations (although it is not necessary!). 

## Functions

All the functions are in the R folder. You can load them and test them by running

``` r
library(dplyr)
library(lubridate)
library(ddspWQ)
library(tidyr)
library(readr)
library(ggplot2)

source("R/functions.R")

```
and running the functions with an example sample point. 

## Establish the pipeline with `{targets}`

Go to the console and type:

``` r
library(targets)

use_targets()
```

A few things will happen, most importantly a new file appears with the name 
`_targets.r` which you have to edit, which is explained below.


Change the packages used in the options

``` r

# Set target options:
tar_option_set(
  packages = c("dplyr","lubridate","ddspWQ","ggplot2","tidyr","readr","arrow")
)


```
Now you can change the target list to look like this (remember to find a sample point
urn and insert it).

``` r

# Replace the target list below with your own:
list(
  tar_target(raw_dat, pull_api("INSERT_YOUR_SAMPLE_POINT"), format = "feather"),
  tar_target(tidy_dat, tidy(raw_dat)),
  tar_target(fit_dat, fit_model(tidy_dat)),
  tar_target(ts_plot, ts_plotter(tidy_dat)),
  tar_target(mod_plot, mod_plotter(tidy_dat,fit_dat))
)
```

## Run the pipeline

To check the pipelines tasks run:

``` r
tar_manifest()
```
To visualise the pipeline, which helps understand outdated targets and errors,
run:

``` r
tar_visnetwork()
```
For more complex pipelines `tar_visnetwork()` can be slow so you could
run 

``` r
tar_outdated()
```
To run the pipeline run:

``` r 
tar_make()
```

You can call any part of the pipeline by running the following function
with the target name, for example:

``` r
tar_read(ts_plot)
```


## Further reading 

The `{targets}` package has been developed by Will Landau and an excellent resource
is the online [book](https://books.ropensci.org/targets/), which contains more 
developed examples (and a great four minute video which I used as the inspiration for 
this presentation).

You can find more information on the `{ddspWQ}` package, with a workflow that 
includes finding sample points to use in this example [here](https://github.com/a-jone5/ddspWQ)



















