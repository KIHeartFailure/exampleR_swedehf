
# Apply inclusion/exclusion criteria to shfdb4 to get the project specific cohort

install.packages("dplyr") # you only need to do this once
install.packages("lubridate") # you only need to do this once

library("dplyr")
library("lubridate")


rsdata <- rsdata400 %>%
  # comorbs, hf duration ect is not collected for the follow-up visits in New SwedeHF.
  # They are imputed from the index visit in the database but will not be of as good quality.
  # Also, although not very common,
  # a follow-up visit can be for example a phone call, leading to more missing for other variables.
  # For those reasons follow-up visits in New SwedeHF are excluded.
  filter(!(shf_source == "New SHF" & shf_type == "Follow-up") &
    # apply any other relevant project specific selection criteria, for example:
    shf_indexdtm >= ymd("2009-01-01") &
    !is.na(shf_ef)) %>%
  group_by(lopnr) %>%
  arrange(shf_indexdtm) %>%
  slice(n()) %>% # select the last registration within each individual (lopnr)
  # slice(1) %>% selects the first registration instead
  ungroup()
