data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression.csv")
# str(data)
# summary(data)


# # regression for demand
# lm(formula = demand ~ 
#      price 
#    + number_of_reviews 
#    + reviews_per_month 
#    + distance_from_subway_station 
#    + distance_from_bus_stop 
#    + n_cult_orgs 
#    + shooting_number 
#    + calls_911_number 
#    + negative 
#    + neutral 
#    + nositive 
#    + days_last_rev 
#    + entire_home_apt, 
#    data = data) %>% 
#   summary()
# 
# # regression for demand without variables with high p-values
# lm(formula = demand ~ 
#      price 
#    # + number_of_reviews 
#    + reviews_per_month 
#    # + distance_from_subway_station 
#    + distance_from_bus_stop 
#    + n_cult_orgs 
#    # + shooting_number 
#    + calls_911_number 
#    + negative 
#    + neutral 
#    + nositive 
#    + days_last_rev 
#    + entire_home_apt,  
#    data = data) %>% 
#   summary()


data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression.csv")

# regression for price_log
lm(formula = price_log ~ 
     demand 
   + number_of_reviews 
   + reviews_per_month 
   + distance_from_subway_station 
   + distance_from_bus_stop 
   + n_cult_orgs 
   + shooting_number 
   + calls_911_number 
   + negative 
   + neutral 
   + positive 
   + days_last_rev 
   + entire_home_apt
   + distance_from_transportation
   + negative_prop
   + neutral_prop
   + positive_prop
   , data = data) %>% 
   summary()

# regression for price_log without variables with high p-values
lm(formula = price_log ~ 
      demand 
   # + number_of_reviews 
   + reviews_per_month 
   # + distance_from_subway_station 
   # + distance_from_bus_stop 
   + n_cult_orgs 
   + shooting_number 
   # + calls_911_number 
   # + negative 
   # + neutral 
   # + positive 
   + days_last_rev 
   + entire_home_apt
   + distance_from_transportation
   + negative_prop
   + neutral_prop
   + positive_prop, 
   data = data) %>% 
   summary()


lm(formula = price_log ~ 
      demand 
   # + number_of_reviews 
   + reviews_per_month 
   # + distance_from_subway_station 
   + distance_from_bus_stop
   + n_cult_orgs 
   + shooting_number 
   # + calls_911_number 
   # + negative 
   # + neutral 
   # + positive 
   # + days_last_rev 
   + entire_home_apt
   # + distance_from_transportation
   + negative_prop, 
   # + neutral_prop
   # + positive_prop, 
   data = data) %>% 
   summary()


data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression.csv")
# regression for price
lm(formula = price ~ 
      demand 
   + number_of_reviews 
   + reviews_per_month 
   + distance_from_subway_station 
   + distance_from_bus_stop 
   + n_cult_orgs 
   + shooting_number 
   + calls_911_number 
   + negative 
   + neutral 
   + positive 
   + days_last_rev 
   + entire_home_apt
   + distance_from_transportation
   + negative_prop
   + neutral_prop
   + positive_prop
   , data = data) %>% 
   summary()


data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression.csv")
# regression for price
# price_log gives a bit better R2, but price is more illustrative. As soon as we 
# are not going to make predictions, we can use price because eventually
# the variables which have impact in both cases are the same
lm(formula = price ~ 
      demand 
   # + number_of_reviews 
   + reviews_per_month 
   # + distance_from_subway_station
   + distance_from_bus_stop
   + n_cult_orgs 
   + shooting_number 
   # + calls_911_number 
   # + negative 
   # + neutral 
   # + positive 
   # + days_last_rev 
   + entire_home_apt
   + distance_from_transportation
   + negative_prop
   # + neutral_prop
   # + positive_prop
   , data = data) %>% 
   summary()

