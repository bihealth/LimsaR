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



