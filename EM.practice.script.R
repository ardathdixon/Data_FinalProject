library(lubridate)
library(dplyr)
library(tidyverse)
library(gpplot2)
library(zoo)
library(trend)
library(tidyr)

fish.dat <- readxl::read_excel("../Data_FinalProject/Data/Raw/mrip_estim_catch_wave_1990_2019_NC.xlsx")

fish.tidy <- fish.dat %>%
  select(YEAR, WAVE, MODE_FX, AREA_X, TOT_CAT) %>%
  mutate(DATE = my(paste0(WAVE, "-", YEAR))) %>%
  select(DATE, MODE_FX, AREA_X, TOT_CAT)
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
                             start = c(fyear, fmonth),frequency = 12)
#change to frequency = 6

month.decomp <- stl(fish.monthly.ts, s.window = "periodic")

plot(month.decomp)

#need to ask Luana about how to deal with the 'waves' rather than months - think this may be making things funky

#maybe just copy the wave data so wave 1 corresponds to jan and feb etc

#if seasonal comp continues to look funky, maybe there's just no seasonality in dataset
#fxn in TS projects called autoplot() --> ggplot for TS. makes the plotting really smooth - autoplot(TS object)
#helps with visualizing if the TS is running correctly
#maybe just copy the wave data so it corresponds to jan and feb etc


