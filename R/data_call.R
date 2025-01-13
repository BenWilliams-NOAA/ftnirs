# retrieve goa specimen data
# load ----
library(afscdata)

# data ----
db <- afscdata::connect("afsc")

dplyr::tbl(db, dplyr::sql("racebase.cruise")) %>%
  dplyr::rename_with(tolower) -> aa

dplyr::tbl(db, dplyr::sql("racebase.haul")) %>%
  dplyr::rename_with(tolower) -> bb

dplyr::tbl(db, dplyr::sql("racebase.specimen")) %>%
  dplyr::rename_with(tolower) -> cc

# join, filter and query
dplyr::select(aa, cruisejoin, region, vessel, survey_name, start_date) %>%
  dplyr::left_join(dplyr::select(bb, cruisejoin, hauljoin, vessel, start_latitude, end_latitude,
                                 start_longitude, end_longitude, bottom_depth, abundance_haul,
                                 stratum, gear_temperature)) %>%
  dplyr::left_join(dplyr::select(cc, hauljoin, specimenid, species_code, sex,
                                 length, weight, age, maturity)) %>%
  dplyr::mutate(year = lubridate::year(start_date)) %>%
  dplyr::select(-start_date) %>%
  dplyr::filter(abundance_haul == "Y",
                region %in% 'GOA',
                species_code %in% 30420) %>%
  dplyr::arrange(year) -> table

dplyr::collect(table) %>%
  vroom::vroom_write(here::here("data", "goa_specimen_data.csv"), delim = ",")
