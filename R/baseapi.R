#' Set the SODAR configuration.
#'
#' This function sets the SODAR configuration.
#'
#' @param sodar_api_token A character string containing the SODAR API token.
#' @param sodar_url A character string containing the SODAR URL.
#' @param set_options A logical value indicating whether to set the global options.
#' @return An invisible list containing the SODAR configuration.
#' @export
sodar_config <- function(sodar_api_token, sodar_url, set_options = TRUE) {

  config <- list(token = sodar_api_token, url = sodar_url)

  if(set_options) {
    options(sodar = config)
  }

  return(invisible(config))
}


# ------------------------------------------------------------
#                       Samplesheets API
# ------------------------------------------------------------

#' Retrieve details of an investigation from a project
#'
#' This function retrieves details of an investigation from a project. This
#' can be used to retrieve assay UUIDs for landing zone operations.
#' @param project_uuid A character string containing the UUID of the project.
#' @inheritParams sodar_whoami
#' @return A list with the details of the investigation.
#' @export
sodar_investigation_retrieve <- function(project_uuid, 
                                         config = NULL, 
                                         verbose = getOption("verbose", default = FALSE), 
                                         return_raw = FALSE) {

  url <- paste0("/samplesheets/api/investigation/retrieve/", project_uuid)
  response <- .request_get(url, config, verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}

#' Import an ISAtab sample sheet from a file
#' 
#' This function imports an ISAtab sample sheet from a file.
#' @param file A character string containing the path to the ISAtab zip file.
#' @param project_uuid A character string containing the UUID of the project where the sample sheet will be imported.
#' @inheritParams sodar_whoami
#' @importFrom httr upload_file
#' @return A list with the details of the import outcome.
#' @export
sodar_sheet_import <- function(project_uuid, file, config = NULL, verbose = getOption("verbose", default = FALSE), return_raw = FALSE) {

  url <- paste0("/samplesheets/api/import/", project_uuid)
  file_up <- upload_file(file)
  body <- list(file = file_up)
  response <- .request_post(url, config, body = body, encode = "multipart", verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}

#' Export an ISAtab sample sheet from a project
#'
#' This function exports an ISAtab sample sheet from a project.
#' @param project_uuid A character string containing the UUID of the project to export.
#' @param file A character string containing the name of the file to be exported.
#' @inheritParams sodar_whoami
#' @return  * sodar_sheet_export_zip: The name of the file exported.
#'  * sodar_sheet_export_json: A list with the exported isatab structure.
sodar_sheet_export_zip <- function(project_uuid, file,
                               config = NULL, verbose = getOption("verbose", default = FALSE), return_raw = FALSE) {

  url <- paste0("/samplesheets/api/export/zip/", project_uuid)
  response <- .request_get(url, config, verbose = verbose)
  result <- .request_process(response, return_raw = return_raw, process = "asis")

  if(return_raw) {
    return(result)
  }

  writeBin(result, con = file)
  return(file)
}

#' @rdname sodar_sheet_export_zip
#' @export
sodar_sheet_export_json <- function(project_uuid,
                               config = NULL, 
                               verbose = getOption("verbose", default = FALSE), 
                               return_raw = FALSE) {

  url <- paste0("/samplesheets/api/export/json/", project_uuid)
  response <- .request_get(url, config, verbose = verbose)
  result <- .request_process(response, return_raw = return_raw)

  return(result)
}



