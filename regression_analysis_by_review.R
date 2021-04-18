data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression_review_cutoff_10percent.csv")

data %>% 
    split(.$review) %>% 
    map(function(x) lm(formula = price_log ~ 
                         demand 
                       + number_of_reviews_log
                       + reviews_per_month_log
                       + distance_from_subway_station
                       + distance_from_bus_stop
                       + n_cult_orgs
                       + shooting_number_log
                       + calls_911_number
                       # + negative_log
                       # + neutral_log
                       # + positive_log
                       + days_last_rev_log
                       + entire_home_apt
                       + distance_from_transportation
                       # + negative_prop_log
                       # + neutral_prop_log
                       # + positive_prop_log
                       , data = x)) %>% 
    map(summary) %>% 
    map(~.$r.squared)


data %>% 
    split(.$review) %>% 
    map(function(x) lm(formula = price_log ~ 
                           demand 
                       + number_of_reviews_log
                       + reviews_per_month_log
                       + distance_from_subway_station
                       + distance_from_bus_stop
                       + n_cult_orgs
                       + shooting_number_log
                       + calls_911_number
                       # + negative_log
                       # + neutral_log
                       # + positive_log
                       + days_last_rev_log
                       + entire_home_apt
                       + distance_from_transportation
                       # + negative_prop_log
                       # + neutral_prop_log
                       # + positive_prop_log
                       , data = x)) %>% 
    map(summary)



data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression_review_cutoff_1review.csv")

data %>% 
    split(.$review) %>% 
    map(function(x) lm(formula = price_log ~ 
                           demand 
                       + number_of_reviews_log
                       + reviews_per_month_log
                       + distance_from_subway_station
                       + distance_from_bus_stop
                       + n_cult_orgs
                       + shooting_number_log
                       + calls_911_number
                       # + negative_log
                       # + neutral_log
                       # + positive_log
                       + days_last_rev_log
                       + entire_home_apt
                       + distance_from_transportation
                       # + negative_prop_log
                       # + neutral_prop_log
                       # + positive_prop_log
                       , data = x)) %>% 
    map(summary) %>% 
    map(~.$r.squared)


data %>% 
    split(.$review) %>% 
    map(function(x) lm(formula = price_log ~ 
                           demand 
                       + number_of_reviews_log
                       + reviews_per_month_log
                       + distance_from_subway_station
                       + distance_from_bus_stop
                       + n_cult_orgs
                       + shooting_number_log
                       + calls_911_number
                       # + negative_log
                       # + neutral_log
                       # + positive_log
                       + days_last_rev_log
                       + entire_home_apt
                       + distance_from_transportation
                       # + negative_prop_log
                       # + neutral_prop_log
                       # + positive_prop_log
                       , data = x)) %>% 
    map(summary)


data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression_review_cutoff_5percent.csv")

data %>% 
    split(.$review) %>% 
    map(function(x) lm(formula = price_log ~ 
                           demand 
                       + number_of_reviews_log
                       + reviews_per_month_log
                       + distance_from_subway_station
                       + distance_from_bus_stop
                       + n_cult_orgs
                       + shooting_number_log
                       + calls_911_number
                       # + negative_log
                       # + neutral_log
                       # + positive_log
                       + days_last_rev_log
                       + entire_home_apt
                       + distance_from_transportation
                       # + negative_prop_log
                       # + neutral_prop_log
                       # + positive_prop_log
                       , data = x)) %>% 
    map(summary) %>% 
    map(~.$r.squared)


data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression_review_cutoff_5percent.csv")

data %>% 
    split(.$review) %>% 
    map(function(x) lm(formula = price_log ~ 
                         demand 
                       + number_of_reviews_log
                       + reviews_per_month_log
                       + distance_from_subway_station
                       + distance_from_bus_stop
                       + n_cult_orgs
                       + shooting_number_log
                       + calls_911_number
                       + days_last_rev_log
                       + entire_home_apt
                       + distance_from_transportation
                       , data = x)) %>% 
    map(summary)



data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression_review_cutoff_3percent.csv")

data %>% 
    split(.$review) %>% 
    map(function(x) lm(formula = price_log ~ 
                           demand 
                       + number_of_reviews_log
                       + reviews_per_month_log
                       + distance_from_subway_station
                       + distance_from_bus_stop
                       + n_cult_orgs
                       + shooting_number_log
                       + calls_911_number
                       + days_last_rev_log
                       + entire_home_apt
                       + distance_from_transportation
                       , data = x)) %>% 
    map(summary)




data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression_review_cutoff_3_10_percent.csv")

data %>% 
    split(.$review) %>% 
    map(function(x) lm(formula = price_log ~ 
                           demand 
                       + number_of_reviews_log
                       + reviews_per_month_log
                       + distance_from_subway_station
                       + distance_from_bus_stop
                       + n_cult_orgs
                       + shooting_number_log
                       + calls_911_number
                       + days_last_rev_log
                       + entire_home_apt
                       + distance_from_transportation
                       , data = x)) %>% 
    map(summary)


data <- read_csv("./Data/Manipulated_Data/listings_prepared_for_regression_review_cutoff_321review.csv")

data %>% 
    split(.$review) %>% 
    map(function(x) lm(formula = price_log ~ 
                           demand 
                       + number_of_reviews_log
                       + reviews_per_month_log
                       + distance_from_subway_station
                       + distance_from_bus_stop
                       + n_cult_orgs
                       + shooting_number_log
                       + calls_911_number
                       + days_last_rev_log
                       + entire_home_apt
                       + distance_from_transportation
                       , data = x)) %>% 
    map(summary)
