
# Load packages -----------------------------------------------------------

library("mice")
library("survival")
library("dplyr")

# Import data -------------------------------------------------------------

load("./data/rsdataxxx.RData")

# Run R files in stated order ---------------------------------------------

source("./code/patientselection.R")
source("./code/varfixes.R")
source("./code/mymodels.R")
source("./code/foresplot.R")


# Tips: -------------------------------------------------------------------

# Basic: 

# 1. Create MAIN.R that runs the project (see suggestion above)

# 2. Use the same folder structure for all projects, for example data, code, output, docs

# 3. Work in a R project enviroment (File/New Project in RStudio)

# 4. Save R files with todays date (version control) 

# Advanced: 

# 1. Use ProjectTemplate, http://projecttemplate.net/, my custom ProjectTemplate see https://github.com/linabe/statreport_projecttemplate

# 2. Use git (version control) 