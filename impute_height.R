
install.packages("dplyr") # you only need to do this once

library("dplyr")

# Impute height based on age and sex and create BMI ------------------------
# The below is already done in shf_bmiimp and shf_bmiimp_cat

# create age groups, more stable median than exact age
rsdata <- rsdata %>%
  mutate(shf_age_catimp = case_when(
    shf_age < 30 ~ 30,
    shf_age < 40 ~ 40,
    shf_age < 50 ~ 50,
    shf_age < 60 ~ 60,
    shf_age < 65 ~ 65,
    shf_age < 70 ~ 70,
    shf_age < 75 ~ 75,
    shf_age < 80 ~ 80,
    shf_age < 85 ~ 85,
    shf_age < 90 ~ 90,
    shf_age >= 90 ~ 95
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
    shf_heightimp = coalesce(shf_height, heightmed), # if non missing height use that, otherwise use the imputed median within age and sex
    shf_bmiimp = round(shf_weight / (shf_heightimp / 100)^2, 1) # calculate bmi from imputed height
  ) %>%
  select(-shf_heightimp, -shf_age_catimp, -heightmed) # remove variables not needed
