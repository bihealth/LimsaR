# ------------------------------------------------------------
#                       Landing Zones API
# ------------------------------------------------------------


#' List landing zones for a project
#'
#' This function lists landing zones for a project.
#'
#' @param project_uuid A character string containing the UUID of the project.
#' @inheritParams sodar_whoami
#' @seealso sodar_lz_retrieve sodar_lz_create
#' @return A colorDF data frame with the details of the landing zones.
#' Several columns are hidden for better readability, but can still be
#' accessed.
sodar_lz_list <- function(project_uuid, verbose = getOption("verbose", default = FALSE), config = NULL) {

  url <- paste0("/landingzones/api/list/", project_uuid)

  response <- .request_get(url, config, verbose = verbose)
  ret <- .request_process(response, return_raw = FALSE)
  if(length(ret) == 0) {
    message("No landing zones found")
    return(NULL)
  }
  class(ret) <- c("colorDF", class(ret))
  col_type(ret, "assay") <- "hidden"
  col_type(ret, "user") <- "hidden"
  col_type(ret, "description") <- "hidden"
  col_type(ret, "configuration") <- "hidden"
  col_type(ret, "config_data") <- "hidden"
  col_type(ret, "irods_path") <- "hidden"
  col_type(ret, "project") <- "hidden"
  col_type(ret, "user_message") <- "hidden"

  return(ret)
}


#' Create a landing zone for a project
#'
#' This function creates a landing zone for a project.
#' @param project_uuid A character string containing the UUID of the project.
#' @param create_colls A logical value indicating whether to create collections for the landing zone.
#' @param restrict_colls A logical value indicating whether to restrict collections for the landing zone.
#' @param title A character string containing the title suffix of the landing zone.
#' @param assay_uuid A character string containing the UUID of the assay to associate with 
#'        the landing zone. If NULL, the first assay found will be used.
#' @inheritParams sodar_whoami
#' @return A list with the details of the landing zone created.
#' @seealso sodar_lz_retrieve sodar_lz_list
#' @export
sodar_lz_create <- function(project_uuid, 
                            create_colls = TRUE, 
                            restrict_colls = TRUE, 
                            title = "",
                            assay_uuid = NULL, 
                            config = NULL,
                            verbose = getOption("verbose", default = FALSE),
                            return_raw = FALSE) {

  url <- paste0("/landingzones/api/create/", project_uuid)

  if(is.null(assay_uuid)) {
    message("No assay UUID provided. Trying to get the first assay found...")
    investigation <- sodar_investigation_retrieve(project_uuid, config, verbose = verbose)
    assay_uuid <- investigation$studies[[1]]$assays[[1]]$sodar_uuid
    message("Creating landing zone for assay", assay_uuid)
  }

  body <- list(title = title,
               create_colls = create_colls,
               restrict_colls = restrict_colls,
               assay = assay_uuid)

  response <- .request_post(url, config, body, verbose = verbose)
  return(.request_process(response, return_raw = return_raw, expect = 201))
}


#' Handling existing landing zones
#'
#' This functions retrieve information about a landing zone for a project,
#' delete existing landing zones etc.
#' @param lz_uuid A character string containing the UUID of the landing zone.
#' @inheritParams sodar_whoami
#' @return A list with the details of the landing zone.
#' @export
sodar_lz_retrieve <- function(lz_uuid, config = NULL, verbose = getOption("verbose", default = FALSE), return_raw = FALSE) {

  url <- paste0("/landingzones/api/retrieve/", lz_uuid)
  response <- .request_get(url, config, verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}

#' @rdname sodar_lz_retrieve
#' @export
sodar_lz_status <- function(lz_uuid, config = NULL, verbose = getOption("verbose", default = FALSE)) {
  return(sodar_lz_retrieve(lz_uuid, config, verbose = verbose, return_raw = FALSE)$status)
}

#' @rdname sodar_lz_retrieve
#' @export
sodar_lz_delete <- function(lz_uuid, config = NULL, verbose = getOption("verbose", default = FALSE), return_raw = FALSE) {
  message("Initiating landing zone deletion...")
  url <- paste0("/landingzones/api/submit/delete/", lz_uuid)
  response <- .request_post(url, config, body = NULL, verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}

#' @param move A logical value indicating whether to move the landing zone
#' after validation.
#' @rdname sodar_lz_retrieve
#' @export
sodar_lz_move <- function(lz_uuid, move = TRUE, config = NULL, 
                          verbose = getOption("verbose", default = FALSE), return_raw = FALSE) {
  if(move) {
    message("Initiating landing zone validation and move...")
    url <- paste0("/landingzones/api/submit/move/", lz_uuid)
  } else {
    message("Initiating landing zone validation...")
    url <- paste0("/landingzones/api/submit/validate/", lz_uuid)
  }

  response <- .request_post(url, config, body = NULL, verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}

#' @rdname sodar_lz_retrieve
#' @export
sodar_lz_validate <- function(lz_uuid, config = NULL, 
                          verbose = getOption("verbose", default = FALSE), return_raw = FALSE) {
  sodar_lz_move(lz_uuid, move = FALSE, config = config, verbose = verbose, return_raw = return_raw)
}
