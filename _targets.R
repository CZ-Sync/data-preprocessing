
# Load packages required to define the pipeline:
library(targets)

# Set target options:
tar_option_set(
  # Packages targets need to run
  packages = c(
    'googledrive',
    'tidyverse'
  ), 
  # Setting default storage format to `qs`, which is fast
  format = "qs"
)

# Source the phase target recipe files to load the target lists
source('01_download.R')

# Combine targets from phase files
c(p1)
