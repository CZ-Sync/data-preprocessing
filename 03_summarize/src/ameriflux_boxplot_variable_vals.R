
#' @title Create a boxplot of AmeriFlux values
#' @description This creates a single boxplot per vegetation category and 
#' facets by each variable using daily data.
#' 
#' @param out_file character string giving the file path for saving the PNG
#' @param ameriflux_data_long a tibble with the columns `site_id`, `date`, 
#' `variable`, and `value`
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
    stat_boxplot(outlier.shape = 1) +
    ggtitle('Distribution of mean daily AmeriFlux values within each variable grouped by IGBP vegetation category') +
    ylab('Attribute value') +
    xlab('IGBP Vegetation Category') +
    guides(fill = 'none') +
    theme_bw()  +
    theme(text = element_text(size = 12), 
          plot.title = element_text(size = 20),
          strip.background = element_blank(),
          strip.text = element_text(size = 8, face = 'bold'),
          axis.text.x = element_text(size = 7, angle = 45, hjust = 1))
  
  ggsave(out_file, p,  width = 18,  height = 12,  dpi = 150)
  return(out_file)
}
