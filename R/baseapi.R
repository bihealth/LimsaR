#' @importFrom httr DELETE GET PATCH POST


# if config is null, try to get it from the global options
.get_sodar_config <- function(config = NULL) {

  if(is.null(config)) {
    config <- getOption("sodar")
  }

  return(config)
}

# create the headers for requests
.get_sodar_head <- function(config) {
  head <- httr::add_headers("Authorization" = paste("token", config$token, sep = " "))
  return(head)
}

.request_delete <- function(url, config, verbose = FALSE) {

  config <- .get_sodar_config(config)
  head <- .get_sodar_head(config)

  url <- paste0(config$url, url)

  if(verbose) verbose = verbose()
  else verbose = NULL

  response <- DELETE(url, head, verbose)
  return(response)
}


# make a GET request
.request_get <- function(url, config, verbose=FALSE) {

  config <- .get_sodar_config(config)
  head <- .get_sodar_head(config)

  url <- paste0(config$url, url)

  if(verbose) verbose = verbose()
  else verbose = NULL

  response <- GET(url, head, verbose)
  return(response)
}

# make a PATCH request
.request_patch <- function(url, config, body, encode = "form", verbose=FALSE) {

  config <- .get_sodar_config(config)
  head <- .get_sodar_head(config)

  url <- paste0(config$url, url)

  if(verbose) verbose = verbose()
  else verbose = NULL

  response <- PATCH(url, head, 
                  body=body,
                  encode=encode, 
                  verbose)

  return(response)
}

# make a POST request
.request_post <- function(url, config, body, encode = "form", verbose=FALSE) {

  config <- .get_sodar_config(config)
  head <- .get_sodar_head(config)

  url <- paste0(config$url, url)

  if(verbose) verbose = verbose()
  else verbose = NULL

  response <- POST(url, head, 
                  body=body,
                  encode=encode, 
                  verbose)


  return(response)
}

# process the request; handle errors if necessary
.request_process <- function(response, return_raw = FALSE, expect = 200, process = "json") {

  if(return_raw) {
    return(response)
  }

  if(response$status_code != expect) {
    stop(paste0("Error response code: ", 
                response$status_code, 
                "\nDetails:\n", 
                rawToChar(response$cont)))
  }

  if(process == "json") {
    cont <- rawToChar(response$content)
    cont <- fromJSON(cont)
  } else if(process == "asis") {
    cont <- response$content
  } else if(process == "tochar") {
    cont <- rawToChar(response$content)
  }

  return(cont)
}

#' Set the SODAR configuration.
#'
#' This function sets the SODAR configuration.
#' @param sodar_api_token A character string containing the SODAR API token.
#' @param sodar_url A character string containing the SODAR URL.
#' @param set_options A logical value indicating whether to set the global options.
#' @return A list containing the SODAR configuration.
#' @export

sodar_config <- function(sodar_api_token, sodar_url, set_options = TRUE) {

  config <- list(token = sodar_api_token, url = sodar_url)

  if(set_options) {
    options(sodar = config)
  }

  return(config)
}

# ------------------------------------------------------------
#                       SODAR CORE (Project) API
# ------------------------------------------------------------

