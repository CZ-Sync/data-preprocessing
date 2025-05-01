
#' @title Extract a file from a zip file
#' @description Use the `zip::unzip()` function to pull a specific file from
#' a zip file and move into a new location.
#' 
#' @param out_file a character string indicating a file path to save the file
#' @param zip_file a character string giving the zip file's path
#' @param file_to_extract character string giving the file(s) stored in the 
#' zip file that will be copied to a new location. 
#' 
#' @return a filepath specifying the name and location of the extracted file
#'
extract_file_from_zip <- function(out_file, zip_file, file_to_extract) {
  
  # Unzip and extract the file(s) of interest
  zipdir <- tempdir()
  zip::unzip(zipfile = zip_file,
             files = file_to_extract,
             exdir = zipdir)
  
  # Copy from the temporary directory into the desired location
  file.copy(from = file.path(zipdir, file_to_extract), 
            to = out_file)
  
  return(out_file)
}

#' @title Find a file within a zip file
#' @description Use the `zip::zip_list()` function to identify a file from
#' inside a zip file that matches a specific pattern.
#' 
#' @param zip_file a character string giving the zip file's path
#' @param file_pattern character string giving the regex pattern to search
#' 
#' @return a filepath specifying the name and location of the matched file
#'
identify_file_in_zip <- function(zip_file, file_pattern) {
  zip_files <- zip::zip_list(zip_file)
  file_matched <- zip_files$filename[grepl(file_pattern, zip_files$filename)]
  return(file_matched)
}

#' @title Find and move a file in one function
#' @description Use `identify_file_in_zip()` along with `extract_file_from_zip()`
#' to find and move a file in one function. Handles cases where there is no 
#' file found.
#' 
#' @param out_dir a character string indicating a directory to move the file
#' @param zip_file a character string giving the zip file's path
#' @param file_pattern character string giving the regex pattern to search
#' 
#' @return a filepath specifying the name and location of the extracted file
#'
move_file_from_zip <- function(out_dir, zip_file, file_pattern) {
  
  file_nm <- identify_file_in_zip(zip_file, file_pattern)
  out_file <- extract_file_from_zip(file.path(out_dir, file_nm), 
                                    zip_file, file_nm)
  
  return(out_file)
}
