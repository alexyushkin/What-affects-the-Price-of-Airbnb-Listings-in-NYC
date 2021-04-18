library(tidyverse)


# read the file with listings
listings_all <- read_csv("listings_updated.csv")


## cleaning and processing data

# neighborhood_group probably doesn't give an exact information about the 
# neighborhood environment
listings_all %>% 
  group_by(neighbourhood_group) %>% #5
  count()

# there are too many neighborhoods to make dummy variables
listings_all %>% 
  group_by(neighbourhood) %>% #221
  count()


# there are 388 Hotel rooms in the database, and 920 Shared rooms. 
listings_all %>% 
  group_by(room_type) %>% 
  count()

# I suggest to remove them
listings_all <- subset(listings_all, 
                       room_type != "Hotel room" & room_type != "Shared room")


# create a new column for number of days since the last review
listings_all$days_last_rev <- 
  as.numeric(as.Date("2020-10-12") - listings_all$last_review)
# replace NAs with max value
listings_all$days_last_rev[is.na(listings_all$days_last_rev)] <- 
  max(listings_all$days_last_rev, na.rm = TRUE)

# replace NAs with 0
listings_all$reviews_per_month[is.na(listings_all$reviews_per_month)] <- 0


# remove columns we won't use
listings_all <- select(listings_all, -id, -name, -host_id, -host_name, 
                       -neighbourhood_group, -neighbourhood, -latitude, 
                       -longitude, -last_review, 
                       -calculated_host_listings_count, 
                       -station, -stop,
                       -precinct)

# create dummy variable EntireHomeApt/PrivateRoom
listings_all$EntireHomeApt <- 0

for (i in 1:nrow(listings_all)) {
  if (listings_all[i, "room_type"] == "Entire home/apt") {
    listings_all[i, "EntireHomeApt"] <- 1
  } 
}

# remove the column we don't need any more
listings_all <- select(listings_all, -room_type)


# remove rows with price = 0
listings_all <- listings_all %>% 
  filter(price > 0)


# minimum nights
ggplot(listings_all, aes(minimum_nights)) +
  geom_histogram(bins = 60)

min_nights_distr <- listings_all %>% 
  group_by(minimum_nights) %>% 
  count() %>% 
  arrange(desc(minimum_nights))

# short term
listings_short_term <- listings_all %>% 
  filter(minimum_nights < 30)

# long term
listings_long_term <- listings_all %>% 
  filter(minimum_nights >= 30)

## I recommend to choose short term - more observations, less predictable price

# price per night or per minimum_nights? could be different
# maybe it makes sense to use only rows with minimum_nights == 1?
listings_one_night <- listings_short_term %>% 
  filter(minimum_nights == 1) %>% 
  select(-minimum_nights)

# price
ggplot(listings_one_night, aes(price)) +
  geom_histogram(bins = 60)

ggplot(listings_one_night, aes(price)) +
  geom_boxplot(alpha = 0.2)


# remove price per night > 700 
listings_wo_outliers <- listings_one_night %>%
  filter(price <= 700)

ggplot(listings_wo_outliers, aes(price)) +
  geom_histogram(bins = 60)

ggplot(listings_wo_outliers, aes(price)) +
  geom_boxplot(alpha = 0.2)

price_distr <- listings_wo_outliers %>%
  group_by(price) %>%
  count() %>%
  arrange(desc(price))


# create demand variable
listings_w_demand <- listings_wo_outliers %>% 
  mutate(demand <- 365 - availability_365) %>% 
  rename(demand = "demand <- 365 - availability_365") %>% 
  select(-availability_365)


str(listings_w_demand)

summary(listings_w_demand)


write_csv(listings_w_demand, "prepared_data.csv")



# # ids which we are going to use, filtered reviews out 
# # not to process those ones which are not necessary
# ids <- listings_wo_outliers %>% 
#   select(id)
# write_csv(ids, "ids.csv")

