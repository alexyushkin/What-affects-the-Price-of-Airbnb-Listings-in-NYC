data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression.csv")
# regression for price
lm(formula = price_log ~ 
     demand
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
   , data = data) %>% 
    summary()


# regression for price wo variables with bad p-values
lm(formula = price_log ~ 
       demand 
   # + number_of_reviews_log
   # + reviews_per_month_log
   # + distance_from_subway_station
   + distance_from_bus_stop
   + n_cult_orgs 
   + shooting_number_log
   # + calls_911_number
   + negative_log
   # + neutral_log
   # + positive_log
   + days_last_rev_log
   + entire_home_apt
   # + distance_from_transportation
   # + negative_prop_log
   # + neutral_prop_log
   # + positive_prop_log
   , data = data) %>% 
    summary()


data %>% 
    split(.$neighbourhood_group) %>% 
    map(function(x) lm(formula = price_log ~ 
                         demand 
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
                       , data = x)) %>% 
    map(summary) %>% 
    map(~.$r.squared)

# demand wo log
# $Bronx
# [1] 0.3605622
# 
# $Brooklyn
# [1] 0.4048011
# 
# $Manhattan
# [1] 0.3672848
# 
# $Queens
# [1] 0.3439501
# 
# $`Staten Island`
# [1] 0.6137846


data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression.csv")
# regression for price
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
   , data = data) %>% 
    summary()


# regression for price wo variables with bad p-values
lm(formula = price_log ~ 
       demand_log 
   # + number_of_reviews_log
   # + reviews_per_month_log
   # + distance_from_subway_station
   + distance_from_bus_stop
   + n_cult_orgs 
   + shooting_number_log
   # + calls_911_number
   + negative_log
   # + neutral_log
   # + positive_log
   + days_last_rev_log
   + entire_home_apt
   # + distance_from_transportation
   # + negative_prop_log
   # + neutral_prop_log
   # + positive_prop_log
   , data = data) %>% 
    summary()


data %>% 
    split(.$neighbourhood_group) %>% 
    map(function(x) lm(formula = price_log ~ 
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
                       , data = x)) %>% 
    map(summary)
# %>%
#     map(~.$r.squared)

# $Bronx
# [1] 0.3762767
# 
# $Brooklyn
# [1] 0.4023727
# 
# $Manhattan
# [1] 0.3661388
# 
# $Queens
# [1] 0.3446073
# 
# $`Staten Island`
# [1] 0.6146547