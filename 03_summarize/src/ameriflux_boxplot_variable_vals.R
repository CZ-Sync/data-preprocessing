
#' @title Create a boxplot of AmeriFlux values
#' @description This creates a single boxplot per vegetation category and 
#' facets by each variable.
#' 
#' @param out_file character string giving the file path for saving the PNG
#' @param ameriflux_data_long a tibble with the columns `site_id`, `date_time`, 
#' `is_night`, `variable`, `value`, and `qc`
#' @param ameriflux_site_info a tibble of site information, see `prep_ameriflux_site_info()`
#' 
#' @returns the filepath to the saved PNG
#' 
ameriflux_boxplot_variable_vals <- function(out_file, ameriflux_data_long,
                                            ameriflux_site_info) {
  
  # Prepare the data
  plot_data <- ameriflux_data_long %>%
    # Remove NA values
    drop_na(value) %>% 
    # Join site information to get the vegetation category
    left_join(ameriflux_site_info, by = 'site_id') 
  
  p <- ggplot(plot_data, aes(x = IGBP_veg, y = value, fill = IGBP_veg)) + 
    facet_wrap(vars(variable), scales = 'free_y') +
    stat_boxplot() +
    ggtitle('Distribution of values within each variable') +
    ylab('Attribute value') +
    xlab('AmeriFlux Site') +
    guides(fill = 'none') +
    theme_bw()  +
    theme(text = element_text(size = 12), 
          plot.title = element_text(size = 20),
          strip.background = element_blank(),
          strip.text = element_text(size = 8, face = 'bold'))
  
  ggsave(out_file, p,  width = 15,  height = 10,  dpi = 150)
  return(out_file)
}
