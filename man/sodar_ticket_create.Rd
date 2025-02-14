% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tickets.R
\name{sodar_ticket_create}
\alias{sodar_ticket_create}
\alias{sodar_ticket_list}
\alias{sodar_ticket_retrieve}
\alias{sodar_ticket_delete}
\title{Manage SODAR iRODS tickets}
\usage{
sodar_ticket_create(
  project_uuid,
  path,
  label,
  date_expires = NULL,
  config = NULL,
  verbose = getOption("verbose", default = FALSE),
  return_raw = FALSE
)

sodar_ticket_list(
  project_uuid,
  config = NULL,
  verbose = getOption("verbose", default = FALSE),
  return_raw = FALSE
)

sodar_ticket_retrieve(
  ticket_uuid,
  config = NULL,
  verbose = getOption("verbose", default = FALSE),
  return_raw = FALSE
)

sodar_ticket_delete(
  ticket_uuid,
  config = NULL,
  verbose = getOption("verbose", default = FALSE),
  return_raw = FALSE
)
}
\arguments{
\item{project_uuid}{A character string containing the UUID of the project.}

\item{path}{A character string containing the path to the iRODS collection.}

\item{label}{A character string containing the label of the ticket.}

\item{date_expires}{A character string containing the expiration date of the ticket.}

\item{config}{A list containing the SODAR configuration. If NULL, it tries to get it from the global options.}

\item{verbose}{A logical value indicating whether to make verbose requests.}

\item{return_raw}{A logical value indicating whether to return the raw response.}

\item{ticket_uuid}{A character string containing the UUID of the ticket.}
}
\value{
A list with the details of the ticket.
}
\description{
These functions create, retrieve and deletes iRODS tickets.
}
\details{
The tickets allow anonymous access to selected collections in a project over SODAR.
}
