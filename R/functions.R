library(dplyr)
library(lubridate)
library(ddspWQ)
library(tidyr)
library(ggplot2)

## name this raw_dat

pull_api <- function(site){
  
  fetch_sample_res(site_notation = site) 
  
}

## name this tidy_bod

tidy_dat_bod <- function(raw_dat){
  
  raw_dat %>% 
    rename("urn" = sample.samplingPoint.notation,
           "site" = sample.samplingPoint.label,
           "det_name" = determinand.definition,
           "det_code" = determinand.notation,
           "sample_date" = sample.sampleDateTime,
           "sample_result" = result,
           "sample_qualifier" = resultQualifier.notation,
           "sample_unit" = determinand.unit.label) %>%
    select(c(urn,site,det_name,det_code,sample_date,sample_result,sample_qualifier,sample_unit)) %>% 
    mutate(
      date_time = lubridate::ymd_hms(sample_date),
      month_year = format_ISO8601(date_time, precision = "ym"),
      year = year(date_time),
      sample_hour = hour(date_time),
      sample_day = wday(date_time, label = TRUE, abbr = FALSE),
      index = as.numeric(row.names(.))
    ) %>% 
    filter(det_code == "0111"|det_code == "0135") %>% 
    select(det_code,date_time,sample_result) %>% 
    pivot_wider(names_from = det_code, values_from = sample_result) %>%
    rename("bod" = 2,
           "ss" = 3)
  
}

## name this fit_bod

fit_bod_model <- function(tidy_bod){
  
  lm(bod ~ ss, tidy_bod) %>% 
    coefficients()
  
}

## name this plot

bod_plot <- function(tidy_bod,fit_bod){
  
  ggplot(tidy_bod) +
    geom_point(aes(x = ss, y = bod)) +
    geom_abline(intercept = fit_bod[1], slope = fit_bod[2], colour = "blue") +
    theme_bw()
  
}
