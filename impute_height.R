
install.packages("dplyr") # you only need to do this once

library("dplyr")

# Impute heigh based on age and sex and create BMI ------------------------

# impute height with the median within each age and sex

# few pats < 30 and > 90 categorize to one group
rsdata <- rsdata %>%
  mutate(shf_age_catimp = case_when(
    shf_age < 30 ~ 30,
    shf_age > 90 ~ 90,
    TRUE ~ shf_age
  ))

# median within sex and age
height <- rsdata %>%
  group_by(shf_sex, shf_age_catimp) %>% # can also add for example shf_indexyear
  summarise(heightmed = quantile(shf_height,
    probs = 0.5,
    na.rm = TRUE
  ), .groups = "drop_last")

# join together
rsdata <- left_join(
  rsdata,
  height,
  by = c("shf_sex", "shf_age_catimp")
) %>%
  mutate(
    shf_heightimp = coalesce(shf_height, heightmed), # if non missing height use that, otherwise use the imputed median
    shf_bmiimp = round(shf_weight / (shf_heightimp / 100)^2, 1) # calc bmi from imputed height
  ) %>%
  select(-shf_heightimp, -shf_age_catimp, -heightmed) # remove variables not needed
