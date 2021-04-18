---
title: "What affects the Price of Airbnb Listings in NYC?"
author: "by Alexey Yushkin and Jack Daoud"
output:
  html_notebook:
    number_sections: yes
    theme: readable
    highlight: pygments
    toc: yes
    toc_float:
      collapsed: yes
  html_document:
    toc: yes
    df_print: paged
---
```{r load packages, message=FALSE, warning=FALSE, include=FALSE}
# REMOVE # to install packages
#install.packages("tidyverse")
#install.packages("geosphere")
#install.packages("broom")
#install.packages("knitr")
#install.packages("reshape2")
#install.packages("sjPlot")
#install.packages("sjlabelled")
#install.packages("sjmisc")
# create a vector that holds all the packages we need to load
Packages <- c("tidyverse", "geosphere", "broom", "knitr", "reshape2", "sjPlot", "sjlabelled", "sjmisc")
# load Packages
lapply(Packages, library, character.only = TRUE)
```

# Framing the Problem

## Problem Recognition:

Pricing is a complicated but essential business decision. This is true for Airbnb hosts too, which have "limited and inefficient strategies" to "price their spaces" (Li *et al.*, 2015). The problem of price is made even more difficult hosts within New York City, NY where there are about **44,600 listings in NYC** - a lot of competition to consider. This pricing problem can be recognized as:

----------------------------------------------------------------------------

<center><b><em>Which criteria has a statistically significant relationship with the price of an Airbnb listing in NYC?</em></b></center>

----------------------------------------------------------------------------

## Review of Previous Findings:

Previous research regarding Airbnb accommodation prices had found that "price is significantly related to the level of the host's accumulated experience and the level of market demand on a specific booking date" (Magno *et al.*, 2018). More specifically, this research paper computed the impact of specific variables on the price of an Airbnb accommodation:

```{r research findings, echo=FALSE, message=FALSE, warning=FALSE}
# import data set holding previous findings
research_findings <- read_csv(file = "./Data/Markdown_Data/research_paper_data.csv")
# knit into a table
kable(research_findings)
```

## Thought Process:

Our analysis aims to infer whether or not certain variables - which are different from variables in the aforementioned literature - are related to the price of an accommodation. These variables are summarized under section 2.3 Variable Selection. The hypothesis for each variable will be as follows:

$$
\begin{aligned}
H_0 &: \beta_i = 0 \\
H_A &: \beta_i \neq 0
\end{aligned}
$$
Note: $\beta_i$ denotes the variable being tested, and in our case, we're assessing approximately 14. More specifically though, we're testing these 14 null hypotheses:

- **H0<sub>1</sub>**: The price of a listing is not related to the **number of reviews** the accommodation received
- **H0<sub>2</sub>**: The price of a listing is not related to the **number of reviews per month** the accommodation received
- **H0<sub>3</sub>**: The price of a listing is not related to the listing's **demand**
- **H0<sub>4</sub>**: The price of a listing is not related to its **distance from subway stations**
- **H0<sub>5</sub>**: The price of a listing is not related to its **distance from bus stops**
- **H0<sub>6</sub>**: The price of a listing is not related to the **number of cultural organizations nearby**
- **H0<sub>7</sub>**: The price of a listing is not related to the **number of shootings nearby**
- **H0<sub>8</sub>**: The price of a listing is not related to the **number of 911 calls nearby**
- **H0<sub>9</sub>**: The price of a listing is not related to its **number of negative reviews**
- **H0<sub>10</sub>**: The price of a listing is not related to its **number of neutral reviews**
- **H0<sub>11</sub>**: The price of a listing is not related to its **number of positive reviews**
- **H0<sub>12</sub>**: The price of a listing is not related to the **number of days since its last review**
- **H0<sub>13</sub>**: No difference exists between the price of an **entire apartment** and that of a **private room**
- **H0<sub>14</sub>**: The price of a listing is not related to the **number of listings a host has**


# Solving the Problem

## Data Collection:

The data sets we'll be analyzing revolves around Airbnb listings in New York City, NY in the US. The analysis also includes data sets regarding tourist attractions, crime rates, and transportation proximity. The number of observations and variables per data set is outlined below: 

```{r data collection, echo=FALSE, message=FALSE, warning=FALSE}
# import summary of data sets used in this report
data_sets <- read_csv(file = './Data/Markdown_Data/data_sets.csv')
# knit into a table
kable(data_sets)
```

*For data sources & snippets, please see the Appendix below.*

## Data Wrangling:

The data wrangling process involved joining the data sets in 5 sequential steps:

1. Listing data joined with Subway station data
2. Data from step 1 joined with Bus station data
3. Data from step 2 joined with Tourist attraction data
4. Data from step 3 joined with Crime rate data (Shootings / 911 Calls)
5. Data from step 4 joined with Listing reviews data with sentiment analysis

```{r subway stations, include=FALSE}
# import data set for wrangling
original_listings <- read_csv("./Data/Original_Data/listingsNYC.csv")
# create data frame for distance calculation
coordinates <- original_listings %>% 
  select(id, longitude, latitude)
# import data set to extract necessary variables
subway <- read.csv("./Data/Original_Data/NYC_Transit_Subway_Entrance_And_Exit_Data.csv", 
                   stringsAsFactors = FALSE)
# calculate the distance between each listing and subway entrance
dist <- mapply(function(lon, lat, coord) distHaversine(c(lon, lat), coord),
               subway$Entrance.Longitude, subway$Entrance.Latitude, 
               list(coordinates[-1]))
# find the nearest subway entrance
min_dist <- apply(dist, 1, which.min)
# write the distance between listing and station and station name
original_listings["distance_from_subway_station"] <- min_dist
original_listings["station"] <- subway[min_dist, 3]
# write amended data set to the file
write_csv(original_listings, "./Data/Manipulated_Data/listingsNYC_w_subway.csv")
```

```{r bus stations, include=FALSE}
# import data set for wrangling
manipulated_listings <- read_csv("./Data/Manipulated_Data/listingsNYC_w_subway.csv")
# create data frame for distance calculation
coordinates <- manipulated_listings %>% 
  select(id, longitude, latitude)
# import data set to extract necessary variables
bus <- read.csv("./Data/Original_Data/Bus_Stop_Shelter.csv", 
                   stringsAsFactors = FALSE)
# calculate the distance between each listing and bus stop
dist <- mapply(function(lon, lat, coord) distHaversine(c(lon, lat), coord),
               bus$LONGITUDE, bus$LATITUDE, 
               list(coordinates[-1]))
# find the nearest bus stop
min_dist <- apply(dist, 1, which.min)
# write the distance between listing and bus stop and bus stop name
manipulated_listings["distance_from_bus_stop"] <- min_dist
manipulated_listings["stop"] <- bus[min_dist, 8]
# write amended data set to the file
write_csv(manipulated_listings, "./Data/Manipulated_Data/listingsNYC_w_transport.csv")
```

