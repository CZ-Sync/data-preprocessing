
# Source the files with custom functions called by the targets
tar_source('01_download/src')

p1 <- list(
  
  #### Downloading raw data inputs from Google Drive ####
  
  tar_target(p1_gd_folder_10_Raw,
             googledrive::as_id('1SagFhGwxrJMRygiENTWesFhSd64eJSfq')),
  
  tar_target(p1_list_raw_data_files,
             googledrive::drive_ls(p1_gd_folder_10_Raw)),
  
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
             format = 'file'),
  
  #### Downloading AmeriFlux data ####
  
  tar_target(p1_ameriflux_site_info,
             amf_site_info() %>% 
               # Keep CONUS sites only
               filter(COUNTRY %in% 'USA', !STATE %in% c('AK', 'HI')) %>% 
               # Ignore any sites that follow the LEGACY data policy
               filter(DATA_POLICY != 'LEGACY') %>% 
               # Require a DATA_START year to be provided
               filter(!is.na(DATA_START))),
  
  tar_target(p1_ameriflux_sites, sort(p1_ameriflux_site_info$SITE_ID)[2:3]),
  
  tar_target(p1_ameriflux_data_zip_status,
             download_ameriflux_safely(
               user_id = 'lindsayplatt',
               user_email = 'lplatt@cuahsi.org',
               site_id = p1_ameriflux_sites,
               data_product = "FLUXNET",
               data_variant = "SUBSET", # Using SUBSET for now, https://fluxnet.org/data/fluxnet2015-dataset/subset-data-product/
               intended_use_text = "Eventually for an CONUS ET project, but testing R package downloads for now",
               out_dir = '01_download/tmp'
             ), pattern = map(p1_ameriflux_sites)),
  
  # Using the output tibble of download statuses for AmeriFlux data, 
  # filter to only those that successfully downloaded a file 
  tar_target(p1_ameriflux_data_zip_exists, 
             p1_ameriflux_data_zip_status %>% 
               filter(file.exists(download_result))),
  
  tar_target(p1_ameriflux_data_csv, 
             move_file_from_zip('01_download/out',
                                p1_ameriflux_data_zip_exists$download_result,
                                'AMF_US-[A-z|0-9]{3}_FLUXNET_SUBSET_HH_[0-9]{4}-[0-9]{4}_[0-9]{1}-[0-9]{1}.csv'),
             pattern = map(p1_ameriflux_data_zip_exists),
             format = 'file')
  
)
