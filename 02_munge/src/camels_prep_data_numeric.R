
#' @title Create a long-formatted CAMELS dataset of only numeric attributes
#' @description This function pivots the dataset to be in long format and 
#' contain only those attributes with numeric values, so that the data
#' can be quickly visualized.
#' 
#' @param camels_data_all a tibble with at least the column `gauge_id` and any
#' number of columns prefixed with the CAMELS data file they come from.
#' 
#' @returns a tibble with the columns `gauge_id`, `huc_02`, `category`,
#' `attribute`, and `value`
#' 
camels_prep_data_numeric <- function(camels_data_all) {
  camels_data_all %>% 
    # Select identifying columns and all numeric columns
    select(gauge_id, huc_02, where(is.numeric)) %>% 
    # Pivot from wide to long format
    pivot_longer(cols = -c(gauge_id, huc_02),
                 names_to = 'attribute',
                 values_to = 'value') %>% 
    # Create a separate column for the attribute category
    separate(attribute, 
             into = c('category', 'attribute'),
             sep = '\\.')
}
