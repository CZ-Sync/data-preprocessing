
# Source the files with custom functions called by the targets
tar_source('02_munge/src')

p2 <- list(
  
  # Declare the preprocessed folder ID to use for uploads
  tar_target(p2_gd_folder_20_Preprocessed,
             googledrive::as_id('1afBkfYH81EemTIQvZtpMTtKYkiGO8IhM')),
  
  #### Google Drive `00_Raw` folder ####
  
  ##### Loading, merging, munging #####
  
  ##### Uploading processed data #####
  
  #### CAMELS data ####
  
  ##### Loading, merging, munging #####
  
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
             camels_prep_data_numeric(p2_camels_data_all)),
  
  ##### Uploading processed data #####
  
  # Save intermediate data as a XLSX file
  # Saving as XLSX because Google Drive is dropping leading zeros on the gage numbers
  tar_target(p2_camels_data_all_xlsx, {
    file_out <- '02_munge/out/camels_data_all.xlsx'
    writexl::write_xlsx(p2_camels_data_all, file_out)
    return(file_out)
  }, format = 'file'), 
  
  # Upload this CSV to Google Drive
  tar_target(p2_camels_data_all_gd,
             drive_upload(p2_camels_data_all_xlsx,
                          p2_gd_folder_20_Preprocessed,
                          name = basename(p2_camels_data_all_xlsx),
                          overwrite = TRUE)),
  
  #### AmeriFlux data ####
  
  ##### Loading, merging, munging #####
  
  # Map over each AmeriFlux CSV and munge it
  tar_target(p2_ameriflux_data_feather,
             load_and_prep_ameriflux_data(
               out_file = gsub('.csv', '.feather', gsub('01_download/out', '02_munge/tmp', 
                                                        p1_ameriflux_data_csv)), 
               in_file = p1_ameriflux_data_csv),
             pattern = map(p1_ameriflux_data_csv),
             format = 'file'),
  
  # Combine all AmeriFlux feathers into a single file
  tar_target(p2_ameriflux_data_all_csv, {
    out_file <- '02_munge/out/ameriflux_data_all.csv'
    map(p2_ameriflux_data_feather, read_feather) %>% 
      bind_rows() %>% write_csv(out_file)
    return(out_file)
  })
  
  ##### Uploading processed data #####
  
)
