# install.packages("ggfortify")
# install.packages("forecast")
# install.packages("astsa")
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

#blue.dat <- readxl::read_excel("../Data_FinalProject/Data/Raw/mrip_estim_catch_wave_1990_2019_NC.xlsx")
blue.dat <- read.csv("../Data_FinalProject/Data/Raw/BLUEFISH_mrip_estim_catch_wave_1990_2019_nc.csv")

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
blue.tidy <- blue.dat %>%
  select(YEAR, WAVE, MODE_FX, AREA_X, TOT_CAT) %>%
  mutate(MONTH = wave_to_month_function_V(WAVE)) %>%
  mutate(DATE = my(paste0(MONTH, "-", YEAR))) %>%
  select(DATE, MONTH, YEAR, MODE_FX, AREA_X, TOT_CAT)


ggplot(blue.tidy, aes(x = DATE, y = TOT_CAT)) +
  geom_line() +
  geom_smooth(method = "lm")

blue.tidy.filled <- blue.tidy %>%
  mutate(TOT_CAT =
           na.approx(TOT_CAT))


fmonth <- month(first(blue.tidy.filled$DATE))
fyear <- year(first(blue.tidy.filled$DATE))

blue.monthly.ts <- ts(blue.tidy.filled$TOT_CAT, 
                             start = c(1990, 1),frequency = 6)

month.decomp <- stl(blue.monthly.ts, s.window = "periodic")

plot(month.decomp)

#fxn in TS projects called autoplot() --> ggplot for TS. makes the plotting really smooth - autoplot(TS object)
#helps with visualizing if the TS is running correctly


#need to verify if sum of TOT_CAT is ok/why there are so many different point for each
#possibly due to different combinations of areas, zones of fishing, etc
blue.tidy.summary <- blue.tidy %>%
  select(DATE, MONTH, YEAR, TOT_CAT) %>%
  group_by(DATE) %>%
  summarise(TOT_CAT_ALL = sum(TOT_CAT))
  
#does not have NAs but does have missing observations
#approximate these later (just testing ts again for now)
blue.tidy.summary.ts <- ts(blue.tidy.summary$TOT_CAT_ALL, 
                           start = c(1990, 1),frequency = 6)
summary.ts.decomp <- stl(blue.tidy.summary.ts, s.window = "periodic")

#autoplot requires ggfortify along w ggplot
autoplot(blue.tidy.summary.ts)

#forecasting: use forecast fxn but have to specify a method
#naive: uses most recent observation to forecast next one (NO)
#exponential smoothing: extension of above, use weighted averages of past observations - more recent obs get weighted higher (NO)
#holts trend: extension of above, considers trend component - 2 smoothing eqtns (maybe?)
#ARIMA: v popular. tries to describe autocorrelations rather than basing on trend and seasonality (NO)
#TBATS: combines trig terms for seasonality, heterogeneity, short-term error dynamics, trend, and seasonal components (maybe?)
#holt winters is holts trend but w added seasonality (maybe?)
#double season holt winters allows for seasonality on multiple scales, e.g. month and year
#SARIMA adds seasonal component to ARIMA
#HW:
holtsblue <- HoltWinters(blue.tidy.summary.ts)
blue.predict.HW <- forecast(holtsblue, h=12, findfrequency = TRUE)
plot(blue.predict.HW)
#^plots next 2 years^

#ARIMA:
arima.blue <- auto.arima(blue.tidy.summary.ts)
plot(arima.blue)
#oh no?????
#hahahaha

#SARIMA:
#sarima.blue <- sarima(blue.tidy.summary.ts, )
#these get super complicated with autoregressive orders and stuff so for now just look at HW one and other descriptions and let me know ur thoughts :)


plot(summary.ts.decomp)

ggplot(blue.tidy.summary, aes(x = DATE, y = TOT_CAT_ALL)) +
  geom_line() +
  geom_smooth(method = "lm")

blue.tidy.trend <- Kendall::SeasonalMannKendall(blue.tidy.summary.ts) #SMK test before interpolation
blue.tidy.trend ## shows significant change over time!! 

summary(summary.ts.decomp) #summary info includes min, mean, max, etc for each component
#also shows % for each - amount of variation explained, maybe?

#interpolation
#set up complete date sequence
blue.summary.interpolate <- as.data.frame(
  seq.Date(from = as.Date("1990-01-01"), to = as.Date("2019-11-01"), by = "2 months"))
colnames(blue.summary.interpolate) <- c("DATE")

#join data to complete date sequence
blue.summary.interpolate <- left_join(blue.summary.interpolate, blue.tidy.summary)

#how many dates are missing?
sum(is.na(blue.summary.interpolate$TOT_CAT_ALL)) #only 11 NAs! <- OLD DATA. New data has 18 NAs

#linear approximation for missing dates
blue.summary.interpolate$TOT_CAT_ALL <- na.approx(blue.summary.interpolate$TOT_CAT_ALL)

#rerun Seasonal Mann-Kendall test on interpolated data
blue.interpolated.ts <- ts(blue.summary.interpolate$TOT_CAT_ALL, 
                      start = c(1990, 1),frequency = 6)
blue.interpolated.trend <- Kendall::SeasonalMannKendall(blue.interpolated.ts) #SMK test after interpolation
blue.interpolated.trend ## also shows significant change over time!

