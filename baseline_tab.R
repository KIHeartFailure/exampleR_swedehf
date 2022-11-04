
# Create a baseline table -------------------------------------------------

install.packages("tableone") # you only need to do this once
install.packages("openxlsx") # you only need to do this once
install.packages("dplyr") # you only need to do this once

library("tableone")
library("openxlsx")
library("dplyr")

tabvars <- c(
  # demo
  "shf_indexyear",
  "shf_sex",
  "shf_age",

  # organizational
  "shf_location",
  "shf_followuphfunit", "shf_followuplocation_cat",

  # clinical factors and lab measurments
  "shf_durationhf",
  "shf_nyha",
  "shf_bmi",
  "shf_bpsys",
  "shf_bpdia",
  "shf_map",
  "shf_heartrate",
  "shf_gfrckdepi",
  "shf_potassium",
  "shf_hb",
  "shf_ntprobnp",

  # treatments
  "shf_rasiarni",
  "shf_mra",
  "shf_digoxin",
  "shf_diuretic",
  "shf_nitrate",
  "shf_asaantiplatelet",
  "shf_anticoagulantia",
  "shf_statin",
  "shf_bbl",
  "shf_device",

  # comorbs
  "shf_smoke",
  "shf_sos_com_diabetes",
  "shf_sos_com_hypertension",
  "shf_sos_com_ihd",
  "sos_com_pad",
  "sos_com_stroke",
  "shf_sos_com_af",
  "sos_com_valvular",
  "sos_com_liver",
  "sos_com_cancer3y",
  "sos_com_copd",
  "sos_com_kidney",
  "shf_anemia",
  "sos_com_bleed",
  "sos_com_muscoloskeletal3y",
  "sos_com_dementia",
  "sos_com_depression",

  # socec
  "scb_famtype",
  "scb_child",
  "scb_education",
  "scb_dispincome_cat"
)

tab1 <- print(
  CreateTableOne(
    vars = tabvars,
    data = rsdata,
    strata = "shf_ef_cat"
  ),
  smd = TRUE, # stand mean differences, for example when using propensity score matching
  missing = TRUE, # always present missing
  printToggle = FALSE,
  nonnormal = tabvars, # for median (qi-q3) instead of default mean (SD)
  catDigits = 1,
  contDigits = 1,
  noSpaces = TRUE,
  explain = FALSE
)

tab1 <- as_tibble(cbind(Variable = rownames(tab1), tab1)) %>%
  select(Variable, Missing, 2:3, p, SMD) # to get stuff in order

# export to excel
write.xlsx(tab1, paste0("./output/tabs/tab1_", Sys.Date(), ".xlsx"), rowNames = FALSE, overwrite = TRUE)


# More --------------------------------------------------------------------

# To add variable names and units to the table, see ex https://github.com/KIHeartFailure/iron/blob/main/src/tab1_aid.Rmd
