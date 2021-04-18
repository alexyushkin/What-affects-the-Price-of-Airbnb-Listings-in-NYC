reviews <- read_csv("reviews 2.csv")

ids <- read_csv("ids.csv")

ids <- ids %>% 
  rename(listing_id = "id")

reviews_updated <- ids %>% 
  left_join(reviews, by = "listing_id") %>% 
  select(listing_id, id, comments)

write_csv(reviews_updated, "reviews 2.csv")
