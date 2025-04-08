
# Source the files with custom functions called by the targets
tar_source('02_munge/src')

p2 <- list(
  
  #### Loading raw data inputs from Google Drive ####
  
  
  #### Loading & merging CAMELS data ####
  
  # Load each CAMELS text file as a tibble
  tar_target(p2_camels_data_list,
             camels_load_data(p1_camels_data_txt),
             # Map over each file and load individually; keep as a list of tibbles
             pattern = map(p1_camels_data_txt),
             iteration = 'list'),
  
  # Combine all the CAMELS data into one table by `gauge_id`
  tar_target(p2_camels_data_all,
             p2_camels_data_list |> 
               reduce(left_join, by = 'gauge_id') |> 
               relocate(gauge_name, huc_02, .after = gauge_id)),
  
  # Prepare all CAMELS numeric data for quick summary plotting/exploration
  tar_target(p2_camels_data_numeric_long,
             camels_prep_data_numeric(p2_camels_data_all))
  
)
