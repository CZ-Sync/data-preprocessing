
# Source the files with custom functions called by the targets
tar_source('01_download/src')

p1 <- list(
  
  #### Downloading raw data inputs from Google Drive ####
  
  tar_target(p1_gd_folder_raw_data,
             googledrive::as_id('1SagFhGwxrJMRygiENTWesFhSd64eJSfq')),
  
  tar_target(p1_list_raw_data_files,
             googledrive::drive_ls(p1_gd_folder_raw_data)),
  
  # TODO: insert commands that map over the files in the folder and download
  
  #### Downloading CAMELS data ####
  
  # This lists the names of the files that will be downloaded from
  # https://gdex.ucar.edu/dataset/camels/file.html
  tar_target(p1_camels_data_names,
             c("camels_clim.txt",
               "camels_geol.txt",
               "camels_hydro.txt",
               "camels_name.txt",
               "camels_soil.txt",
               "camels_topo.txt",
               "camels_vege.txt")),
  
  tar_target(p1_camels_data_txt, 
             download_url_safely(file_url = file.path('https://gdex.ucar.edu/api/v1/dataset/camels/file',
                                                      p1_camels_data_names),
                                 file_local = file.path('01_download/out', p1_camels_data_names)),
             pattern = map(p1_camels_data_names),
             format = 'file')
  
)
