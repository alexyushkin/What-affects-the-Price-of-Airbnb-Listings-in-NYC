library(tidyverse)
library(geosphere)


df <- read_csv("listingsNYC_w_subway.csv")

coordinates <- df %>% 
  select(id, longitude, latitude)


bus <- read.csv("Bus_Stop_Shelter.csv", 
                   stringsAsFactors = FALSE)

dist <- mapply(function(lon, lat, coord) distHaversine(c(lon, lat), coord),
               bus$LONGITUDE, bus$LATITUDE, 
               list(coordinates[-1]))

min_dist <- apply(dist, 1, which.min)
# summary(min_dist)

# coordinates["distance"] <- min_dist
# coordinates["stop"] <- bus[min_dist, 8]

df["distance_from_bus_stop"] <- min_dist
df["stop"] <- bus[min_dist, 8]

# write amended dataset to the file
write_csv(df, "listingsNYC_w_transport.csv")

