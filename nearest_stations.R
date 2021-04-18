library(tidyverse)
library(geosphere) 


df <- read_csv("listingsNYC.csv")

coordinates <- df %>% 
  select(id, longitude, latitude)


# subway <- read_csv("NYC_Transit_Subway_Entrance_And_Exit_Data.csv")
# (subway <- subway %>% 
#   rename(name = "Station Name") %>% 
#   rename(lon = "Entrance Longitude") %>% 
#   rename(lat = "Entrance Latitude") %>% 
#   select(name, lat, lon) %>% 
#   distinct(name, lat, lon, .keep_all = T))

# f <- function(lon, lat, coord) distHaversine(c(lon, lat), coord)
# dist <- mapply(f,
#                subway[,29], subway[,30], list(coordinates[-1]))

subway <- read.csv("NYC_Transit_Subway_Entrance_And_Exit_Data.csv", 
                   stringsAsFactors = FALSE)

dist <- mapply(function(lon, lat, coord) distHaversine(c(lon, lat), coord),
               subway$Entrance.Longitude, subway$Entrance.Latitude, 
               list(coordinates[-1]))

min_dist <- apply(dist, 1, which.min)
# summary(min_dist)

# cbind(id = coordinates$id, distance = min_dist, station = subway[min_dist, 3])

# coordinates["distance"] <- min_dist
# coordinates["station"] <- subway[min_dist, 3]

df["distance_from_subway_station"] <- min_dist
df["station"] <- subway[min_dist, 3]

# write amended dataset to the file
write_csv(df, "listingsNYC_w_subway.csv")
