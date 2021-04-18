library(tidyverse)
library(geosphere)


shooting_hist <- read_csv("NYPD_Shooting_Incident_Data__Historic_.csv")
shooting_2020 <- read_csv("NYPD_Shooting_Incident_Data__Year_To_Date_.csv")

shooting <- full_join(shooting_hist, shooting_2020) 

# precincts numbers with thair average coordinates
precincts <- shooting %>% 
  select(PRECINCT, Longitude, Latitude) %>% 
  group_by(PRECINCT) %>% 
  mutate(avg_lon = mean(Longitude)) %>% 
  mutate(avg_lat = mean(Latitude)) %>% 
  slice(n = 1) %>% 
  select(-Longitude, -Latitude)

# quantity of shootings by precincts
shooting_num <- shooting %>% 
  group_by(PRECINCT) %>% 
  count() %>% 
  rename(shooting_number = "n")

# merge data on crime locations and quantities
crime_rate_by_neibs <- precincts %>% 
  left_join(shooting_num)


# read 911 calls data
calls_911 <- read_csv("NYPD_Calls_for_Service.csv")

# calculate calls per precincts
calls_911_num <- calls_911 %>% 
  group_by(NYPD_PCT_CD) %>% 
  count() %>% 
  rename(PRECINCT = "NYPD_PCT_CD") %>% 
  rename(calls_911_number = "n")

# add 911 calls numbers to the crimes table
crime_rate_by_neibs <- crime_rate_by_neibs %>% 
  left_join(calls_911_num, by = "PRECINCT")


# nearest precinct
df <- read_csv("listingsNYC_w_transp_cult.csv")

# coordinates of apartments/houses
coordinates <- df %>% 
  select(id, longitude, latitude)

# distances between apartments/houses and precincts
dist <- mapply(function(lon, lat, coord) distHaversine(c(lon, lat), coord),
               crime_rate_by_neibs$avg_lon, crime_rate_by_neibs$avg_lat,
               list(coordinates[-1]))

# nearest precincts
min_dist <- apply(dist, 1, which.min)

# add precincts, shootings, and 911 calls into the tibble
df["precinct"] <- crime_rate_by_neibs[min_dist, 1]
df["shooting_number"] <- crime_rate_by_neibs[min_dist, 4]
df["calls_911_number"] <- crime_rate_by_neibs[min_dist, 5]

# write amended dataset to the file
write_csv(df, "listings_w_crimes.csv")


# ## quantity of shootings nearby 
# ## 44666 listings x 23127 shooting locations - needs much time and memory
# dist_2 <- mapply(function(lon, lat, coord) distHaversine(c(lon, lat), coord),
#                  shooting$Longitude, shooting$Latitude, 
#                  list(coordinates[-1]))
# 
# n_shootings_nearby <- rowSums(dist_2 < 150, na.rm = TRUE)
# min(n_shootings_nearby)
# max(n_shootings_nearby)
# 
# df["n_shootings_nearby"] <- n_shootings_nearby


# ## quantity of 911 calls nearby ### will take a huge amount of time!
# dist_3 <- mapply(function(lon, lat, coord) distHaversine(c(lon, lat), coord),
#                  calls_911$Longitude, calls_911$Latitude, 
#                  list(coordinates[-1]))
# 
# n_calls_911_nearby <- rowSums(dist_3 < 100, na.rm = TRUE)
# min(n_calls_911_nearby)
# max(n_calls_911_nearby)
# 
# df["n_calls_911_nearby"] <- n_calls_911_nearby
