
# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Used for `tar_group_count()`

# Set target options:
tar_option_set(
  # Packages targets need to run
  packages = c(
    'amerifluxr',
    'arrow', 
    'googledrive',
    'httr2',
    'StreamLightUtils', # Used for getting timezone from lat/long. Install with `remotes::install_packages('psavoy/StreamLightUtils')`
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
