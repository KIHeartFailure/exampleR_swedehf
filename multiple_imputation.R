

# Impute missing values ---------------------------------------------------

install.packages("mice") # you only need to do this once
install.packages("survival") # you only need to do this once

library("mice")
library("survival")

modvars <- c(
  # demo
  "shf_sex",
  "shf_age",
  "shf_indexyear",
  "shf_durationhf",

  # labs
  "shf_ef",
  "shf_nyha",
  "shf_bpsys",
  "shf_heartrate",
  "shf_bmi",
  "shf_hb",
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

noimpvars <- names(rsdata)[!names(rsdata) %in% modvars] # variables NOT included in the imputation model

# Nelson-Aalen estimator
na <- basehaz(coxph(Surv(sos_outtime_death, sos_out_death == "Yes") ~ 1,
  data = rsdata, method = "breslow"
))
rsdata <- left_join(rsdata, na, by = c("sos_outtime_death" = "time"))

ini <- mice(rsdata, maxit = 0, print = F) # to get initial predictors matrix and methods in place

# in order to not use the noimpvars in the model
pred <- ini$pred
pred[, noimpvars] <- 0
pred[noimpvars, ] <- 0 # redundant

meth <- ini$method
# change method used in imputation to prop odds model
meth[c("scb_education", "scb_dispincome", "shf_nyha")] <- "polr"

# in order not to impute the noimpvars
meth[noimpvars] <- ""

rsdataimp <- mice(rsdata,
  m = 10, maxit = 10,
  method = meth,
  predictorMatrix = pred,
  printFlag = FALSE,
  seed = 349872354
)

# for parallel computing (to speed up the process) see https://github.com/KIHeartFailure/resistantht/blob/main/munge/06-impute.R
