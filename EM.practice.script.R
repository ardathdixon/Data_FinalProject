library(lubridate)
library(dplyr)
library(tidyverse)
library(gpplot2)
library(zoo)
library(trend)
library(tidyr)

fish.dat <- readxl::read_excel("../Data_FinalProject/Data/Raw/mrip_estim_catch_wave_1990_2019_NC.xlsx")

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
  #mutate(DATE = my(paste0(WAVE, "-", YEAR))) %>% # DATE line from Eva's initial draft
  select(DATE, MONTH, YEAR, MODE_FX, AREA_X, TOT_CAT)
#wave 1 = Jan 1, wave 2 = March 1, etc --> how do we translate this? for loop? if wave == 1, date = Jan 1
#on ts fxn, say start = 1st year, 1st wave, then when specifying freq = 6 it should work
#can use ggplot to make sure it's doing this correctly


ggplot(fish.tidy, aes(x = DATE, y = TOT_CAT)) +
  geom_line() +
  geom_smooth(method = "lm")

fish.tidy.filled <- fish.tidy %>%
  mutate(TOT_CAT =
           na.approx(TOT_CAT))
#not sure if there were NAs tbh^

fmonth <- month(first(fish.tidy.filled$DATE))
fyear <- year(first(fish.tidy.filled$DATE))

fish.monthly.ts <- ts(fish.tidy.filled$TOT_CAT, 
                             start = c(1990, 1),frequency = 6)
#change to frequency = 6

month.decomp <- stl(fish.monthly.ts, s.window = "periodic")

plot(month.decomp)

#need to ask Luana about how to deal with the 'waves' rather than months - think this may be making things funky

#maybe just copy the wave data so wave 1 corresponds to jan and feb etc

#if seasonal comp continues to look funky, maybe there's just no seasonality in dataset
#fxn in TS projects called autoplot() --> ggplot for TS. makes the plotting really smooth - autoplot(TS object)
#helps with visualizing if the TS is running correctly
#maybe just copy the wave data so it corresponds to jan and feb etc

#Annie's notes 4/9
#after adding month corresponding to beginning of wave, still looks funky
#attempted to fix this by adding sum of TOT_CAT for each wave
#need to verify if this is ok/why there are so many different point for each
#possibly due to different combinations of areas, zones of fishing, etc
fish.tidy.summary <- fish.tidy %>%
  select(DATE, MONTH, YEAR, TOT_CAT) %>%
  group_by(DATE) %>%
  summarise(TOT_CAT_ALL = sum(TOT_CAT))
  
#does not have NAs but does have missing observations
#approximate these later (just testing ts again for now)
fish.tidy.summary.ts <- ts(fish.tidy.summary$TOT_CAT_ALL, 
                           start = c(1990, 1),frequency = 6)
summary.ts.decomp <- stl(fish.tidy.summary.ts, s.window = "periodic")

plot(summary.ts.decomp)
