
# Source the files with custom functions called by the targets
tar_source('01_download/src')

p1 <- list(
  
  #### Downloading raw data inputs from Google Drive ####
  
  tar_target(p1_gd_folder_raw_data,
             googledrive::as_id('1SagFhGwxrJMRygiENTWesFhSd64eJSfq')),
  
  tar_target(p1_list_raw_data_files,
             googledrive::drive_ls(p1_gd_folder_raw_data))
  
  # TODO: insert commands that map over the files in the folder and download
  
  #### Downloading CAMELS data ####
  
  
)
