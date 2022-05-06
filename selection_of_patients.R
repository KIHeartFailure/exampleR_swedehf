
# Apply inclusion/exclusion criteria to shfdb3 to get the project specific cohort

install.packages("dplyr") # you only need to do this once
install.packages("lubridate") # you only need to do this once

library("dplyr")
library("lubridate")

rsdata <- rsdata326 %>%
  # for most projects only patients registered in SwedeHF (=Cases) are used.
  # If you are not sure, this is probably what you want to do
  filter(casecontrol == "Case" &
    # apply any other relevant project specific selection criteria, for example:
    shf_indexdtm >= ymd("2009-01-01") &
    !is.na(shf_ef)) %>%
  group_by(LopNr) %>%
  arrange(shf_indexdtm) %>%
  slice(n()) %>% # select the last registration for each individual (LopNr)
  # slice(1) %>% selects the first registration instead
  ungroup()
