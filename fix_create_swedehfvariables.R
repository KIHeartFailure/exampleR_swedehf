

# Examples create and fix swedehf variables needed for project -------------------

rsdata <- rsdata %>%
  mutate(
    shf_indexyear_cat = case_when(
      shf_indexyear <= 2010 ~ "2000-2010",
      shf_indexyear <= 2018 ~ "2011-2018"
    ),
    shf_nyha_cat = case_when(
      shf_nyha %in% c("I", "II") ~ "I - II",
      shf_nyha %in% c("III", "IV") ~ "III-IV"
    ),
    shf_age_cat = case_when(
      shf_age < 75 ~ "<75",
      shf_age >= 75 ~ ">=75"
    ),
    shf_ef_cat = factor(case_when(
      shf_ef == ">=50" ~ 3,
      shf_ef == "40-49" ~ 2,
      shf_ef %in% c("30-39", "<30") ~ 1
    ),
    labels = c("HFrEF", "HFmrEF", "HFpEF"),
    levels = 1:3
    ),
    shf_smoking_cat = factor(case_when(
      shf_smoking %in% c("Former", "Never") ~ 0,
      shf_smoking %in% c("Current") ~ 1
    ),
    labels = c("No", "Yes"),
    levels = 0:1
    ),

    # Anemia
    shf_anemia = case_when(
      is.na(shf_hb) ~ NA_character_,
      shf_sex == "Female" & shf_hb < 120 | shf_sex == "Male" & shf_hb < 130 ~ "Yes",
      TRUE ~ "No"
    ),
    shf_map_cat = case_when(
      shf_map <= 90 ~ "<=90",
      shf_map > 90 ~ ">90"
    ),
    shf_potassium_cat = factor(
      case_when(
        is.na(shf_potassium) ~ NA_real_,
        shf_potassium < 3.5 ~ 2,
        shf_potassium <= 5 ~ 1,
        shf_potassium > 5 ~ 3
      ),
      labels = c("normakalemia", "hypokalemia", "hyperkalemia"),
      levels = 1:3
    ),
    shf_heartrate_cat = case_when(
      shf_heartrate <= 70 ~ "<=70",
      shf_heartrate > 70 ~ ">70"
    ),
    shf_device_cat = factor(case_when(
      is.na(shf_device) ~ NA_real_,
      shf_device %in% c("CRT", "CRT & ICD", "ICD") ~ 2,
      TRUE ~ 1
    ),
    labels = c("No", "CRT/ICD"),
    levels = 1:2
    ),
    shf_bmi_cat = factor(case_when(
      is.na(shf_bmi) ~ NA_real_,
      shf_bmi < 30 ~ 1,
      shf_bmi >= 30 ~ 2
    ),
    labels = c("<30", ">=30"),
    levels = 1:2
    ),

    shf_gfrckdepi_cat = factor(case_when(
      is.na(shf_gfrckdepi) ~ NA_real_,
      shf_gfrckdepi >= 60 ~ 1,
      shf_gfrckdepi < 60 ~ 2,
    ),
    labels = c(">=60", "<60"),
    levels = 1:2
    ),
    shf_sos_com_af = case_when(
      sos_com_af == "Yes" |
        shf_af == "Yes" |
        shf_ekg == "Atrial fibrillation" ~ "Yes",
      TRUE ~ "No"
    ),
    shf_sos_com_ihd = case_when(
      sos_com_ihd == "Yes" |
        shf_revasc == "Yes" |
        sos_com_pci == "Yes" |
        sos_com_cabg == "Yes" ~ "Yes",
      TRUE ~ "No"
    ),
    shf_sos_com_hypertension = case_when(
      shf_hypertension == "Yes" |
        sos_com_hypertension == "Yes" ~ "Yes",
      TRUE ~ "No"
    ),
    shf_sos_com_diabetes = case_when(
      shf_diabetes == "Yes" |
        sos_com_diabetes == "Yes" ~ "Yes",
      TRUE ~ "No"
    ),
    shf_sos_com_valvular = case_when(
      shf_valvedisease == "Yes" |
        sos_com_valvular == "Yes" ~ "Yes",
      TRUE ~ "No"
    ),
    shf_followuplocation_cat = if_else(shf_followuplocation %in% c("Primary care", "Other"), "Primary care/Other",
      as.character(shf_followuplocation)
    )
  )


# project specific categorization of income within year

inc <- rsdata %>%
  group_by(shf_indexyear) %>%
  summarise(incmed = quantile(scb_dispincome,
    probs = 0.5,
    na.rm = TRUE
  ), .groups = "drop_last")

rsdata <- left_join(
  rsdata,
  inc,
  by = "shf_indexyear"
) %>%
  mutate(
    scb_dispincome_cat2 = case_when(
      scb_dispincome < incmed ~ 1,
      scb_dispincome >= incmed ~ 2
    ),
    scb_dispincome_cat2 = factor(scb_dispincome_cat2,
      levels = 1:2,
      labels = c("Below medium", "Above medium")
    )
  ) %>%
  select(-incmed)

# project specific categorization of NT-proBNP within year

ntprobnp <- rsdata %>%
  group_by(shf_ef_cat) %>%
  summarise(
    ntmed = quantile(shf_ntprobnp,
      probs = 0.5,
      na.rm = TRUE
    ),
    .groups = "drop_last"
  )

rsdata <- left_join(
  rsdata,
  ntprobnp,
  by = c("shf_ef_cat")
) %>%
  mutate(
    shf_ntprobnp_cat = case_when(
      shf_ntprobnp < ntmed ~ 1,
      shf_ntprobnp >= ntmed ~ 2
    ),
    shf_ntprobnp_cat = factor(shf_ntprobnp_cat,
      levels = 1:2,
      labels = c("Below medium", "Above medium")
    )
  ) %>%
  select(-ntmed)