```{r tourist attractions, include=FALSE}
# import data set for wrangling
manipulated_listings <- read_csv("./Data/Manipulated_Data/listingsNYC_w_transport.csv")
# create data frame for distance calculation
coordinates <- manipulated_listings %>% 
  select(id, longitude, latitude)
# import data set to extract necessary variables
cult_orgs <- read.csv("./Data/Original_Data/DCLA_Cultural_Organizations.csv", 
                   stringsAsFactors = FALSE)
# calculate the distance between each listing and cultural organizations
dist <- mapply(function(lon, lat, coord) distHaversine(c(lon, lat), coord),
               cult_orgs$Longitude, cult_orgs$Latitude, 
               list(coordinates[-1]))
# sum the number of cultural organizations with a distance of less than 150
n_cult_orgs <- rowSums(dist < 150, na.rm = TRUE)
# write the number of cultural organizations nearby each listing
manipulated_listings["n_cult_orgs"] <- n_cult_orgs
# write amended data set to the file
write_csv(manipulated_listings, "./Data/Manipulated_Data/listingsNYC_w_transp_cult.csv")
```

```{r crime rate, include=FALSE}
# import data set for wrangling
shooting_hist <- read_csv("./Data/Original_Data/NYPD_Shooting_Incident_Data__Historic_.csv")
shooting_2020 <- read_csv("./Data/Original_Data/NYPD_Shooting_Incident_Data__Year_To_Date_.csv")
# join the imported data sets to form one
shooting <- full_join(shooting_hist, shooting_2020) 
# precincts numbers with their average coordinates
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
calls_911 <- read_csv("./Data/Original_Data/NYPD_Calls_for_Service.csv")
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
manipulated_listings <- read_csv("./Data/Manipulated_Data/listingsNYC_w_transp_cult.csv")
# coordinates of apartments/houses
coordinates <- manipulated_listings %>% 
  select(id, longitude, latitude)
# distances between apartments/houses and precincts
dist <- mapply(function(lon, lat, coord) distHaversine(c(lon, lat), coord),
               crime_rate_by_neibs$avg_lon, crime_rate_by_neibs$avg_lat,
               list(coordinates[-1]))
# nearest precincts
min_dist <- apply(dist, 1, which.min)
# add precincts, shootings, and 911 calls into the tibble
manipulated_listings["precinct"] <- crime_rate_by_neibs[min_dist, 1]
manipulated_listings["shooting_number"] <- crime_rate_by_neibs[min_dist, 4]
manipulated_listings["calls_911_number"] <- crime_rate_by_neibs[min_dist, 5]
# write amended data set to the file
write_csv(manipulated_listings, "./Data/Manipulated_Data/listings_w_crimes.csv")
```

```{r listings reviews, include=FALSE}
# read file with reviews, select needed columns
reviews_all <- read_csv("./Data/Original_Data/listing_reviewsNYC.csv") %>%
  select(listing_id, id)
# select needed columns
sentiments <- read_csv("./Data/Manipulated_Data/sentiments_2020-12-06.csv")
sentiments_id_sent <- select(sentiments, id, sentiment)
# This data set was created via a sentiment analysis we conducted. Please see Sentiment Analysis subsection in Appendix for more details.
# set the threshold
upper_threshold <- -1e-3
lower_threshold <- -0.012
# function which translates the score into a decision
decision <- function(x) {
  if (x["sentiment"] > upper_threshold) {
    x["decision"] <- "positive"
  }
  else if (x["sentiment"] < lower_threshold) {
    x["decision"] <- "negative"
  }
  else {
    x["decision"] <- "neutral"
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
listings_all <- read_csv("./Data/Manipulated_Data/listings_w_crimes.csv")
# add reviews numbers to the listings table
listings_all <- listings_all %>% 
  left_join(reviews_numbs, by = "id")
# replace NAs with 0
listings_all$positive[is.na(listings_all$positive)] <- 0
listings_all$negative[is.na(listings_all$negative)] <- 0
listings_all$neutral[is.na(listings_all$neutral)] <- 0
# create a new column for number of days since the last review
listings_all$days_last_rev <- 
  as.numeric(as.Date("2020-10-12") - listings_all$last_review)
# replace NAs with max value
listings_all$days_last_rev[is.na(listings_all$days_last_rev)] <- 
  max(listings_all$days_last_rev, na.rm = TRUE)
# replace NAs with 0
listings_all$reviews_per_month[is.na(listings_all$reviews_per_month)] <- 0
# drop all variables not used in our analysis
listings_all <- select(listings_all, -id, -name, -host_id, -host_name, 
                       -neighbourhood, -latitude, -last_review, -station, 
                       -stop, -precinct)
# write amended data set to the file
write_csv(listings_all, "./Data/Manipulated_Data/listings_updated.csv")
```

## Variable Selection:

```{r variable selection, include=FALSE}
# read the file with listings
listings_all <- read_csv("./Data/Manipulated_Data/listings_updated.csv")
```

The finalized data set produced, after joining all aforementioned data sets & conducting data analysis below, has 19 key variables:

1. `price`: the cost of renting a listing for a day
2. `minimum_nights`: the number of minimum nights permitted for the booking of a listing
3. `number_of_reviews`: the total number of reviews for a listing
4. `reviews_per_month`: the number of reviews per month for a listing
5. `availability_365`: the number of days per year a listing is available for renting
6. `distance_from_subway_station`: the distance in miles between a listing and the nearest subway station
7. `distance_from_bus_stop`: the distance in miles between a listing and the nearest bus stop
8. `n_cult_orgs`: the number of cultural organizations / tourist attractions nearby a listing
9. `shooting_number`: the number of reported shootings nearby a listing
10. `calls_911_number`: the number of calls made to 911 nearby a listing
11. `negative`: the number of negative reviews for a listing
12. `neutral`: the number of neutral reviews for a listing
13. `positive`: the number of positive reviews for a listing
14. `days_last_rev`: the number of days since a listing's last review
15. `room_type`: whether a listing is an Entire Home/Apt, or Private room, or hotel, or shared room
16. `neighborhood_group`: which neighborhood group a listing is located in
17. `calculated_host_listings_count`: the total number of listings on Airbnb per host
18. `long_term_rent`: whether a listing is has a minimum stay of less than 30 days (short-term) or 30 days or more (long-term)
19. `demand`: the total number of days a listing is *not* available within a year

All these variables will be criteria that could answer our business problem:

----------------------------------------------------------------------------

<center><b><em>Which criteria has a statistically significant relationship with the price of an Airbnb listing in NYC?</em></b></center>

----------------------------------------------------------------------------

## Data Analysis:

### Price

The first step is to assess the main variable of our analysis - the *price* of a listing.

```{r price, echo=FALSE, message=FALSE, warning=FALSE}
# check the distribution of price via histogram
ggplot(data = listings_all) +
  geom_histogram(mapping = aes(x = price), fill = 'dodgerblue4') +
  labs(title = "Is Price Skewed?",
       x = "Price",
       y = "Count") +
  theme(plot.title = element_text(hjust = 0.5))
```

