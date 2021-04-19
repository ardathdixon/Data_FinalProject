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
bass.dat <- read.csv("../Data_FinalProject/Data/Raw/BSB_mrip_estim_catch_wave_1990_2019_nc.csv")

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
bass.tidy <- bass.dat %>%
  select(YEAR, WAVE, MODE_FX, AREA_X, TOT_CAT) %>%
  mutate(MONTH = wave_to_month_function_V(WAVE)) %>%
  mutate(DATE = my(paste0(MONTH, "-", YEAR))) %>%
  select(DATE, MONTH, YEAR, MODE_FX, AREA_X, TOT_CAT)


ggplot(bass.tidy, aes(x = DATE, y = TOT_CAT)) +
  geom_line() +
  geom_smooth(method = "lm")

bass.tidy.filled <- bass.tidy %>%
  mutate(TOT_CAT =
           na.approx(TOT_CAT))


fmonth <- month(first(bass.tidy.filled$DATE))
fyear <- year(first(bass.tidy.filled$DATE))

bass.monthly.ts <- ts(bass.tidy.filled$TOT_CAT, 
                      start = c(1990, 1),frequency = 6)

month.decomp <- stl(bass.monthly.ts, s.window = "periodic")

plot(month.decomp)

#fxn in TS projects called autoplot() --> ggplot for TS. makes the plotting really smooth - autoplot(TS object)
#helps with visualizing if the TS is running correctly


#need to verify if sum of TOT_CAT is ok/why there are so many different point for each
#possibly due to different combinations of areas, zones of fishing, etc
bass.tidy.summary <- bass.tidy %>%
  select(DATE, MONTH, YEAR, TOT_CAT) %>%
  group_by(DATE) %>%
  summarise(TOT_CAT_ALL = sum(TOT_CAT))


#approximate these later (just testing ts again for now)
bass.tidy.summary.ts <- ts(bass.tidy.summary$TOT_CAT_ALL, 
                           start = c(1990, 1),frequency = 6)
summary.ts.decomp <- stl(bass.tidy.summary.ts, s.window = "periodic")

#autoplot requires ggfortify along w ggplot
autoplot(bass.tidy.summary.ts)

#forecasting: use forecast fxn but have to specify a method
#exponential smoothing: extension of above, use weighted averages of past observations - more recent obs get weighted higher 
#holts trend: extension of above, considers trend component - 2 smoothing eqtns 
#ARIMA: v popular. tries to describe autocorrelations rather than basing on trend and seasonality 
#holt winters is holts trend but w added seasonality
#double season holt winters allows for seasonality on multiple scales, e.g. month and year
#SARIMA adds seasonal component to ARIMA
#HW 4 year:
holtsbass <- HoltWinters(bass.tidy.summary.ts)
bass.predict.HW <- forecast(holtsbass, h=24, findfrequency = TRUE)
plot(bass.predict.HW)

#arima:
#bass.arima <- auto.arima(bass.tidy.summary.ts)
#summary(bass.arima)
#plot(forecast(bass.arima, 24))
#leaving this so you can see it but it looks funky - I think a SARIMA is better here than auto.arima, but it requires a lot of coefficients that we don't know. Let's stick w HW!

plot(summary.ts.decomp)

ggplot(bass.tidy.summary, aes(x = DATE, y = TOT_CAT_ALL)) +
  geom_line() +
  geom_smooth(method = "lm")

bass.tidy.trend <- Kendall::SeasonalMannKendall(bass.tidy.summary.ts) #SMK test before interpolation
bass.tidy.trend
#will interpret in AM

summary(summary.ts.decomp)
#interpret in AM


bass.summary.interpolate <- as.data.frame(
  seq.Date(from = as.Date("1990-01-01"), to = as.Date("2019-11-01"), by = "2 months"))
colnames(bass.summary.interpolate) <- c("DATE")
#interpret in AM

#[finish in AM]


