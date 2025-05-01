
# Load packages required to define the pipeline:
library(targets)

# Set target options:
tar_option_set(
  # Packages targets need to run
  packages = c(
    'amerifluxr',
    'googledrive',
    'httr2',
    'tidyverse',
    'writexl'
  ), 
  # Setting default storage format to `qs`, which is fast
  format = "qs"
)

# Source the phase target recipe files to load the target lists
source('01_download.R')
source('02_munge.R')
source('03_summarize.R')

# Combine targets from phase files
c(p1, p2, p3)
