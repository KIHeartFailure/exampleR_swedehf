
# Create variables in imputed dataset -----------------------------------

# For example if the imputed variable is continuous and a categorical 
# variable is needed for a Forest plot

install.packages("mice") # you only need to do this once
install.packages("dplyr") # you only need to do this once

library("mice")
library("dplyr")

# keep original imputed data (rsdataimp) just in case
rsdataimp.org <- rsdataimp

# Convert to Long
long <- mice::complete(rsdataimp, action = "long", include = TRUE)

long <- long %>%
  mutate(
    shf_nyha_cat = factor(case_when(
      is.na(shf_nyha) ~ NA_character_,
      shf_nyha %in% c("I", "II") ~ "I-II",
      TRUE ~ "III-IV"
    ))
  )

# Convert back to mids object
rsdataimp <- as.mids(long)
