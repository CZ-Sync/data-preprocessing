
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
#' object, and converting binary columns to logicals.
#' 
#' @param out_file a character string of where to save the feather file
#' @param in_file a character string to a CSV file of AmeriFlux data in wide 
#' format with all variables as columns and rows as different time steps for a
#' single site.
#' @param site_id the AmeriFlux site id for this data
#' 
#' @returns a filepath to the feather file containing the columns `site_id`, 
#' `date_time`, `is_night`, and then a number of AmeriFlux variable or QC columns
#'
load_and_prep_ameriflux_data <- function(out_file, in_file, site_id) {
  
  amf_data <- read_csv(in_file, show_col_types = FALSE) %>% 
    
    # Add the site id
    mutate(site_id = site_id) %>% 
    
    # Replace `-9999` as NAs
    mutate(across(where(is.numeric), ~na_if(., -9999))) %>% 
    
    # Adjust night from a 0 or 1 to F or T
    mutate(is_night = as.logical(NIGHT)) %>% 
    
    # Convert numeric time to a datetime format
    # TODO: Will need to add in timezone later. Defaulting to UTC for now.
    mutate(date_time = as_datetime(as.character(TIMESTAMP_START), format = '%Y%m%d%H%M')) %>%
    
    # Now select relevant columns
    select(site_id, date_time, is_night, everything(), 
           -starts_with('TIMESTAMP'), -NIGHT) %>% 
    
    # Arrange by DateTime
    arrange(date_time) %>% 
    
    # Save as a feather file per site
    write_feather(out_file)
  
  return(out_file)
}
