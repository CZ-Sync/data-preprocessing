
#' @title For a given URL, attempt to download then retry
#' @description Handles automatic retries for internet blip type of errors
#' (aka "transient") rather than failing outright using the `httr2` package.
#' This is for basic internet file downloads, where the URL points directly to
#' the file.
#' 
#' @param file_url a character string of the URL to download the file
#' @param file_local a character string giving the filepath for where to store
#' the downloaded file locally, e.g. `data/my_file.xlsx`
#' 
download_url_safely <- function(file_url, file_local) {
  httr2::request(file_url) |>
    httr2::req_retry(max_tries = 3,
                     backoff = \(resp) 10, # Wait 10 seconds between retries
                     # Retry when these HTTP status codes popup
                     is_transient = \(resp) httr2::resp_status(resp) %in% c(429, 500, 503)) |> 
    httr2::req_perform(path = file_local)
  return(file_local)
}
