# library(dplyr)
# library(lubridate)
# library(ddspWQ)
# library(tidyr)
# library(readr)
# library(ggplot2)

## get data from api using ddspWQ

pull_api <- function(site){
  
  fetch_sample_res(site_notation = site) 
  
}

## tidy the data

tidy <- function(raw_dat){
  
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
    filter(det_code == "0085"|det_code == "0135") %>% 
    select(det_code,date_time,year,sample_result) %>% 
    pivot_wider(names_from = det_code, values_from = sample_result) %>%
    rename("bod" = `0085`,
           "ss" = `0135`)
  
}

## fit a model - lets look at the relationship between bod and sus solids 

fit_model <- function(tidy_dat){
  
  lm(bod ~ ss, tidy_dat) %>% 
    coefficients()
  
}

## plot the model 

mod_plotter <- function(tidy_dat,fit_dat){
  
  ggplot(tidy_dat) +
    geom_point(aes(x = ss, y = bod)) +
    geom_abline(intercept = fit_dat[1], slope = fit_dat[2], colour = "blue") +
    theme_bw()
  
}

## plot a time series for the bod

ts_plotter <- function(tidy_dat){
  
  year_mean <- tidy_dat %>%
    group_by(year) %>%
    summarise(bod_mean = mean(bod),
              ss_mean = mean(ss))
  
  total <- merge(tidy_dat,year_mean, by = "year")
  
  
  ggplot(total, mapping = aes(x = date_time)) +
    geom_point(mapping = aes(y = bod), col = "black") +
    geom_line(mapping = aes(y = bod_mean, group = as.factor(year)), col = "blue", lwd = 2) +
    scale_y_continuous(name = paste0("BOD (mg/l)")) +
    scale_x_datetime(name = "Date", breaks = waiver()) +
    ggtitle(paste0("BOD_ts_plot")) +
    theme_bw()
  
  
}