#' Returns information about the user making the request
#'
#' Returns information about the user making the request.
#' @param config A list containing the SODAR configuration. If NULL, it tries to get it from the global options.
#' @param verbose A logical value indicating whether to make verbose requests.
#' @param return_raw A logical value indicating whether to return the raw response.
#' @export
sodar_whoami <- function(config = NULL, verbose = getOption("verbose", default = FALSE), return_raw = FALSE) {

  response <- .request_get("/project/api/users/current", config, verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}


#' Get the SODAR project list table.
#'
#' This function gets the SODAR project list table.
#'
#' The function returns a data frame flavored by the colorDF package. This allows
#' to hide multiline columns such as "readme", "roles" or "description". The columns
#' are still present in the data frame and can be accessed as usual, but
#' they are not shown in the console.
#' @inheritParams sodar_whoami
#' @return A color data frame (colorDF) containing the SODAR project list.
#' @export
#' @importFrom colorDF colorDF col_type col_type<-
#' @importFrom jsonlite fromJSON
sodar_project_list <- function(config = NULL, verbose = getOption("verbose", default = FALSE), return_raw = FALSE) {

  response <- .request_get("/project/api/list", config, verbose = verbose)
  proj_list <- .request_process(response, return_raw = return_raw)

  # by turning proj_list into a color data frame, we can hide multiline
  # columns
  class(proj_list) <- c("colorDF", class(proj_list))
  col_type(proj_list, "readme") <- "hidden"
  col_type(proj_list, "description") <- "hidden"
  col_type(proj_list, "roles") <- "hidden"
  return(proj_list)
}

#' Returns a list of all projects and categories belonging to a category
#'
#' This function returns a list of all projects and categories belonging to a given category.
#' @param category_uuid A character string containing the UUID of the category.
#' @inheritParams sodar_whoami
#' @return A color data frame (colorDF) containing the SODAR project list.
#' @export
sodar_category_list <- function(category_uuid, 
                                config = NULL, 
                                verbose = getOption("verbose", default = FALSE), 
                                return_raw = FALSE) {

  all_projects <- sodar_project_list(config, verbose, return_raw)

  if(! category_uuid %in% all_projects$sodar_uuid) {
    stop(sprintf("Category %s not found in the project list", category_uuid))
  }

  return(all_projects[all_projects$parent == category_uuid,])
}



#' Create a new project in SODAR
#'
#' This function creates a new project or category in SODAR.
#' @param title A character string containing the title of the project or category; mandatory.
#' @param parent A character string containing the UUID of the parent project or category; mandatory.
#' @param description A character string containing the description of the project or category (optional).
#' @param readme A character string containing the README of the project or category (optional).
#' @param public_guest_access A logical value indicating whether the project or category has public guest access.
#' @param owner A character string containing the UUID of the owner of the project or category. If NULL, the 
#'              current user (indicated by the API token) will be set as owner.
#' @param type A character string indicating whether it is a project or a category.
#' @inheritParams sodar_whoami
#' @return A list with the details of the project created.
#' @export
sodar_project_create <- function(title, 
                                 parent,
                                 type = "PROJECT",
                                 description = NULL,
                                 readme = NULL,
                                 public_guest_access = FALSE,
                                 owner = NULL,
                                 verbose = getOption("verbose", default = FALSE),
                                 return_raw = FALSE,
                                 config = NULL) {

  type <- match.arg(toupper(type), c("PROJECT", "CATEGORY"))

  if(is.null(owner)) {
    message("Trying to get the current user as owner...")
    user <- sodar_whoami(config, verbose = verbose)
    message(sprintf("Owner: [%s](%s) UUID=%s",
                    user$name, user$email, user$sodar_uuid))
    owner <- user$sodar_uuid
  }

  if(is.null(owner)) {
    stop("No owner defined")
  }

  body <- list(title = title,
               parent = parent,
               type = type,
               readme = readme,
               public_guest_access = public_guest_access,
               description = description,
               owner = owner
           )

  response <- .request_post("/project/api/create", config, body, verbose = verbose)
  return(.request_process(response, return_raw = return_raw, expect = 201))
}

#' Update a project or category in SODAR
#'
#' This function updates a project or category in SODAR.
#' @param project_uuid A character string containing the UUID of the project or category.
#' @inheritParams sodar_project_create
#' @return A list with the details of the project updated.
#' @export
sodar_project_update <- function(project_uuid, 
                                 title = NULL, 
                                 parent = NULL,
                                 description = NULL,
                                 readme = NULL,
                                 public_guest_access = NULL,
                                 verbose = getOption("verbose", default = FALSE),
                                 return_raw = FALSE,
                                 config = NULL) {

  message("Retrieving project details...")
  proj <- sodar_project_retrieve(project_uuid, config, verbose = verbose)
  type <- proj$type
  
  body <- list(title = title,
               type = type,
               parent = parent,
               readme = readme,
               public_guest_access = public_guest_access,
               description = description
           )

  body <- body[!sapply(body, is.null)]
  any_differences <- sapply(names(body), \(x) body[[x]] != proj[[x]])

  if(! any(any_differences)) {
    message("No changes detected. Exiting...")
    return(NULL)
  }

  url <- paste0("/project/api/update/", project_uuid)
  response <- .request_patch(url, config, body, verbose = verbose)
  return(.request_process(response, return_raw = return_raw))
}

# convert the roles list to a usable data frame
.roles_to_df <- function(roles) {

  rlist <- lapply(roles, \(x) {
    data.frame(
      uuid = x$sodar_uuid,
      name = x$user$name,
      email = x$user$email,
      role = x$role,
      user_uuid = x$user$sodar_uuid,
      inherited = x$inherited,
      is_superuser = x$user$is_superuser)
   })
  df <- do.call(rbind, rlist)
  rownames(df) <- NULL
  class(df) <- c("colorDF", class(df))
  col_type(df, c("uuid")) <- "hidden"

  return(df)
}

#' Retrieve details of a project or category
#'
#' This function retrieves details of a project or category.
#' @param project_uuid A character string containing the UUID of the project or category.
#' @inheritParams sodar_whoami
#' @return A list with the details of the project or category.
#' @export
sodar_project_retrieve <- function(project_uuid, 
                                   config = NULL, 
                                   verbose = getOption("verbose", default = FALSE), 
                                   return_raw = FALSE) {

  url <- paste0("/project/api/retrieve/", project_uuid)
  response <- .request_get(url, config, verbose = verbose)
  ret <- .request_process(response, return_raw = return_raw)
  if(!is.null(ret$roles)) {
    ret$roles <- .roles_to_df(ret$roles)
  }
  return(ret)
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