As we can see, price is **highly skewed to the right** and therefore **warrants a transformation** if we are to conduct further analysis in the form of linear regression. Furthermore, it seems there are **some listings with a price of zero** that ought to be **excluded**.

```{r price - log transformation, echo=FALSE, message=FALSE, warning=FALSE}
# remove rows with price = 0
listings_all <- listings_all %>% 
  filter(price > 0)
# transform price using log
listings_all = listings_all %>% 
  mutate(log_price = log(price))
# plot the new distribution
ggplot(data = listings_all) +
  geom_histogram(mapping = aes(x = log_price), fill = "dodgerblue4") +
  labs(title = "log_Price with Normal Distribution",
       x = "log_Price",
       y = "Count") +
  theme(plot.title = element_text(hjust = 0.5))
```

Now price represents a more *'normal'* distribution. However, there appears to be **outliers**. We can clearly identify them using a boxplot:

```{r price - outlier detection, echo=FALSE, message=FALSE, warning=FALSE}
# check for outliers using a boxplot
ggplot(listings_all, aes(x = log_price)) +
  geom_boxplot(fill = 'dodgerblue4') +
  labs(title = "Boxplot of log_Price",
       x = "log_Price",
       y = "Count") +
  theme(plot.title = element_text(hjust = 0.5))
# write amended data set to file
write_csv(listings_all, "./Data/Manipulated_Data/listings_updated.csv")
```

What is the cause of all these outliers in terms of price? It could be a categorical variable, such as the neighborhood group or room type of the listing. It is important to note, although these prices are considered to **statistical outliers**, really expensive listings and really cheap listings have their **business justifications that make them normal**. For example, a listing in a booming location with extremely fancy furniture & many amenities. Therefore, these outliers will be considered throughout the analysis.

### Room type & Neighborhood Group

Let's start with looking at the count of each variable

```{r count per category, echo=FALSE, message=FALSE, warning=FALSE}
# count the number of listings for each room type & knit into a table
kable(listings_all %>% 
  count(room_type) %>% 
  rename(num_listing = n))
# count the number of listings for each neighborhood group & knit into a table
kable(listings_all %>% 
  count(neighbourhood_group) %>% 
  rename(num_listing = n))
```

Hotel rooms and shared rooms make up approximately **1%** and **2%** of the total listings respectively. Listings in Staten Island and Bronx make up also **1%** and **2%** of total listings respectively. Such minute proportions are negligible and therefore warrant an exclusion from the analysis.

```{r exclude room_types, echo=FALSE, message=FALSE, warning=FALSE}
# subset data to exclude all rows of negligible room types and neighborhood groups
listings_all <- subset(listings_all, 
                       room_type != "Hotel room" & room_type != "Shared room" &
                       neighbourhood_group != "Bronx" & neighbourhood_group != "Staten Island")
```

Now let's look at how each room type relates with price.

```{r room_type, echo=FALSE, message=FALSE, warning=FALSE}
# plot distribution of log_price by room_type and split by neighborhood group
listings_all %>% 
  ggplot(.) +
  geom_histogram(mapping = aes(x = log_price, fill = room_type), 
                 alpha = 0.75, 
                 position = 'identity') +
  facet_wrap('neighbourhood_group') +
  labs(title = "log_Price Distribution per Neighborhood",
       x = "log_Price",
       y = "Count") +
  theme(plot.title = element_text(hjust = 0.5))
```

Observations of the above visualization can be summarized as follows:

- Private room prices are grouped towards lower levels
- Entire home/apt prices are grouped towards higher levels
- Prices of listings are lower in Queens compared to Brooklyn and Manhattan.

Based on this, there seems to be some relationship between room type, neighborhood group and price. This relationship will be worth analyzing by using a regression model in section 3.

```{r room_types dummy variable, message=FALSE, warning=FALSE, include=FALSE}
# Since we only have two room types, it is wise to transform the variable into
# a dummy variable of entire_home_apt/private_room
listings_all$entire_home_apt <- 0
# loop through each row and label 1 for room type of Entire home/apt
for (i in 1:nrow(listings_all)) {
  if (listings_all[i, "room_type"] == "Entire home/apt") {
    listings_all[i, "entire_home_apt"] <- 1
  } 
}
# remove the column we don't need any more
listings_all <- select(listings_all, -room_type)
# write amended data set to file
write_csv(listings_all, "./Data/Manipulated_Data/listings_updated.csv")
```

### Minimum nights

```{r max minimum nights, include=FALSE}
# max minimum nights & knit into table
kable(listings_all %>% 
  slice_max(minimum_nights, n = 10) %>% 
  select(neighbourhood_group, price, minimum_nights))
```

Any listing with a minimum nights requirement of **over 365 days (greater than 1 year)** will be assumed to be **unreasonable** and therefore **excluded** from the analysis.

```{r exclude unreasonble minimum nights, message=FALSE, warning=FALSE, include=FALSE}
# exclude all listings with a minimum number of nights of more than a year
listings_all <- subset(listings_all, 
                       minimum_nights < 365)
```

Furthermore, there seems to be a legitimate distinction between listings in terms of minimum number of days for length of stay. A listing with a minimum number of nights of **less than 30 days** will be denoted as **Short-term**, whereas listings with minimum number of nights of **greater than or equal to 30 days and less than 1 year** will be denoted as **Long-term**.

```{r demarcate minimum_nights, echo=FALSE}
# a dummy variable of Long-term vs Short-term
listings_all$long_term_rent <- "Short-term"
# loop through each listing and label Long-term for any with 30 or more days of
# minimum number of days
for (i in 1:nrow(listings_all)) {
  if (listings_all[i, "minimum_nights"] >= 30) {
    listings_all[i, "long_term_rent"] <- "Long-term"
  } 
}
# factor the categorical variable for specific ordering in graphing
listings_all$long_term_rent <- factor(listings_all$long_term_rent, levels = c("Short-term",
                                                                              "Long-term"))
# plot distribution of log_price by long_term_rent
listings_all %>% 
  ggplot(.) +
  geom_histogram(mapping = aes(x = log_price, fill = long_term_rent), 
                 alpha = 0.45) +
  labs(title = "log_Price per Duration or Rent",
       x = "log_Price",
       y = "Count") +
  theme(plot.title = element_text(hjust = 0.5))
# write amended data set to file
write_csv(listings_all, "./Data/Manipulated_Data/listings_updated.csv")
```

Approximately **15%** of listings are for **long-term** stays whereas **85%** are for **short-term**. Furthermore, we'll assume that long-term pricing strategies for listings are static and predictable, whereas short-term pricing strategies are more dynamic and less predictable. Based on this, *our analysis will focus on the short-term listings and exclude long-term ones*.

### Sentiment Analysis
When looking at reviews as a customer, one usually looks out for negative reviews. Therefore, we'll assume that *negative reviews have more weight* in comparison to neutral or positive reviews.

Based off that assumption, the categorical variable **review** was created with the following conditional:

- If listing has 1 or more negative reviews, then "review" = HasNegative
- If listing has 0 negative but 1 or more neutral reviews, then "review" = HasNeutral
- If listing has 0 negative and 0 neutral but 1 or more positive reviews, then "review" = Positive
- If listing has no reviews, then "review" = NoReviews

