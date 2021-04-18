# read file with reviews, select needed columns
reviews_all <- read_csv("reviews 2_old.csv") %>% ### use the old file at this time
  select(listing_id, id)

# select needed columns
sentiments <- read_csv("sentiments2020-12-05.csv")
sentiments_id_sent <- select(sentiments, id, sentiment)

# set the threshold
upper_threshold <- -1e-3
lower_threshold <- -0.012

# function which translates the score into a decision
decision <- function(x) {
  if (x["sentiment"] > upper_threshold) {
    x["decision"] <- "Positive"
  }
  else if (x["sentiment"] < lower_threshold) {
    x["decision"] <- "Negative"
  }
  else {
    x["decision"] <- "Neutral"
  }
}

# create a column with decisions
sentiments_id_sent$decision <- apply(sentiments_id_sent, 1, decision)

# remove sentiment column
sentiments_id_sent <- sentiments_id_sent[-2]

# count positive, negative, and neutral reviews numbers
reviews_numbs <- reviews_all %>% 
  left_join(sentiments_id_sent, by = "id") %>% 
  drop_na() %>% 
  group_by(listing_id, decision) %>% 
  count() %>% 
  pivot_wider(names_from = "decision", values_from = n) %>% 
  rename(id = "listing_id")

# read the file with listings
listings_all <- read_csv("listings_w_crimes.csv")

# add reviews numbers to the listings table
listings_all <- listings_all %>% 
  left_join(reviews_numbs, by = "id")

# replace NAs with 0
listings_all$Positive[is.na(listings_all$Positive)] <- 0
listings_all$Negative[is.na(listings_all$Negative)] <- 0
listings_all$Neutral[is.na(listings_all$Neutral)] <- 0


# write amended dataset to the file
write_csv(listings_all, "listings_updated.csv")
