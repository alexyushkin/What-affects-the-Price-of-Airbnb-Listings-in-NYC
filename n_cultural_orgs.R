library(tidyverse)
library(geosphere)


df <- read_csv("listingsNYC_w_transport.csv")

coordinates <- df %>% 
  select(id, longitude, latitude)

cult_orgs <- read.csv("DCLA_Cultural_Organizations.csv", 
                   stringsAsFactors = FALSE)

dist <- mapply(function(lon, lat, coord) distHaversine(c(lon, lat), coord),
               cult_orgs$Longitude, cult_orgs$Latitude, 
               list(coordinates[-1]))

n_cult_orgs <- rowSums(dist < 150, na.rm = TRUE)
# min(n_cult_orgs)
# max(n_cult_orgs)

df["n_cult_orgs"] <- n_cult_orgs

# write amended dataset to the file
write_csv(df, "listingsNYC_w_transp_cult.csv")