A more appropriate approach might be to assign the category of HasNegative based on a proportion of the negative reviews at a certain threshold. For e.g., if a listing has 10% or more negative reviews from its total reviews, then it should be labeled as HasNegative. However, demarcating such a threshold will have to be assessed (this will be a step we'll conduct post the initial check-in)

```{r review sentiment by neighborhood, echo=FALSE, message=FALSE, warning=FALSE}
# create a new column and loop through each listing
# refer to the markdown text above for the explanation of conditionals
listings_all$review <- "NoReviews"
for (i in 1:nrow(listings_all)) {
  if (listings_all[i, "negative"] >= 1) {
    listings_all[i, "review"] <- "HasNegative"
  } else if (listings_all[i, "neutral"] >= 1) {
    listings_all[i, "review"] <- "HasNeutral"
  } else if (listings_all[i, "positive"] >= 1) {
    listings_all[i, "review"] <- "Positive"
  }
}
# plot the proportion of review by neighbourhood group
ggplot(listings_all) + 
  geom_bar(mapping = aes(x = neighbourhood_group, fill = review), alpha = 0.5, 
           position = 'fill') +
  scale_fill_brewer(palette = 'RdYlBu') +
  labs(title = "Proportions of Sentiment of Listing Reviews",
       x = "Neighborhood Group",
       y = "Proportion") +
  theme(plot.title = element_text(hjust = 0.5))
```

The proportions are strikingly close across neighborhoods. We can see that approximately **50%** of listings have **purely positive reviews** across neighborhoods, with *Queens having the least purely positive reviews*. About **25%** of listings **don't have reviews at all**, most of which are in Manhattan. This hints at short stays that don't necessarily warrant reviews. Lastly, almost **25%** of listings **have negative reviews** across each neighborhood, with Queens having the most. What is negatively affecting reviews in Queens? Is it the hosts? The neighborhoods? The renters?

What about review sentimentality and price?

```{r review sentiment by log_price, echo=FALSE, message=FALSE, warning=FALSE}
# factor review for ordering the categorical levels for graphing
listings_all$review <- factor(listings_all$review, levels = c("Positive",
                                                                  "HasNeutral",
                                                                  "HasNegative",
                                                                  "NoReviews"))
# plot the distribution of log_price by review
listings_all %>% 
  group_by(neighbourhood_group) %>% 
  ggplot() + 
  geom_histogram(mapping = aes(x = log_price, fill = review), alpha = 0.50) +
  labs(title = "Distribution of log_Price per Review Sentiment",
       x = "log_Price",
       y = "Count") +
  theme(plot.title = element_text(hjust = 0.5))
# write amended data set to file
write_csv(listings_all, "./Data/Manipulated_Data/listings_updated.csv")
```
The distributions of review sentimentality and price are strikingly similar, hinting at the fact that either 

a) there might not be a relationship between review sentimentality and price, or 
b) if there's a relationship, it will be a weak one 

This will have to be assessed in section 3 by running a Multiple Linear Regression model using either dummy variables or the quantities of each review sentiment.

### Correlation Matrix
Plotting a correlation matrix can help guide which variable we ought to assess with regards to modeling in section 3.

```{r correlation matrix, echo=FALSE, message=FALSE, warning=FALSE}
# create a data frame of only numerical variable for a correlation matrix
numeric_listings_all <- listings_all %>%
  select(c("price", "minimum_nights", "number_of_reviews", "reviews_per_month", 
           "calculated_host_listings_count", "availability_365", 
           "distance_from_bus_stop", "distance_from_subway_station", "n_cult_orgs", 
           "shooting_number", "calls_911_number", "negative", "positive", "neutral",
           "days_last_rev"))
# Create correlation matrix
cormat <- round(cor(numeric_listings_all),2)
# Function to get lower triangle of the correlation matrix
get_lower_tri<-function(cormat){
  cormat[upper.tri(cormat)] <- NA
  return(cormat)
}
# Function to get upper triangle of the correlation matrix
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}
# Function to reorder correlation matrix
reorder_cormat <- function(cormat){
# Use correlation between variables as distance
dd <- as.dist((1-cormat)/2)
hc <- hclust(dd)
cormat <-cormat[hc$order, hc$order]
}
# Reorder the correlation matrix
cormat <- reorder_cormat(cormat)
upper_tri <- get_upper_tri(cormat)
# Melt the correlation matrix
melted_cormat <- melt(upper_tri, na.rm = TRUE)
# Create a heatmap
ggheatmap <- ggplot(melted_cormat, aes(Var2, Var1, fill = value))+
 geom_tile(color = "white")+
 scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
   midpoint = 0, limit = c(-1,1), space = "Lab", 
    name="Pearson\nCorrelation") +
  theme_minimal()+ # minimal theme
 theme(axis.text.x = element_text(angle = 45, vjust = 1, 
    size = 9, hjust = 1))+
 coord_fixed()
# Plot gg heatmap with values on graph as text
ggheatmap + 
geom_text(aes(Var2, Var1, label = value), color = "black", size = 1.75) +
theme(
  axis.title.x = element_blank(),
  axis.title.y = element_blank(),
  panel.grid.major = element_blank(),
  panel.border = element_blank(),
  panel.background = element_blank(),
  axis.ticks = element_blank(),
  legend.justification = c(1, 0),
  legend.position = c(0.5, 0.6),
  legend.direction = "horizontal") +
  guides(fill = guide_colorbar(barwidth = 5, barheight = 1,
                title.position = "top", title.hjust = 0.5)) +
  labs(title = "Correlation Heatmap of Numerical Variables") +
  theme(plot.title = element_text(hjust = 0.5))
# Source of code for correlation heatmap plot: http://www.sthda.com/english/wiki/ggplot2-quick-correlation-matrix-heatmap-r-software-and-data-visualization
```

We can see that review sentimentality, number of reviews, and reviews per month are *highly positively (+0.5) correlated* with one another. The same 3 variables are highly negatively correlated with days since last review. Interestingly, number of shootings and distance from bus stops is also highly negatively correlated. Unfortunately, we can see that there is not much correlation between price and all these numerical variables. This could likely be due to the fact that not all variables have linear relationships. This also suggests that perhaps categorical variables in the form of dummy variables would be better explanatory variables for price. 


## Thought Process Adjustments:

We came to realize that a few of our variables have skewed distributions which warrant log transformations:

1. `demand`
2. `number_of_reviews`
3. `reviews_per_month`
4. `calls_911_number`
5. `negative`
6. `neutral`
7. `positive`
8. `negative_prop` (proportion)
9. `neutral_prop`
10. `positive_prop`
11. `days_last_review`


