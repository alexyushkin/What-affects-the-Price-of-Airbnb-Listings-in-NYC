library(tidyverse)
library(broom)

listings_w_demand <- read_csv("./Data/Manipulated_Data/listings_w_transformations.csv")

options(digits=8)

model_05 <- listings_w_demand %>% 
    lm(formula = price_log ~ 
                 demand_log 
               + n_cult_orgs 
               + entire_home_apt
               + calculated_host_listings_count
               # + distance_from_transportation
               + shooting_number_log
               + negative_log
               + days_last_rev_log
               # + calls_911_number
               , data = .)


table_of_impact <- broom::tidy(model_05) %>% 
    filter(p.value < 0.1, term != "(Intercept)") %>%  
    mutate(percent_of_impact = abs(estimate * 100), p_value = round(p.value, 3)) %>% #or without abs
    rename(variable = "term") %>% 
    select(variable, percent_of_impact, p_value) %>% 
    arrange(desc(abs(percent_of_impact)))

table_of_impact # not a very high precision of coefficients




table_of_impact_2 <- data.frame(summary(model_05)[4]) %>% 
    select(-2, -3) %>% 
    slice(2:10) %>% 
    filter(coefficients.Pr...t.. < 0.1) %>%
    rename(percent_of_impact = "coefficients.Estimate", p_value = "coefficients.Pr...t..") %>% 
    arrange(desc(abs(percent_of_impact)))
    
table_of_impact_2$percent_of_impact <- round(table_of_impact_2$percent_of_impact * 100, 2)
table_of_impact_2$p_value <- round(table_of_impact_2$p_value, 3)

table_of_impact_2



colnames(listings_w_demand)

model_06 <- listings_w_demand %>% 
    lm(formula = price_log ~ 
           neighbourhood_group
       + minimum_nights
       + calculated_host_listings_count
       + distance_from_subway_station
       + distance_from_bus_stop
       + n_cult_orgs
       + calls_911_number
       + entire_home_apt
       + long_term_rent
       + review
       + distance_from_transportation
       + demand_log
       + number_of_reviews_log
       + reviews_per_month_log
       + shooting_number_log
       + negative_log
       + neutral_log
       + positive_log
       + negative_prop_log
       + neutral_prop_log
       + positive_prop_log
       + days_last_rev_log
       , data = .)


model_06 <- listings_w_demand %>% 
    lm(formula = price_log ~ 
                    neighbourhood_group
                    + minimum_nights
                    + calculated_host_listings_count
                    + distance_from_subway_station
                    # + distance_from_bus_stop
                    + n_cult_orgs
                    + calls_911_number
                    + entire_home_apt
                    + long_term_rent
                    # + review
                    + distance_from_transportation
                    + demand_log
                    + number_of_reviews_log
                    + reviews_per_month_log
                    + shooting_number_log
                    + negative_log
                    # + neutral_log
                    + positive_log
                    + negative_prop_log
                    # + neutral_prop_log
                    # + positive_prop_log
                    + days_last_rev_log
                    , data = .)

summary(model_06)

table_of_impact_3 <- data.frame(summary(model_06)[4]) %>% 
    select(-2, -3) %>% 
    slice(2:10) %>% 
    filter(coefficients.Pr...t.. < 0.1) %>%
    rename(percent_of_impact = "coefficients.Estimate", p_value = "coefficients.Pr...t..") %>% 
    arrange(desc(abs(percent_of_impact)))

table_of_impact_3$percent_of_impact <- round(abs(table_of_impact_3$percent_of_impact * 100), 2) # or without abs
table_of_impact_3$p_value <- round(table_of_impact_3$p_value, 3)

table_of_impact_3

