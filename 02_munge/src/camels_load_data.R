
#' @title Load a single CAMELS dataset txt file
#' @description Read in a semicolon-delimited file from the downloaded CAMELS
#' data as a tibble. Adjusts the column names to use the shorthand word for the
#' CAMELS file that they came from as a prefix, e.g. `hydro.runoff_ratio`.
#' 
#' @param file character string of the local filepath to load
#' 
#' @returns a tibble with at least the column `gauge_id` and any number of columns
#' prefixed with the CAMELS data file they come from. They should all have 
#' 671 rows, which is the number of gauges represented in the CAMELS dataset.
#' 
camels_load_data <- function(file) {
  
  # Prepare the column prefix based on the name of the file
  col_prefix <- paste0(gsub('camels_|.txt', '', basename(file)), '.')
  
  # Don't add prefix for the metadata cols in `camels_name.txt`
  col_prefix <- ifelse(grepl('name', col_prefix), '', col_prefix)
  
  # Read in the file and adjust column names
  read_delim(file, delim = ';', col_types = cols()) |>
    # Add the filename as a prefix to the column
    rename_with(
      .fn = ~ paste0(col_prefix, .),    # Function to add prefix
      .cols = -gauge_id                 # Exclude the column 'gauge_id'
    ) %>% 
    # Remove leading space that appears in the land cover type column
    mutate(across(matches('vege.dom_land_cover'), ~str_replace(.x, "^\\s+", "")))
}