```{r demand, echo=FALSE}
# create demand variable
listings_w_demand <- listings_all %>% 
  mutate(demand <- 365 - availability_365) %>% 
  rename(demand = "demand <- 365 - availability_365") %>% 
  select(-availability_365, log_price)
listings_w_demand <- listings_w_demand %>% 
  mutate(price_log = log(price))
listings_w_demand <- listings_w_demand %>% 
  mutate(distance_from_transportation = ifelse(distance_from_subway_station 
                                               <= distance_from_bus_stop, 
                                                 distance_from_subway_station, 
                                                 distance_from_bus_stop))
listings_w_demand <- listings_w_demand %>%
  mutate(negative_prop = negative / number_of_reviews,
         neutral_prop = neutral / number_of_reviews,
         positive_prop = positive / number_of_reviews)
```

```{r transformations, include=FALSE}
# which variables need transformations?
# demand - maybe to get rid of value 365?
listings_w_demand %>% 
  ggplot(., aes(demand)) + 
  geom_histogram()
# number_of_reviews - skewed > log?
listings_w_demand %>% 
  ggplot(., aes(number_of_reviews)) + 
  geom_histogram()
# reviews_per_month - skewed > log?
listings_w_demand %>% 
  ggplot(., aes(reviews_per_month)) + 
  geom_histogram()
# distance_from_subway_station
listings_w_demand %>% 
  ggplot(., aes(distance_from_subway_station)) + 
  geom_histogram()
# distance_from_bus_stop
listings_w_demand %>% 
  ggplot(., aes(distance_from_bus_stop)) + 
  geom_histogram()
# distance_from_transportation
listings_w_demand %>% 
  ggplot(., aes(distance_from_transportation)) + 
  geom_histogram()
# n_cult_orgs
listings_w_demand %>% 
  ggplot(., aes(n_cult_orgs)) + 
  geom_histogram()
# shooting_number - skewed > log?
listings_w_demand %>% 
  ggplot(., aes(shooting_number)) + 
  geom_histogram()
# calls_911_number - there are some outliers, take them out?
listings_w_demand %>% 
  ggplot(., aes(calls_911_number)) + 
  geom_histogram()
# negative - skewed > log?
listings_w_demand %>% 
  ggplot(., aes(negative)) + 
  geom_histogram()
# neutral - skewed > log?
listings_w_demand %>% 
  ggplot(., aes(neutral)) + 
  geom_histogram()
# positive - skewed > log?
listings_w_demand %>% 
  ggplot(., aes(positive)) + 
  geom_histogram()
# days_last_rev - there is strong outlier (delete > 3100?) and skewness
listings_w_demand %>% 
  ggplot(., aes(days_last_rev)) + 
  geom_histogram()
# entire_home_apt
listings_w_demand %>% 
  ggplot(., aes(entire_home_apt)) + 
  geom_histogram()
# negative_prop - skewed > log?
listings_w_demand %>% 
  ggplot(., aes(negative_prop)) + 
  geom_histogram()
# neutral_prop - skewed > log?
listings_w_demand %>% 
  ggplot(., aes(neutral_prop)) + 
  geom_histogram()
# positive_prop - skewed > log?
listings_w_demand %>% 
  ggplot(., aes(positive_prop)) + 
  geom_histogram()
################################################################################
# transform skewed distributions to log
listings_w_demand <- listings_w_demand %>% 
  mutate(demand = demand + 1) %>% 
  mutate(demand_log = log(demand))
listings_w_demand <- listings_w_demand %>% 
  mutate(number_of_reviews_log = log(number_of_reviews))
listings_w_demand <- listings_w_demand %>% 
  mutate(reviews_per_month_log = log(reviews_per_month))
listings_w_demand <- listings_w_demand %>% 
  mutate(shooting_number_log = log(shooting_number))
calls_911_number_median <- median(listings_w_demand$calls_911_number)
listings_w_demand <- listings_w_demand %>% 
  mutate(calls_911_number = ifelse(calls_911_number < 12500 | calls_911_number > 75000, 
                                   calls_911_number_median, calls_911_number))
listings_w_demand <- listings_w_demand %>% 
  mutate(negative = negative + 1) %>% 
  mutate(negative_log = log(negative))
listings_w_demand <- listings_w_demand %>% 
  mutate(neutral = neutral + 1) %>% 
  mutate(neutral_log = log(neutral))
listings_w_demand <- listings_w_demand %>% 
  mutate(positive = positive + 1) %>% 
  mutate(positive_log = log(positive))
listings_w_demand <- listings_w_demand %>% 
  mutate(negative_prop = negative_prop + 0.000001) %>% 
  mutate(negative_prop_log = log(negative_prop))
listings_w_demand <- listings_w_demand %>% 
  mutate(neutral_prop = neutral_prop + 0.000001) %>% 
  mutate(neutral_prop_log = log(neutral_prop))
listings_w_demand <- listings_w_demand %>% 
  mutate(positive_prop = positive_prop + 0.000001) %>% 
  mutate(positive_prop_log = log(positive_prop))
listings_w_demand <- listings_w_demand %>% 
  mutate(days_last_rev_log = log(days_last_rev))
# write amended data set to the file
write_csv(listings_w_demand, "./Data/Manipulated_Data/listings_w_transformations.csv")
```

Other than those transformations, there will be no major adjustments other than the aspect in which we will assess the relationships between all the aforementioned variables and price. When looking at each variable, we'll have to split the modeling based on specific categories such as listing type (`Entire home/apt`), rent duration (`long_term_rent`), and `neighborhood group`. Furthermore, when assessing review sentimentality, we will attempt a variety of approaches by looking at sentimentality as a number, factor, and proportion.

# Modelling

## Model Benchmark

First, let's see how much of price is explained by the entire list of 15 aforementioned variables. This is with the addition of the sentiment_review_proportions, making it a total of 18 variables:

```{r model 01 - adj r squared, echo=FALSE}
model_1 <- listings_w_demand %>% 
  lm(formula = price_log ~ 
               demand_log 
             + number_of_reviews_log
             + reviews_per_month_log 
             + distance_from_subway_station
             + distance_from_bus_stop
             + n_cult_orgs 
             + shooting_number_log 
             + calls_911_number
             + negative_log
             + neutral_log
             + positive_log
             + days_last_rev_log
             + entire_home_apt
             + distance_from_transportation
             + negative_prop_log
             + neutral_prop_log
             + positive_prop_log
             + calculated_host_listings_count
     , data = .)
cat("Adjusted R squared:", summary(model_1)$adj.r.squared)
```
So the list of variables we're assessing can explain up to 44% of the price of an Airbnb listing. But which variables truly play a role? i.e. which variables can be neglected? 

```{r model 01 - p-values, echo=FALSE}
kable(tidy(model_1))
```
From the above table, we can see that some variables can be excluded from further modeling because they are statistically insignificant, i.e. they have a p-value greater than 0.05:

- `distance_from_subway_station`
- `neutral_log`
- `neutral_prop_log`

For the rest of the variables, we can reject $H0_i$ at a confidence level of 95% (significance level 0.05). But first we have to run a few more models to be sure.

Furthermore, we can see that **some variables have a inverse relationship with price**, i.e. when this variable increases, price is likely to decrease. These are the variables along with a rational explanations for the inverse relationship:

