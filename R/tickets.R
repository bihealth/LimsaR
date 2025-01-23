# ------------------------------------------------------------
#                       Tickets API
# ------------------------------------------------------------

#' Manage SODAR iRODS tickets
#'
#' These functions create, retrieve and deletes iRODS tickets.
#'
#' The tickets allow anonymous access to selected collections in a project over SODAR.
#' @param project_uuid A character string containing the UUID of the project.
#' @param path A character string containing the path to the iRODS collection.
#' @param label A character string containing the label of the ticket.
#' @param date_expires A character string containing the expiration date of the ticket.
#' @inheritParams sodar_whoami
#' @return A list with the details of the ticket.
#' @export
sodar_ticket_create <- function(project_uuid, 
                                path,
                                label,
                                date_expires = NULL,
                                config = NULL, 
                                verbose = getOption("verbose", default = FALSE), 
                                return_raw = FALSE) {

  url <- paste0("/samplesheets/api/irods/ticket/create/", project_uuid)
  body <- list(
    path = path,
    label = label,
    date_expires = date_expires
  )

  response <- .request_post(url, config, body, verbose = verbose)
  return(.request_process(response, return_raw = return_raw, expect = 201))
}

#' @rdname sodar_ticket_create
#' @export
sodar_ticket_list <- function(project_uuid, 
                              config = NULL, 
                              verbose = getOption("verbose", default = FALSE), 
                              return_raw = FALSE) {

  url <- paste0("/samplesheets/api/irods/ticket/list/", project_uuid)
  response <- .request_get(url, config, verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}

#' @param ticket_uuid A character string containing the UUID of the ticket.
#' @rdname sodar_ticket_create
#' @export
sodar_ticket_retrieve <- function(ticket_uuid, 
                                  config = NULL, 
                                  verbose = getOption("verbose", default = FALSE), 
                                  return_raw = FALSE) {

  url <- paste0("/samplesheets/api/irods/ticket/retrieve/", ticket_uuid)
  response <- .request_get(url, config, verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}

#' @rdname sodar_ticket_create
#' @export
sodar_ticket_delete <- function(ticket_uuid, 
                                config = NULL, 
                                verbose = getOption("verbose", default = FALSE), 
                                return_raw = FALSE) {

  url <- paste0("/samplesheets/api/irods/ticket/delete/", ticket_uuid)
  response <- .request_delete(url, config, verbose = verbose)
  return(.request_process(response, return_raw = return_raw, expect = 204, process = "tochar"))
}



