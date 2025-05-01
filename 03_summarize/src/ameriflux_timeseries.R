
#' @title Create a boxplot of AmeriFlux values
#' @description This creates a single boxplot per vegetation category and 
#' facets by each variable.
#' 
#' @param out_file character string giving the file path for saving the PNG
#' @param ameriflux_data_long a tibble with the columns `site_id`, `date_time`, 
#' `is_night`, `variable`, `value`, and `qc`
#' @param site_id a character string of the site ID to plot
#' 
#' @returns the filepath to the saved PNG
#' 
ameriflux_timeseries <- function(out_file, ameriflux_data_long, site_id) {
  
  # Prepare the data
  plot_data <- ameriflux_data_long %>%
    # Remove NA values
    drop_na(value) %>% 
    dplyr::filter(site_id %in% site_id)
  
  p <- ggplot(plot_data,
              aes(x = date_time, y = value, color = site_id)) +
    geom_line(color = '#334e68') + 
    facet_wrap(vars(variable), scales = "free_y") +
    ggtitle(sprintf('Hourly timeseries of AmeriFlux variables for Site %s',
                    site_id)) +
    ylab('Attribute value') +
    xlab('Time') +
    guides(fill = 'none') +
    theme_bw()  +
    theme(text = element_text(size = 12), 
          plot.title = element_text(size = 20),
          strip.background = element_blank(),
          strip.text = element_text(size = 7, face = 'bold'))
  
  ggsave(out_file, p,  width = 15,  height = 10,  dpi = 150)
  return(out_file)
}
