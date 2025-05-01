
#' @title Helper function to pivot AmeriFlux from wide to long
#' @description This function is used to take wide AmeriFlux data, where each
#' variable is a column and every row is a different timestep and convert to
#' long so that variables appear in a column and their values are in a column
#' next to them. The tricky part that is completed here is to retain any of the
#' variable's corresponding QC (quality control) column and put in a single 
#' QC column. The overall QC column will have NAs if a variable did not have 
#' its own QC column.
#' 
#' @param in_data a tibble of AmeriFlux data in wide format with at least the
#' columns `site_id`, `date_time` (added as a custom munge step) and `is_night` 
#' as well as a column per variable and corresponding QC columns (named `{VARIABLE}_QC`).
#' 
#' @returns a tibble with the columns `site_id`, `date_time`, `is_night`, 
#' `variable`, `value`, and `qc`
#' 
convert_ameriflux_to_long <- function(in_data) {
  in_data %>%
    pivot_longer(
      cols = -c(site_id, date_time, is_night),
      names_to = "name",
      values_to = "value"
    ) %>%
    mutate(
      # Separate base variable name and QC flag
      variable = str_remove(name, "_QC$"),
      field = if_else(str_detect(name, "_QC$"), "qc", "value")
    ) %>%
    select(-name) %>%
    pivot_wider(
      names_from = field,
      values_from = value
    ) %>%
    select(site_id, date_time, is_night, variable, value, qc)
}

#' @title Load and clean AmeriFlux data
#' @description This function loads raw hourly AmeriFlux data and prepares it
#' for analysis by filling NAs properly, converting timestamps to a `POSIXct`
#' object in the correct local time, and converting binary columns to logicals.
#' 
#' @param out_file a character string of where to save the feather file
#' @param in_file a character string to a CSV file of AmeriFlux data in wide 
#' format with all variables as columns and rows as different time steps for a
#' single site.
#' @param site_info a tibble with at least the columns `site_id` and `timezone`,
#' see `prep_ameriflux_site_info()` for details
#' @param site_id the AmeriFlux site id for this data
#' 
#' @returns a filepath to the feather file containing the columns `site_id`, 
#' `date_time`, `is_night`, and then a number of AmeriFlux variable or QC columns
#'
load_and_prep_ameriflux_data <- function(out_file, in_file, site_info, site_id) {
  
  site_tz <- site_info %>% dplyr::filter(site_id == site_id) %>% pull(timezone)

  amf_data <- read_csv(in_file, show_col_types = FALSE) %>% 
    
    # Add the site id
    mutate(site_id = site_id) %>% 
    
    # Replace `-9999` as NAs
    mutate(across(where(is.numeric), ~na_if(., -9999))) %>% 
    
    # Adjust night from a 0 or 1 to F or T
    mutate(is_night = as.logical(NIGHT)) %>% 
    
    # Convert numeric time to a datetime format, then add timezone
    # Using `with_tz()` after because weirdly some values (e.g. 201603130200)
    # fail when we try to add the timezone inside of `as_datetime()`.
    mutate(date_time = as_datetime(as.character(TIMESTAMP_START), format = '%Y%m%d%H%M')) %>%
    mutate(date_time = with_tz(date_time, site_tz)) %>% 
    
    # Now select relevant columns
    select(site_id, date_time, is_night, everything(), 
           -starts_with('TIMESTAMP'), -NIGHT) %>% 
    
    # Arrange by DateTime
    arrange(date_time) %>% 
    
    # Save as a feather file per site
    write_feather(out_file)
  
  return(out_file)
}

#' @title Prepare AmeriFlux site information
#' @description This function adds a timezone and selects only relevant columns
#' 
#' @param site_info a tibble with AmeriFlux site metadata, see `amf_site_info()`
#' @param site_ids a vector of the site_ids for which data was successfully downloaded
#' 
#' @returns a tibble with only rows of sites that had data downloaded and a
#' subset of columns renamed to be lowercase or more understandable.
#'
prep_ameriflux_site_info <- function(site_info, site_ids) {
  
  site_info %>% 
    # Filter to just those sites for which data was successfully downloaded
    filter(SITE_ID %in% site_ids) %>%
    
    # Add the timezone based on lat/long using the `StreamLightUtils` pkg fxn `get_tz()`
    rowwise() %>% 
    mutate(TIMEZONE = get_tz(LOCATION_LAT, LOCATION_LONG, 
                             # Assuming vals provided use WGS84
                             site_crs = 4326)) %>% 
    ungroup() %>% 
    
    # Select and rename the columns we want to keep
    rename_with(tolower) %>% 
    select(site_id, 
           site_name, 
           data_policy,
           data_start,
           data_end,
           latitude = location_lat,
           longitude = location_long,
           elevation =  location_elev,
           timezone,
           avg_air_temp_degC = mat,
           avg_precip_mm = map, 
           IGBP_veg = igbp,
           Koppen_clim_class = climate_koeppen)
  
}