- `demand_log`: this makes sense based off the law of demand which states price and demand are inversely related, so that if price decreases, demand will increase.
- `number_of_reviews_log`: hosts with a large number of reviews possibly set low prices to attract more customers.
- `distance_from_bus_stop`: if a listing is further away from bus stops, it will cost less because of a low transportation score.
- `shooting_number_log`: a listings with a higher recorded number of shootings in the area will have a lower price due to a decreased sense of safety.
- `calls_911_number`: same as the variable above.
- `negative_log`: the more negative reviews a listing has, the lower the price will be. This is so hosts can attract price-sensitive customers that're willing to overlook a bad reputation.
- `calculated_host_listings_count`: this is likely due to the fact that hosts with a higher number of listings normally set lower prices to attract more customers.

On the other hand, **some variables have a positive relationship with price**, i.e. when this variable increases, price is likely to increase with it:

- `reviews_per_month_log`: this actually raises another question, why is it that an increase in the number of reviews per month increases price, whereas an increase in the total number of reviews decreases price?
- `n_cult_orgs`: the more tourist attractions nearby a listing, the higher the price.
- `positive_log`: the more positive reviews a listing has, the higher the price.
- `days_last_rev_log`: the higher the number of days since the last review for a listing, the higher the price.
- `entire_home_apt`: the type of listing has the most significant impact on price (this reiterates the aforementioned previous findings).
- `distance_from_transportation`: the coefficient for this variable is non-intuitive, because it states that the higher the distance from transportation, the higher the price. Perhaps the explanation is that we already used `distance_from_bus_stop` and `distance_from_subway_station` so `distance_from_transportation` brings an insignificant correction.


Now let's assess the relationship of statistically significant variables with price grouped under these categories:

1. `long_term_rent`
2. `neighborhood group`
3. `review`

## Model by Neighborhood

```{r model 02 - neighborhood adj r squared, echo=FALSE}
cat("Adjusted R squared:\n\n")
model_02 <- listings_w_demand %>% 
            split(.$neighbourhood_group) %>% 
            map(function(x) lm(formula = price_log ~ 
                                         demand_log 
                                       + number_of_reviews_log
                                       + reviews_per_month_log 
                                       + distance_from_bus_stop
                                       + n_cult_orgs 
                                       + shooting_number_log 
                                       + calls_911_number
                                       + negative_log
                                       + positive_log
                                       + days_last_rev_log
                                       + entire_home_apt
                                       + distance_from_transportation
                                       + negative_prop_log
                                       + neutral_prop_log
                                       + positive_prop_log
                                       + calculated_host_listings_count
                               , data = x)) %>%
          map(summary)
model_02 %>% 
  map(~.$adj.r.squared)
```
Interestingly, the **adjusted r squared** changes across neighborhoods. For Queens, it's identical to the first overarching model run at **44%**. For Brooklyn and Manhattan, it increased to **48%** and decreased to **35%** respectively. This means our model is best at explaining the price of an Airbnb listing in Brooklyn. It also means there are lurking variables that one ought to consider when it comes to pricing Airbnb listings in Manhattan.

```{r model 02 - neighborhood p-values, echo=FALSE, results='hide'}
model_02
```

The variables being assessed for a relationship with price behave differently depending on the neighborhood of the listing. These are the statistically significant variables per neighborhood:

| Brooklyn       | Manhattan           | Queens  |
| :------------- |:-------------| :-----|
| demand_log      | demand_log | demand_log |
| distance_from_bus_stop      | number_of_reviews_log      | reviews_per_month_log |
| n_cult_orgs | reviews_per_month_log      | n_cult_orgs |
| shooting_number_log | n_cult_orgs      | calls_911_number |
| calls_911_number | shooting_number_log     | negative_log |
| negative_log | negative_log      | days_last_rev_log |
| days_last_rev_log | positive_log      | calculated_host_listings_count |
| distance_from_transportation | days_last_rev_log     |  entire_home_apt   |
| calculated_host_listings_count | distance_from_transportation      |     |
| entire_home_apt | calculated_host_listings_count      |   |
|  | entire_home_apt    |   |

The variables that are statistically significant across all neighborhoods are:

- `demand_log`
- `n_cult_orgs`
- `negative_log`
- `days_last_rev_log`
- `calculated_host_listings_count`
- `entire_home_apt`

## Model by Rent Duration

```{r model 03 - rent duration adj r squared, echo=FALSE}
cat("Adjusted R squared:\n\n")
model_03 <- listings_w_demand %>% 
            split(.$long_term_rent) %>% 
            map(function(x) lm(formula = price_log ~ 
                                         demand_log 
                                       + number_of_reviews_log
                                       + reviews_per_month_log 
                                       + distance_from_bus_stop
                                       + n_cult_orgs 
                                       + shooting_number_log 
                                       + calls_911_number
                                       + negative_log
                                       + positive_log
                                       + days_last_rev_log
                                       + entire_home_apt
                                       + distance_from_transportation
                                       + negative_prop_log
                                       + neutral_prop_log
                                       + positive_prop_log
                                       + calculated_host_listings_count
                               , data = x)) %>%
          map(summary)
model_03 %>% 
  map(~.$adj.r.squared)
```
The **adjusted r squared** doesn't differ significantly across durations of rent. For Short-term, it's identical to the first overarching model run at **44%**. For Long-term, it increased to **49%**. This means our model is best at explaining the price of an Airbnb listing that is long-term rather than short-term. This makes sense intuitively, because long-term pricing is more static and easier to predict, whereas short-term pricing is more dynamic and more difficult to predict.

```{r model 03 - rent p-values, echo=FALSE, results='hide'}
model_03 
```
Just as the variables behaved differently when being assessed by neighborhood, the same applies when being assessed by rent duration. These are the statistically significant variables per rent duration:

| Long-term       | Short-term  |
| :-------------- |:-------------|
| demand_log      | demand_log |
| number_of_reviews_log | reviews_per_month_log   |
| reviews_per_month_log | distance_from_bus_stop   |
| n_cult_orgs | n_cult_orgs      |
| shooting_number_log | shooting_number_log     |
| calls_911_number | calls_911_number      |
| negative_log | negative_log      |
| positive_log | days_last_rev_log     |
| days_last_rev_log | entire_home_apt      |
| entire_home_apt | distance_from_transportation      |
| calculated_host_listings_count | negative_prop_log    |
|                           | calculated_host_listings_count    |

The variables that are statistically significant across both rent durations are:

- `demand_log`
- `reviews_per_month_log`
- `n_cult_orgs`
- `shooting_number_log`
- `calls_911_number`
- `negative_log`
- `days_last_rev_log`
- `calculated_host_listings_count`
- `entire_home_apt`

