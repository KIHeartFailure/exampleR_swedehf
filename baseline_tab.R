
# Create a baseline table -------------------------------------------------

install.packages("tableone") # you only need to do this once
install.packages("openxlsx") # you only need to do this once

library("tableone")
library("openxlsx")


tabvars <- c(
  # demo
  "shf_sex",
  "shf_age",
  "shf_indexyear",
  "shf_durationhf",

  # labs
  "shf_ef",
  "shf_nyha",
  "shf_map",
  "shf_bpsys",
  "shf_bpdia",
  "shf_heartrate",
  "shf_bmi",
  "shf_hb",
  "shf_potassium",
  "shf_gfrckdepi",
  "shf_ntprobnp",

  # comorbs
  "shf_smoking",
  "shf_diabetes",
  "shf_af",
  "shf_hypertension",
  "sos_com_peripheralartery",
  "sos_com_stroketia",
  "sos_com_liver",
  "sos_com_cancer3y",
  "sos_com_copd",
  "sos_com_bleed",
  "sos_com_charlsonci",

  # treatments
  "shf_rasarni",
  "shf_bbl",
  "shf_mra",
  "shf_diuretic",
  "shf_device",
  "shf_digoxin",
  "shf_asaantiplatelet",
  "shf_anticoagulantia",
  "shf_statin",
  "shf_nitrate",

  # organizational
  "shf_followuphfunit",
  "shf_followuplocation",

  # socec
  "scb_famtype",
  "scb_child",
  "scb_education",
  "scb_dispincome"
)

tab1 <- print(CreateTableOne(
  vars = tabvars,
  data = rsdata,
  strata = "shf_sex"
),
smd = TRUE, # if you want stand mean differences, for example when using propensity score matching
missing = TRUE,
printToggle = FALSE,
nonnormal = tabvars,
catDigits = 1,
contDigits = 1,
noSpaces = TRUE,
explain = FALSE
)

tab1 <- as_tibble(cbind(Variable = rownames(tab1), tab1)) %>%
  select(Variable, Missing, 2:3, p, SMD)

# export to excel
write.xlsx(tab1, paste0("./output/tabs/tab1_", Sys.Date(), ".xlsx"), rowNames = FALSE, overwrite = TRUE)


# for adding variable names and units to the table, see https://github.com/KIHeartFailure/iron/blob/main/src/tab1_aid.Rmd
