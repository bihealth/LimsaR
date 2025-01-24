
# LimsaR

<!-- badges: start -->
<!-- badges: end -->

A simple implementation of the
[SODAR](https://www.cubi.bihealth.org/software/sodar/) API to access the
SODAR features from R.

## Installation

You can install the development version of LimsaR from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("bihealth/LimsaR")
```

## Quick start

First, you need to know what your SODAR server is. For example, it can be 
[https://sodar-demo.cubi.bihealth.org/](https://sodar-demo.cubi.bihealth.org/).

Second you need to get hold of the 
[API token](https://sodar-server.readthedocs.io/en/latest/ui_api_tokens.html). 
Without the token, you will not be able to work with LimsaR.

Once you have the server and the token, say, 'asdfb891823basdfuwerbce',
before you start working you need to configure your access. 


```r
library(LimsaR)
token <- "asdfb891823basdfuwerbce"
sodar_url <- c("https://sodar-demo.cubi.bihealth.org")
sodar_config(token, sodar_url)
```

Now you can get a data frame containing the projects and categories that
are visible to you:


```r
projects <- sodar_project_list()
```

Or check exactly who you are:

```r
sodar_whoami()
```

A large part of the SODAR API is implemented. You can create and modify the
projects. You can upload and download sample sheets. You can create and
manipulate tickets, landing zones and delete requests. For example, if you
have a project UUID and the project has a study and iRODS associated, you
can create a landing zone with

```r
lz <- sodar_lz_create(project_uuid)
# gets the UUID of the LZ
lz_uuid <- lz$sodar_uuid
```

and then check its status, and validate and move it with

```r
sodar_lz_status(lz_uuid)
sodar_lz_move(lz_uuid)
```


## SODAR API vs LimsaR

The tables below contain the current SODAR API and the names of
corresponding LimsaR functions.


### ProjectRoles:

| SODAR API function | SODAR API link | Section | Description | LimsaR function |
|--------------------|----------------|---------|-------------|-----------------|
| `projectroles.views_api.ProjectListAPIView` | `/project/api/list`  | ProjectRoles |   |  `sodar_project_list`  |
| `projectroles.views_api.ProjectRetrieveAPIView` | `/project/api/retrieve/{Project.sodar_uuid}`  | ProjectRoles |   |  `sodar_project_retrieve`  |
| `projectroles.views_api.ProjectCreateAPIView` | `/project/api/create`  | ProjectRoles |   |  `sodar_project_create`  |
| `projectroles.views_api.ProjectUpdateAPIView` | `/project/api/update/{Project.sodar_uuid}`  | ProjectRoles |   |  `sodar_project_update`  |
| `projectroles.views_api.RoleAssignmentCreateAPIView` | `/project/api/roles/create/{Project.sodar_uuid}`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.RoleAssignmentUpdateAPIView` | `/project/api/roles/update/{RoleAssignment.sodar_uuid}`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.RoleAssignmentDestroyAPIView` | `/project/api/roles/destroy/{RoleAssignment.sodar_uuid}`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.RoleAssignmentOwnerTransferAPIView` | `/project/api/roles/owner-transfer/{Project.sodar_uuid}`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.ProjectInviteListAPIView` | `/project/api/invites/list/{Project.sodar_uuid}`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.ProjectInviteCreateAPIView` | `/project/api/invites/create/{Project.sodar_uuid}`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.ProjectInviteRevokeAPIView` | `/project/api/invites/revoke/{ProjectInvite.sodar_uuid}`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.ProjectInviteResendAPIView` | `/project/api/invites/resend/{ProjectInvite.sodar_uuid}`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.ProjectSettingRetrieveAPIView` | `project/api/settings/retrieve/{Project.sodar_uuid}`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.ProjectSettingSetAPIView` | `project/api/settings/set/{Project.sodar_uuid}`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.UserSettingRetrieveAPIView` | `project/api/settings/retrieve/user`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.UserSettingSetAPIView` | `project/api/settings/set/user`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.UserListAPIView` | `/project/api/users/list`  | ProjectRoles |   |  ``  |
| `projectroles.views_api.CurrentUserRetrieveAPIView` | `/project/api/users/current`  | ProjectRoles |   |  `sodar_whoami`  |


### SampleSheets:

| SODAR API function | SODAR API link | Section | Description | LimsaR function |
|--------------------|----------------|---------|-------------|-----------------|
| `samplesheets.views_api.InvestigationRetrieveAPIView` | `/samplesheets/api/investigation/retrieve/{Project.sodar_uuid}`  | SampleSheets |   |  `sodar_investigation_retrieve`  |
| `samplesheets.views_api.SheetImportAPIView` | `/samplesheets/api/import/{Project.sodar_uuid}`  | SampleSheets |   |  `sodar_sheet_import`  |
| `samplesheets.views_api.SheetISAExportAPIView` | `/samplesheets/api/export/zip/{Project.sodar_uuid}`  for zip export | SampleSheets |   |  `sodar_sheet_export_zip`  |
| `samplesheets.views_api.SheetISAExportAPIView` | `/samplesheets/api/export/json/{Project.sodar_uuid}`  for JSON export | SampleSheets |   |  `sodar_sheet_export_json`  |
| `samplesheets.views_api.IrodsCollsCreateAPIView` | `/samplesheets/api/irods/collections/create/{Project.sodar_uuid}`  | SampleSheets |   |  `sodar_create_irods`  |
| `samplesheets.views_api.SampleDataFileExistsAPIView` | `/samplesheets/api/file/exists`  | SampleSheets |   |  `sodar_file_exists`  |
| `samplesheets.views_api.ProjectIrodsFileListAPIView` | `/samplesheets/api/file/list/{Project.sodar_uuid}`  | SampleSheets |   |  `sodar_file_list`  |
| `samplesheets.views_api.IrodsAccessTicketRetrieveAPIView` | `/samplesheets/api/irods/ticket/retrieve/{IrodsAccessTicket.sodar_uuid}`  | SampleSheets |   |  `sodar_ticket_retrieve`  |
| `samplesheets.views_api.IrodsAccessTicketListAPIView` | `/samplesheets/api/irods/ticket/list/{Project.sodar_uuid}`  | SampleSheets |   |  `sodar_ticket_list`  |
| `samplesheets.views_api.IrodsAccessTicketCreateAPIView` | `/samplesheets/api/irods/ticket/create/{Project.sodar_uuid}`  | SampleSheets |   |  `sodar_ticket_create`  |
| `samplesheets.views_api.IrodsAccessTicketUpdateAPIView` | `/samplesheets/api/irods/ticket/update/{IrodsAccessTicket.sodar_uuid}`  | SampleSheets |   |  ``  |
| `samplesheets.views_api.IrodsAccessTicketDestroyAPIView` | `/samplesheets/api/irods/ticket/delete/{IrodsAccessTicket.sodar_uuid}`  | SampleSheets |   |  `sodar_ticket_delete`  |
| `samplesheets.views_api.IrodsDataRequestRetrieveAPIView` | `/samplesheets/api/irods/request/retrieve/{IrodsDataRequest.sodar_uuid}`  | SampleSheets |   |  ``  |
| `samplesheets.views_api.IrodsDataRequestListAPIView` | `/samplesheets/api/irods/requests/{Project.sodar_uuid}`  | SampleSheets |   |  `sodar_request_list`  |
| `samplesheets.views_api.IrodsDataRequestCreateAPIView` | `/samplesheets/api/irods/request/create/{Project.sodar_uuid}`  | SampleSheets |   |  ``  |
| `samplesheets.views_api.IrodsDataRequestUpdateAPIView` | `/samplesheets/api/irods/request/update/{IrodsDataRequest.sodar_uuid}`  | SampleSheets |   |  ``  |
| `samplesheets.views_api.IrodsDataRequestDestroyAPIView` | `/samplesheets/api/irods/request/delete/{IrodsDataRequest.sodar_uuid}`  | SampleSheets |   |  `sodar_delete_request`  |
| `samplesheets.views_api.IrodsDataRequestAcceptAPIView` | `/samplesheets/api/irods/request/accept/{IrodsDataRequest.sodar_uuid}`  | SampleSheets |   |  `sodar_request_accept`  |
| `samplesheets.views_api.IrodsDataRequestRejectAPIView` | `/samplesheets/api/irods/request/reject/{IrodsDataRequest.sodar_uuid}`  | SampleSheets |   |  `sodar_request_reject`  |



### LandingZones:

| SODAR API function | SODAR API link | Section | Description | LimsaR function |
|--------------------|----------------|---------|-------------|-----------------|
| `landingzones.views_api.ZoneListAPIView` | `/landingzones/api/list/{Project.sodar_uuid}?finished={integer}`  | LandingZones |   |  `sodar_lz_list`  |
| `landingzones.views_api.ZoneRetrieveAPIView` | `/landingzones/api/retrieve/{LandingZone.sodar_uuid}`  | LandingZones |   |  `sodar_lz_retrieve`  |
| `landingzones.views_api.ZoneCreateAPIView` | `/landingzones/api/create/{Project.sodar_uuid}`  | LandingZones |   |  `sodar_lz_create`  |
| `landingzones.views_api.ZoneUpdateAPIView` | `/landingzones/api/update/{LandingZone.sodar_uuid}`  | LandingZones |   |  ``  |
| `landingzones.views_api.ZoneSubmitDeleteAPIView` | `/landingzones/api/submit/delete/{LandingZone.sodar_uuid}`  | LandingZones |   |  `sodar_lz_delete`  |
| `landingzones.views_api.ZoneSubmitMoveAPIView` | `/landingzones/api/submit/validate/{LandingZone.sodar_uuid}`  for Validation | LandingZones |   |  `sodar_lz_validate`  |
| `landingzones.views_api.ZoneSubmitMoveAPIView` | `/landingzones/api/submit/move/{LandingZone.sodar_uuid}`  for Moving | LandingZones |   |  `sodar_lz_move`  |



### iRODSinfo:

| SODAR API function | SODAR API link | Section | Description | LimsaR function |
|--------------------|----------------|---------|-------------|-----------------|
| `irodsinfo.views_api.IrodsEnvRetrieveAPIView` | `/irods/api/environment`  | iRODSinfo |   |  ``  |




## Why LimsaR

Limsa is "Soda" in Finnish.
