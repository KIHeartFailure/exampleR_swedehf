
# P-value for interaction in cox model using mi data --------------------

install.packages("mice") # you only need to do this once
install.packages("survival") # you only need to do this once
install.packages("dplyr") # you only need to do this once

library("mice")
library("survival")
library("dplyr")

## model with interaction between sex and ef
mod <- with(rsdataimp, coxph(Surv(sos_outtime_death, sos_out_death == "Yes") ~ shf_sex * shf_ef + shf_age))

## Interaction between factors with 2 levels or continuous variables possible to take p for interaction straight from output.
smod <- summary(pool(mod))

## Interaction between factors with > 2 levels
## model without interaction between sex and ef
mod_noint <- with(rsdataimp, coxph(Surv(sos_outtime_death, sos_out_death == "Yes") ~ shf_sex + shf_ef + shf_age))

pint <- mice::D1(mod, mod_noint)