## Model by Review Sentiment
```{r model 04 - review adj r squared, echo=FALSE}
cat("Adjusted R squared:\n\n")
model_04 <- listings_w_demand %>% 
            split(.$review) %>% 
            map(function(x) lm(formula = price_log ~ 
                                         demand_log 
                                       + distance_from_bus_stop
                                       + n_cult_orgs 
                                       + shooting_number_log 
                                       + calls_911_number
                                       + negative_log
                                       + positive_log
                                       + days_last_rev_log
                                       + entire_home_apt
                                       + distance_from_transportation
                                       + calculated_host_listings_count
                               , data = x)) %>%
          map(summary)
model_04 %>% 
  map(~.$adj.r.squared)
```
The **adjusted r squared** doesn't differ significantly across types of reviews. Listings with no reviews can explain approximately 39% of price, whereas listings that have Negative or Neutral reviews can explain 45% and 47% respectively. Lastly, listings with purely positive reviews can explain about 43% of price. WHAT CAN WE SEE?

```{r model 04 - review p-values, echo=FALSE, results='hide'}
model_04
```

These are the statistically significant variables per review:

| Positive      | HasNeutral  | HasNegative      | NoReviews  |
| :-------------- |:-------------|:-------------|:-------------|
| demand_log      | demand_log | demand_log      | demand_log |
| distance_from_bus_stop | distance_from_bus_stop | distance_from_bus_stop | distance_from_bus_stop   |
| n_cult_orgs | n_cult_orgs | n_cult_orgs | n_cult_orgs |
| shooting_number_log | shooting_number_log | shooting_number_log | shooting_number_log |
| positive_log | positive_log | positive_log |  |
| | | negative_log | |
| days_last_rev_log | days_last_rev_log | days_last_rev_log |  |
| | | calls_911_number | calls_911_number|
| entire_home_apt | entire_home_apt | entire_home_apt | entire_home_apt |
| distance_from_transportation |  | distance_from_transportation | distance_from_transportation |
| calculated_host_listings_count | calculated_host_listings_count | calculated_host_listings_count | calculated_host_listings_count |

The variables that are statistically significant across types of reviews are:

- `demand_log`
- `distance_from_bus_stop`
- `n_cult_orgs`
- `shooting_number_log`
- `calls_911_number`
- `entire_home_apt`
- `calculated_host_listings_count`

## Model Comparison

The three models we looked at are:

1. Model Set 1 - 3 Models Categorized by Neighborhood Group
2. Model Set 2 - 2 Models Categorized by Rent Duration
3. Model Set 3 - 4 Models Categorized by Review Sentiment

The variables that are statistically significant within each set of models are:

| Model Set 1      | Model Set 2  | Model Set 3      |
| :-------------- |:-------------|:-------------|
| demand_log      | demand_log | demand_log      |
|  |  | distance_from_bus_stop |
| | reviews_per_month_log | |
| n_cult_orgs | n_cult_orgs | n_cult_orgs |
|  | shooting_number_log | shooting_number_log |
| negative_log | negative_log |  |
| days_last_rev_log | days_last_rev_log |  |
| | calls_911_number | calls_911_number |
| entire_home_apt | entire_home_apt | entire_home_apt |
| distance_from_transportation |  | distance_from_transportation |
| calculated_host_listings_count | calculated_host_listings_count | calculated_host_listings_count |

The variables that are statistically significant across all models or at least 2 models are:

| All Model Sets     | Two Model Sets |
| :-------------- |:-------------|
| demand_log      | demand_log |
| n_cult_orgs | n_cult_orgs |
| calculated_host_listings_count | calculated_host_listings_count |
| entire_home_apt | entire_home_apt |
|  | distance_from_transportation |
|  | shooting_number_log |
|  | negative_log |
|  | days_last_rev_log |
| | calls_911_number |


## Model Conclusion

Now we build our final model with all the variables that are statistically significant in at least two of our previous models. How much of price can be explained?

*Note*: `distance_from_transportation` and `calls_911_number` were removed due to being statistically insignificant after our initial run of the model

```{r model 05 - adj r squared, echo=FALSE}
model_05 <- listings_w_demand %>% 
    lm(formula = price_log ~ 
                 demand_log 
               + n_cult_orgs 
               + entire_home_apt
               + calculated_host_listings_count
               # + distance_from_transportation # statistically insignificant in this model
               + shooting_number_log
               + negative_log
               + days_last_rev_log
               # + calls_911_number     # statistically insignificant in this model
               , data = .)
cat("Adjusted R squared:", summary(model_05)$adj.r.squared)
```
```{r model 05 - summary, echo=FALSE, results='hide'}
model_05 %>% summary()
```

Our final model with 7 variables has 42% explanatory power whereas our initial model had 44%. That's approximately 2% decrease when compared to the initial model which tested 18 variables. Barely any change in explanatory power but less than half the number of variables were used. Therefore, although the explanatory power decreases slightly, the simplicity of the model increases substantially (reduced from 18 variables to 7).

One important note is that one of our variables `entire_home_apt` was already inferred to have a strong relationship with price in our Section 1.2 Review of Previous Findings. We chose to include this variable in our analysis because it is extremely significant in such a way that if we didn't use the variable, we'd have to split the data set and analyze each one separately (doubling the number of models).

Moreover, our final model that has an explanatory power of 42% explains more when it comes to price than the model found in the review of previous findings with an explanatory power of 27% (Magno *et al.*, 2018).

# Communication

So what factors should we consider when attempting to solve the pricing problem of an Airbnb listing? More specifically...

----------------------------------------------------------------------------

<center><b><em>Which criteria has a statistically significant relationship with the price of an Airbnb listing in NYC?</em></b></center>

----------------------------------------------------------------------------

Let's revise the aforementioned list of 14 null hypotheses (Section 1.3 - Though Process). The null hypotheses crossed out have been rejected due to statistical significance (i.e. a p-value of less than 0.1):

- **H0<sub>1</sub>**: The price of a listing is not related to the **number of reviews** the accommodation received
- **H0<sub>2</sub>**: The price of a listing is not related to the **number of reviews per month** the accommodation received
- <strike>**H0<sub>3</sub>**: The price of a listing is not related to the listing's **demand**</strike>
- **H0<sub>4</sub>**: The price of a listing is not related to its **distance from subway stations**
- **H0<sub>5</sub>**: The price of a listing is not related to its **distance from bus stops**
- <strike>**H0<sub>6</sub>**: The price of a listing is not related to the **number of cultural organizations nearby**</strike>
- <strike>**H0<sub>7</sub>**: The price of a listing is not related to the **number of shootings nearby**</strike>
- **H0<sub>8</sub>**: The price of a listing is not related to the **number of 911 calls nearby**
- <strike>**H0<sub>9</sub>**: The price of a listing is not related to its **number of negative reviews**</strike>
- **H0<sub>10</sub>**: The price of a listing is not related to its **number of neutral reviews**
- **H0<sub>11</sub>**: The price of a listing is not related to its **number of positive reviews**
- <strike>**H0<sub>12</sub>**: The price of a listing is not related to the **number of days since its last review**</strike>
- <strike>**H0<sub>13</sub>**: No difference exists between the price of an **entire apartment** and that of a **private room**</strike>
- <strike>**H0<sub>14</sub>**: The price of a listing is not related to the **number of listings a host has**</strike>

