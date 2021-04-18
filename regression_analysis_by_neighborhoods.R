data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression.csv")
# regression for price
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
   # + distance_from_transportation
   + negative_prop
   # + neutral_prop
   # + positive_prop
   , data = data) %>% 
    summary()


data %>% 
    split(.$neighbourhood_group) %>% 
    map(function(x) lm(formula = price ~ 
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
                       , data = x)) %>% 
    map(summary) %>% 
    map(~.$r.squared)



