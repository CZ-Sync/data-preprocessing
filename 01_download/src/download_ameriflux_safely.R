
#' @title Safely handle errors when downloading AmeriFlux site data
#' @description This function uses `tryCatch()` to capture errors related to
#' missing data for a site and specific data product/variant combination. It
#' returns a tibble with either a filepath of successfully downloaded data or
#' an error associated with the downloaded.
#' 
#' Arguments to this function are the same as arguments to the 
#' `amerifluxr::amf_download_fluxnet()` function and definitions should be
#' referenced in the `amerifluxr` help pages.
#' 
#' @returns a tibble with two columns, `site_id` giving the site id whose data
#' were attempted to download and `download_status` providing either a filepath
#' to successfully downloaded data or an error status.
#' 
download_ameriflux_safely <- function(user_id, user_email, site_id, data_product,
                                      data_variant, intended_use_text, out_dir) {
  file_downloaded <- tryCatch(
    amf_download_fluxnet(
      user_id = user_id,
      user_email = user_email,
      site_id = site_id,
      data_product = data_product,
      data_variant = data_variant, 
      agree_policy = TRUE,
      intended_use = "other_research",
      intended_use_text = intended_use_text,
      out_dir = out_dir,
      verbose = TRUE
    ),
    error = function(e) {
      if(grepl('Cannot find data from', e))
        'No data matched these criteria'
      else stop(e)
    })
  
  tibble(site_id = sort(site_id), # `sort()` because if you request more than one, they return downloaded data alphabetically
         download_result = file_downloaded)
}
