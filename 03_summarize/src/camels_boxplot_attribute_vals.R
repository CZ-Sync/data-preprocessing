
#' @title Create a boxplot of attribute values
#' @description This creates a single boxplot per HUC and facets by each 
#' attribute. This expects that the data passed in represents only a single
#' CAMELS category (e.g. hydro, clim, topo) to reduce the number of facets in 
#' a single PNG file.
#' 
#' @param out_file character string giving the file path for saving the PNG
#' @param camels_data_long a tibble with the columns `gauge_id`, `huc_02`, 
#' `category`, `attribute`, and `value`
#' 
#' @returns the filepath to the saved PNG
#' 
camels_boxplot_attribute_vals <- function(out_file, camels_data_long) {
  
  # Set the number of columns
  num_facet_cols <- 4
  
  p <- ggplot(camels_data_long, 
         aes(x = huc_02, y = value, fill = huc_02)) +
    facet_wrap(vars(attribute), scales = 'free_y', ncol = num_facet_cols) +
    stat_boxplot() +
    ggtitle(sprintf('Distribution of attributes within category: %s', 
                    unique(camels_data_long$category))) +
    ylab('Attribute value, see attributes PDF for units and definitions') +
    xlab('2-Digit HUC Unit Code') +
    guides(fill = 'none') +
    theme_bw() +
    theme(text = element_text(size = 12), 
          plot.title = element_text(size = 20),
          strip.background = element_blank(),
          strip.text = element_text(size = 16, face = 'bold'))
  
  # Set height per facet
  height_per_facet <- 2.5 # Adjust this value as needed
  num_facet_rows <- ceiling(length(unique(camels_data_long$attribute))/num_facet_cols)
  
  ggsave(out_file,
         p, 
         width = 15, 
         # Dynamically change the figure height based on the number of facet rows
         height = 3 + (height_per_facet*num_facet_rows), 
         dpi = 150)
  
  return(out_file)
}
