
# Source the files with custom functions called by the targets
tar_source('03_summarize/src')

p3 <- list(
  
  #### Summaries of CAMELS data ####
  
  # Create a grouped tibble by category to enable mapping in next target
  tar_target(p3_camels_data_numeric_long_grpCategory,
             p2_camels_data_numeric_long %>% 
               group_by(category) %>% 
               tar_group(),
             iteration = 'group'),
  
  # Create a PNG showing boxplots of attribute values per CAMELS category
  tar_target(p3_camels_dist_by_huc_png,
             camels_boxplot_attribute_vals(
               out_file = sprintf('03_summarize/figures/boxplot_%s.png', 
                                  unique(p3_camels_data_numeric_long_grpCategory$category)),
               camels_data_long = p3_camels_data_numeric_long_grpCategory
             ),
             pattern = map(p3_camels_data_numeric_long_grpCategory),
             format = 'file'),
  
  #### Summaries of AmeriFlux data ####
  
  # Create a PNG showing boxplots of AmeriFlux variable values by vegetation category
  tar_target(p3_ameriflux_dist_by_veg_png,
             ameriflux_boxplot_variable_vals('03_summarize/figures/boxplot_ameriflux.png',
                                             p2_ameriflux_data_long,
                                             p2_ameriflux_site_info),
             format = 'file'),
  
  # Create a PNG showing an example timeseries of AmeriFlux variable values for a single site
  tar_target(p3_ameriflux_timeseries_sites, c('US-A32')),
  tar_target(p3_ameriflux_timeseries_png,
             ameriflux_timeseries(sprintf('03_summarize/figures/timeseries_ameriflux_%s.png',
                                          p3_ameriflux_timeseries_sites),
                                  p2_ameriflux_data_long,
                                  p3_ameriflux_timeseries_sites),
             pattern = map(p3_ameriflux_timeseries_sites),
             format = 'file')
)