Now we're left with these 7 alternative hypotheses as answers to our question and possible solutions to the pricing problem:

- **HA<sub>1</sub>**: The price of a listing *is* related to the listing's **demand**
- **HA<sub>2</sub>**: The price of a listing *is* related to the **number of shootings nearby**
- **HA<sub>3</sub>**: The price of a listing *is* related to its **number of negative reviews**
- **HA<sub>4</sub>**: The price of a listing *is* related to its **number of cultural organizations nearby**
- **HA<sub>5</sub>**: The price of a listing *is* related to its **number of days since its last review**
- **HA<sub>6</sub>**: The price of a listing *is* related to the **number of listings a host has**
- **HA<sub>7</sub>**: A difference *exists* between the price of an **entire apartment** and that of a **private room**

So these are the criteria which have a statistically significant relationship with the price of an Airbnb listing in New York. But what about the impact of each criteria on price?

```{r regression model findings, echo=FALSE, message=FALSE, warning=FALSE}
table_of_impact <- data.frame(summary(model_05)[4]) %>% 
    select(-2, -3) %>% 
    slice(2:10) %>% 
    filter(coefficients.Pr...t.. < 0.1) %>%
    rename(percent_of_impact = "coefficients.Estimate", p_value = "coefficients.Pr...t..") %>% 
    arrange(desc(abs(percent_of_impact)))
    
table_of_impact$percent_of_impact <- round(table_of_impact$percent_of_impact * 100, 2)
table_of_impact$p_value <- round(table_of_impact$p_value, 3)
variable_description <- c("Entire home/apartment (dummy) (vs private/shared room)",
                          "Number of shootings nearby the listing (logarithm transformed)",
                          "Number of days the listing is not available in a year (logarithm transformed)",
                          "Number of days past since a listing received a review (logarithm transformed)",
                          "Number of tourist attractions nearby the listing",
                          "Number of negative reviews a listing has (logarithm transformed)",
                          "Number of total listings currently on Airbnb by a single host")
table_of_impact$variable_description <- variable_description
table_of_impact <- table_of_impact[, c("variable_description", 
                                       "percent_of_impact", 
                                       "p_value")]
kable(table_of_impact)
```


```{r results plot, echo=FALSE}
theme_set(theme_sjplot())
# Plot results of regression model 05
plot_model(model_05,
           vline.color = "azure3",
           sort.est = TRUE, 
           show.values = TRUE, value.offset = .3,
           title = "Final Model, Variable Performance") +
  theme(plot.title = element_text(hjust = 0.5, vjust = 1))
```


Here we can see that our findings both reiterate previous findings as well as add onto them...

Both in our analysis and previous findings, the variable `entire_home_apt` has the highest impact on the price of a listing.

The adding onto previous findings comes along with the assessment of the unique variables of:

1. Number of shootings (`shooting_number_log`): high negative impact
2. Demand (`demand_log`): medium negative impact
3. Days since last review (`days_last_rev_log`): medium positive impact
4. Number of cultural organizations nearby (`n_cult_orgs`): medium positive impact
5. Number of listings per host (`calculated_host_listings_count`): low negative impact
6. Has negative reviews (`negative_log`): low negative impact

In regards to #2, we used a different approach in computing the demand of a listing that resulted with a higher explanatory power in comparison to that of previous findings in Section 1.2.

Furthermore, in regards to #3, the idea that less reviews (or at least an increased elapsed time between reviews) positively impacts price also reiterates previous findings:

"In addition, the findings show that the number of reviews received on Airbnb by an accommodation is negatively correlated to its price. This result is consistent with the evidence provided by Gibbs et al. (2018), who suggested that the lower the price, the higher the number of bookings and, in turn, the higher the number of reviews." (Magno *et al.*, 2018)

In conclusion, the **three major insights** we can derive from our analysis (that was not found in previous research) are:
<br>

--------------------------------------------------------------------------------
1. Number of shootings in a neighborhood, which we have chosen as a criminal ratio, has a significant negative impact on price.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
2. Number of tourist attractions nearby the listing have a significant positive impact on the price.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
3. Existence of negative reviews has a significant negative impact on the price.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


# Appendix

## Data Sources
```{r data sources, echo=FALSE, message=FALSE, warning=FALSE}
# import data sources
data_sources <- read_csv(file = "./Data/Markdown_Data/data_sources.csv")
# knit into a table
kable(data_sources)
```
## Snippets of Original Data
<br>
**01) Airbnb Listings in NYC:**
```{r data snippets 01, echo=FALSE, message=FALSE, warning=FALSE}
# print the first 5 rows of data frame
head(original_listings, n=5)
```
<br>
**02) NYC Transit Subway:**
```{r data snippets 02, echo=FALSE, message=FALSE, warning=FALSE}
# print the first 5 rows of data frame
head(subway, n=5)
```
<br>
**03) NYC Bus Stops:**
```{r data snippets 03, echo=FALSE, message=FALSE, warning=FALSE}
# print the first 5 rows of data frame
head(bus, n=5)
```
<br>
**04) DCLA Cultural Organizations:**
```{r data snippets 04, echo=FALSE, message=FALSE, warning=FALSE}
# print the first 5 rows of data frame
head(cult_orgs, n=5)
```
<br>
**05) NYPD Shooting Incidents:**
```{r data snippets 05, echo=FALSE, message=FALSE, warning=FALSE}
# print the first 5 rows of data frame
head(shooting_2020, n=5)
```
<br>
**06) NYPD Calls for Service:**
```{r data snippets 06, echo=FALSE, message=FALSE, warning=FALSE}
# print the first 5 rows of data frame
head(calls_911, n=5)
```
<br>
**07) Airbnb Listing Reviews:**
```{r data snippets 07, echo=FALSE, message=FALSE, warning=FALSE}
# print the first 5 rows of data frame
head(calls_911, n=5)
```

## Sentiment Analysis

Please check "./Sentiment_Analysis" for the R scripts used to conduct our sentiment analysis on Airbnb listing reviews. The order of scripts and their respective functions is as follows:

1. reviews_files.R - used to create a new folder with txt files of reviews with names [review_id].txt (didn't include them, there are 1M+ of them)

2. files_processing_bing.R

3. file_processing_nrc.R

4. files_processing_afinn.R

All these scripts make up the sentiment analysis. The accuracy comparing with Monkeylearn (an online software that automatically conducts sentiment analysis) was 0.903, 0.907, 0.907. For the full analysis we used file_processing_nrc.R because it gave better results in terms of prediction of negative reviews.

5. checking_model.R - used to validate algorithms comparing with Monkeylearn prediction and threshold adjustments.

# References
Magno, F., Cassia, F., Ugolini, M. M. (2018). "Accomodation prices on Airbnb: effects of host experience and market demand". TQM Journal. Volume 30 Number 5. Pages 608-620.

Li, J., Moreno, A. and Zhang, D.J. (2015), “Agent behavior in the sharing economy: evidence from Airbnb”,Working paper, [1298] Ross School of Business, University of Michigan, Ann Arbor, MI.
