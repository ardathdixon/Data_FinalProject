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

month.decomp <- stl(fish.monthly.ts, s.window = "periodic")

plot(month.decomp)

#need to ask Luana about how to deal with the 'waves' rather than months - think this may be making things funky
#maybe just copy the wave data so wave 1 corresponds to jan and feb etc


