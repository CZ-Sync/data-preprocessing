
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
             format = 'file')
  
)

