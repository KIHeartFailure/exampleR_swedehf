

# Impute missing values ---------------------------------------------------

install.packages("mice") # you only need to do this once
install.packages("survival") # you only need to do this once
install.packages("dplyr") # you only need to do this once

library("mice")
library("survival")
library("dplyr")

# Nelson-Aalen estimator used in imputation model
na <- basehaz(coxph(Surv(sos_outtime_death, sos_out_death == "Yes") ~ 1,
  data = rsdata, method = "breslow"
))
rsdata <- left_join(rsdata, na, by = c("sos_outtime_death" = "time"))

# Alt 1. Only imputation variables in dataset -----------------------------

# Keep only variables used in the imputation model in the dataset used in the imputation model

rsdatausedforimp <-
  rsdata %>%
  select(
    shf_sex,
    shf_age,
    shf_indexyear,
    shf_durationhf,

    # labs
    shf_ef,
    shf_nyha,
    shf_bpsys,
    shf_heartrate,
    shf_bmi,
    shf_hb,
    shf_gfrckdepi,
    shf_ntprobnp,

    # comorbs
    shf_smoking,
    shf_diabetes,
    shf_af,
    shf_hypertension,
    sos_com_peripheralartery,
    sos_com_stroketia,
    sos_com_liver,
    sos_com_cancer3y,
    sos_com_copd,

    # treatments
    shf_rasarni,
    shf_bbl,
    shf_mra,
    shf_diuretic,
    shf_device,
    shf_digoxin,
    shf_asaantiplatelet,
    shf_anticoagulantia,
    shf_statin,
    shf_nitrate,

    # organizational
    shf_followuphfunit,
    shf_followuplocation,

    # socec
    scb_famtype,
    scb_child,
    scb_education,
    scb_dispincome,
    sos_outtime_death,
    hazard,
    sos_out_death
  )

rsdataimp <- mice(rsdatausedforimp,
  m = 10, maxit = 10,
  printFlag = FALSE,
  seed = 349872354
)

# Alt 2. Use prediction matrix and method ---------------------------------

# Specify in the prediction matrix and method input parameters which variables should be used in the imputation model

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
  "scb_dispincome",
  "hazard",
  "sos_out_death"
)

noimpvars <- names(rsdata)[!names(rsdata) %in% modvars] # variables NOT included in the imputation model

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


# More  ------------------------------------------------------------------

# for parallel computing (to speed up the process) see https://github.com/KIHeartFailure/resistantht/blob/main/munge/06-impute.R
