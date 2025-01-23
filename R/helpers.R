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

# make a DELETE request
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


