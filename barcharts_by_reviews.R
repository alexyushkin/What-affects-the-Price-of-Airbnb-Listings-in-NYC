library(tidyverse)

dataset = read_csv("listings_updated.csv")
names(dataset)

dataset$review <- "NoReviews"
for (i in 1:nrow(dataset)) {
  if (dataset[i, "Negative"] >= 1) {
    dataset[i, "review"] <- "HasNegative"
  } else if (dataset[i, "Neutral"] >= 1) {
    dataset[i, "review"] <- "HasNeutral"
  } else if (dataset[i, "Positive"] >= 1) {
    dataset[i, "review"] <- "Positive"
  }
}

dataset %>% 
  group_by(neighbourhood_group) %>% 
  ggplot() + 
  geom_bar(mapping = aes(x = neighbourhood_group, fill = review))


dataset %>% 
  group_by(neighbourhood_group) %>% 
  ggplot() + 
  geom_histogram(mapping = aes(x = log(price), fill = review))


dataset$review <- factor(dataset$review, levels = c("Positive",
                                                    "HasNeutral",
                                                    "HasNegative",
                                                    "NoReviews"))

dataset %>% 
  group_by(neighbourhood_group) %>% 
  ggplot() + 
  geom_histogram(mapping = aes(x = log(price), fill = review),
                 alpha = 0.35,
                 position = 'identity')



dataset %>% 
  group_by(neighbourhood_group) %>% 
  ggplot() + 
    geom_col(mapping = aes(x = neighbourhood_group, y = price, fill = review))



