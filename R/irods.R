# ------------------------------------------------------------
#                       iRODS related stuff
# ------------------------------------------------------------

#' Create an iRODS collection for a project
#'
#' This function creates an iRODS collection for a project.
#' @param project_uuid A character string containing the UUID of the project.
#' @inheritParams sodar_whoami
#' @export
sodar_create_irods <- function(project_uuid, config = NULL, verbose = getOption("verbose", default = FALSE), return_raw = FALSE) {

  url <- paste0("/samplesheets/api/irods/collections/create/", project_uuid)
  response <- .request_post(url, config, body = NULL, verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}


#' Check if a file exists in iRODS using md5 checksum
#'
#' This function checks if a file exists in iRODS using the md5 checksum.
#'
#' @param md5 A character vector containing md5 checksums.
#' @inheritParams sodar_whoami
#' @return A named logical vector indicating whether the file exists.
sodar_file_exists <- function(md5, config = NULL, 
                                   verbose = getOption("verbose", default = FALSE), 
                                   return_raw = FALSE) {

  ret <- sapply(md5, \(x) {
    url <- paste0("/samplesheets/api/file/exists?checksum=", x)
    response <- .request_get(url, config=config, verbose = verbose)
    .request_process(response, return_raw = return_raw)$status
  })
  
  return(ret)
}

#' Retrieve the iRODS path of an assay or study
#'
#' This functions retrieves the iRODS path of an assay or study.
#'
#' It is not necessary to provide the assay UUID if there is only one assay in the project.
#' @param project_uuid A character string containing the UUID of the project.
#' @param study_uuid A character string containing the UUID of the study.
#' @param assay_uuid A character string containing the UUID of the assay.
#' @inheritParams sodar_whoami
#' @return A character string containing the iRODS path of the assay.
#' @export
sodar_assay_irods_path <- function(project_uuid,
                             study_uuid = NULL,
                             assay_uuid = NULL,
                           config = NULL,
                           verbose = getOption("verbose", default = FALSE),
                           return_raw = FALSE) {

  proj <- sodar_investigation_retrieve(project_uuid, config, verbose = verbose)

  if(is.null(study_uuid)) {
    if(length(proj$studies) == 0) {
      stop("No studies found.")
    }

    if(length(proj$studies) > 1) {
      message("Number of studies: ", length(proj$studies))
      stop("Multiple studies found. Please provide a study UUID.")
    }

    study_uuid <- proj$studies[[1]]$sodar_uuid
  }

  if(is.null(assay_uuid)) {
    if(length(proj$studies[[study_uuid]]$assays) != 1) {
      stop("Multiple assays found. Please provide an assay UUID.")
    }
    assay_uuid <- proj$studies[[study_uuid]]$assays[[1]]$sodar_uuid
  }

  return(proj$studies[[study_uuid]]$assays[[assay_uuid]]$irods_path)
}

#' @rdname sodar_assay_irods_path
#' @export
sodar_study_irods_path <- function(project_uuid,
                             study_uuid = NULL,
                           config = NULL,
                           verbose = getOption("verbose", default = FALSE),
                           return_raw = FALSE) {

  proj <- sodar_investigation_retrieve(project_uuid, config, verbose = verbose)

  if(is.null(study_uuid)) {
    if(length(proj$studies) != 1) {
      message("Number of studies: ", length(proj$studies))
      stop("Multiple studies found. Please provide a study UUID.")
    }
    study_uuid <- proj$studies[[1]]$sodar_uuid
  }

  return(proj$studies[[study_uuid]]$irods_path)
}

#' List files present in a project sample data repository
#'
#' List files present in a project sample data repository
#' @param project_uuid A character string containing the UUID of the project.
#' @inheritParams sodar_whoami
#' @export
sodar_file_list <- function(project_uuid, 
                             config = NULL, 
                             verbose = getOption("verbose", default = FALSE), 
                             return_raw = FALSE) {

  url <- paste0("/samplesheets/api/file/list/", project_uuid)
  response <- .request_get(url, config, verbose = verbose)
  return(.request_process(response, return_raw = return_raw)$irods_data)
}

#' Create and process iRODS data requests
#'
#' Create an iRODS delete request for an object or collection
#' @param project_uuid A character string containing the UUID of the project.
#' @param path A character string containing the path to the object or collection.
#' @param description A character string containing the description of the request.
#' @inheritParams sodar_whoami
#' @export
sodar_delete_request <- function(project_uuid,
                         path,
                         description = NULL,
                         config = NULL,
                         verbose = getOption("verbose", default = FALSE),
                         return_raw = FALSE) {
  message("Requesting deletion of object in project ", project_uuid, "\nPath: ", path)

  url <- paste0("/samplesheets/api/irods/request/create/", project_uuid)
  body <- list(path = path, description = description)
  response <- .request_post(url, config, body = body, verbose = verbose)
  return(.request_process(response, return_raw = return_raw, expect = 201))
}

#' @rdname sodar_delete_request
#' @export
sodar_request_list <- function(project_uuid,
                         config = NULL,
                         verbose = getOption("verbose", default = FALSE),
                         return_raw = FALSE) {
  message("Retrieving data requests for project ", project_uuid)

  url <- paste0("/samplesheets/api/irods/requests/", project_uuid)
  response <- .request_get(url, config, verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}

#' @param request_uuid A character string containing the UUID of the request 
#'        (returned by sodar_delete and sodar_request_list).
#' @rdname sodar_delete_request
#' @export
sodar_request_cancel <- function(request_uuid,
                         config = NULL,
                         verbose = getOption("verbose", default = FALSE),
                         return_raw = FALSE) {
  message("Cancelling request ", request_uuid)

  url <- paste0("/samplesheets/api/irods/request/delete/", request_uuid)
  response <- .request_delete(url, config, verbose = verbose)
  return(.request_process(response, return_raw = return_raw, expect = 204, process = "tochar"))
}


#' @param request_uuid A character string containing the UUID of the request 
#'        (returned by sodar_delete and sodar_request_list).
#' @rdname sodar_delete_request
#' @export
sodar_request_reject <- function(request_uuid,
                         config = NULL,
                         verbose = getOption("verbose", default = FALSE),
                         return_raw = FALSE) {
  message("Rejecting request ", request_uuid)

  url <- paste0("/samplesheets/api/irods/request/reject/", request_uuid)
  response <- .request_post(url, config, body=list(), verbose = verbose)
  return(.request_process(response, return_raw = return_raw, expect = 200))
}

#' @rdname sodar_delete_request
#' @export
sodar_request_accept <- function(request_uuid,
                                 config = NULL,
                                 verbose = getOption("verbose", default = FALSE),
                                 return_raw = FALSE) {

  message("Accepting request ", request_uuid)

  url <- paste0("/samplesheets/api/irods/request/accept/", request_uuid)
  response <- .request_post(url, config, body=list(), verbose = verbose)
  return(.request_process(response, return_raw = return_raw, expect = 200))
}

#' Retrieve the iRODS configuration
#'
#' Retrieve the iRODS configuration
#' @inheritParams sodar_whoami
#' @return A list with the iRODS configuration.
#' @export
sodar_irods_configuration <- function(config = NULL, verbose = getOption("verbose", default = FALSE), return_raw = FALSE) {
  url <- "/irods/api/environment"
  response <- .request_get(url, config, verbose = verbose)
  return(.request_process(response, return_raw = return_raw)$irods_environment)
}

                                      

