library(lubridate)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(zoo)
library(trend)
library(tidyr)
library(ggfortify)
library(forecast)
library(astsa)


#fish.dat <- readxl::read_excel("../Data_FinalProject/Data/Raw/mrip_estim_catch_wave_1990_2019_NC.xlsx")
fish.dat <- read.csv("../Data_FinalProject/Data/Raw/mrip_estim_catch_wave_1990_2019_nc.csv")

##create function to choose a month for each wave
wave_to_month_function <-  (function(WAVE) {
  if(WAVE == 1) {
    "Jan"
  }
  else if(WAVE == 2) {
    "Mar"
  }
  else if(WAVE == 3) {
    "May"
  }
  else if(WAVE == 4) {
    "Jul"
  }
  else if(WAVE == 5) {
    "Sep"
  }
  else {
    "Nov"
  }
})

#vectorize function
wave_to_month_function_V <- Vectorize(wave_to_month_function)

#create tidy dataset
fish.tidy <- fish.dat %>%
  select(YEAR, WAVE, MODE_FX, AREA_X, TOT_CAT) %>%
  mutate(MONTH = wave_to_month_function_V(WAVE)) %>%
  mutate(DATE = my(paste0(MONTH, "-", YEAR))) %>%
  select(DATE, MONTH, YEAR, MODE_FX, AREA_X, TOT_CAT)


ggplot(fish.tidy, aes(x = DATE, y = TOT_CAT)) +
  geom_line() +
  geom_smooth(method = "lm")

fish.tidy.filled <- fish.tidy %>%
  mutate(TOT_CAT =
           na.approx(TOT_CAT))


fmonth <- month(first(fish.tidy.filled$DATE))
fyear <- year(first(fish.tidy.filled$DATE))

fish.monthly.ts <- ts(fish.tidy.filled$TOT_CAT, 
                      start = c(1990, 1),frequency = 6)

month.decomp <- stl(fish.monthly.ts, s.window = "periodic")

plot(month.decomp)

#fxn in TS projects called autoplot() --> ggplot for TS. makes the plotting really smooth - autoplot(TS object)
#helps with visualizing if the TS is running correctly


#need to verify if sum of TOT_CAT is ok/why there are so many different point for each
#possibly due to different combinations of areas, zones of fishing, etc
fish.tidy.summary <- fish.tidy %>%
  select(DATE, MONTH, YEAR, TOT_CAT) %>%
  group_by(DATE) %>%
  summarise(TOT_CAT_ALL = sum(TOT_CAT))


#approximate these later (just testing ts again for now)
fish.tidy.summary.ts <- ts(fish.tidy.summary$TOT_CAT_ALL, 
                           start = c(1990, 1),frequency = 6)
summary.ts.decomp <- stl(fish.tidy.summary.ts, s.window = "periodic")

#autoplot requires ggfortify along w ggplot
autoplot(fish.tidy.summary.ts)

#forecasting: use forecast fxn but have to specify a method
#exponential smoothing: extension of above, use weighted averages of past observations - more recent obs get weighted higher 
#holts trend: extension of above, considers trend component - 2 smoothing eqtns 
#ARIMA: v popular. tries to describe autocorrelations rather than basing on trend and seasonality 
#holt winters is holts trend but w added seasonality
#double season holt winters allows for seasonality on multiple scales, e.g. month and year
#SARIMA adds seasonal component to ARIMA
#HW 4 year:
holtsfish <- HoltWinters(fish.tidy.summary.ts)
fish.predict.HW <- forecast(holtsfish, h=24, findfrequency = TRUE)
plot(fish.predict.HW)


#[plots and analysis in AM]
