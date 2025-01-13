# exploring FT-NIRS GOA northern rockfish
# ben.williams@noaa.gov
# 2025-01


# load ----
library(tidytable)
library(ggplot2)
library(here)
library(vroom)
library(readxl)
library(PBSmapping)


# data ----
data('nepacLLhigh')
nepacLLhigh %>%
  dplyr::select(group=PID, POS=POS,long=X, lat=Y) -> ak

vroom("data/AGP_MMCNN_NRF2013to2019.csv") %>% glimpse()
  select(sample, final_age, latitude, longitude, length, sex) -> agp # original data
glimpse(agp)

read_excel(here::here("data", "nrf_traintunetest_predictions_with_haul.xlsx")) %>%
            rename(vessel=vessel_code, specimenid=specimen_number) -> dat # update has haul id
glimpse(dat)

vroom(here::here("data", "goa_specimen_data.csv")) -> bts # GOA bottom trawl survey all sites
glimpse(bts)

dat %>%
  filter(cruisejoin %in% bts$cruisejoin) -> dat2 # filter to only include GOA samples
glimpse(dat2) # 1,307 samples for GOA

# align dat2 samples with haul id dat
dat2 %>%
  left_join(bts) -> dat

# map data
ggplot() +
  geom_polygon(data = ak, aes(long, lat, group = group), fill=8, color='black') +
  theme(panel.background = element_rect(fill = 'white')) +
  xlab(expression(paste(Longitude^o,~'W'))) +
  ylab(expression(paste(Latitude^o,~'W'))) +
  geom_point(data = dat, aes(start_longitude, start_latitude), color = 'red') +
  geom_point(data = bts, aes(start_longitude, start_latitude), color = 'blue', alpha = 0.05) +
  coord_map(xlim = c(-175, -145), ylim = c(50, 61))

# explore
dat %>%
  group_by(year) %>%
  tally()


