
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



### Sample Sheets API (`samplesheets.views_api`):

| SODAR API function | SODAR API link | LimsaR function |
|--------------------|----------------|-----------------|
| `InvestigationRetrieveAPIView` | `/samplesheets/api/investigation/retrieve/{Project.sodar_uuid}`  |  `sodar_investigation_retrieve `  |
| `SheetImportAPIView` | `/samplesheets/api/import/{Project.sodar_uuid}`  |  `sodar_sheet_import `  |
| `SheetISAExportAPIView` | `/samplesheets/api/export/zip/{Project.sodar_uuid}`  for zip export |  `sodar_sheet_export_zip `  |
| `SheetISAExportAPIView` | `/samplesheets/api/export/json/{Project.sodar_uuid}`  for JSON export |  `sodar_sheet_export_json `  |
| `IrodsCollsCreateAPIView` | `/samplesheets/api/irods/collections/create/{Project.sodar_uuid}`  |  `sodar_create_irods `  |
| `SampleDataFileExistsAPIView` | `/samplesheets/api/file/exists`  |  `sodar_file_exists `  |
| `ProjectIrodsFileListAPIView` | `/samplesheets/api/file/list/{Project.sodar_uuid}`  |  `sodar_file_list `  |
| `IrodsAccessTicketRetrieveAPIView` | `/samplesheets/api/irods/ticket/retrieve/{IrodsAccessTicket.sodar_uuid}`  |  `sodar_ticket_retrieve `  |
| `IrodsAccessTicketListAPIView` | `/samplesheets/api/irods/ticket/list/{Project.sodar_uuid}`  |  `sodar_ticket_list `  |
| `IrodsAccessTicketCreateAPIView` | `/samplesheets/api/irods/ticket/create/{Project.sodar_uuid}`  |  `sodar_ticket_create `  |
| `IrodsAccessTicketUpdateAPIView` | `/samplesheets/api/irods/ticket/update/{IrodsAccessTicket.sodar_uuid}`  |  ` `  |
| `IrodsAccessTicketDestroyAPIView` | `/samplesheets/api/irods/ticket/delete/{IrodsAccessTicket.sodar_uuid}`  |  `sodar_ticket_delete `  |
| `IrodsDataRequestRetrieveAPIView` | `/samplesheets/api/irods/request/retrieve/{IrodsDataRequest.sodar_uuid}`  |  ` `  |
| `IrodsDataRequestListAPIView` | `/samplesheets/api/irods/requests/{Project.sodar_uuid}`  |  `sodar_request_list `  |
| `IrodsDataRequestCreateAPIView` | `/samplesheets/api/irods/request/create/{Project.sodar_uuid}`  |  ` `  |
| `IrodsDataRequestUpdateAPIView` | `/samplesheets/api/irods/request/update/{IrodsDataRequest.sodar_uuid}`  |  ` `  |
| `IrodsDataRequestDestroyAPIView` | `/samplesheets/api/irods/request/delete/{IrodsDataRequest.sodar_uuid}`  |  `sodar_delete_request `  |
| `IrodsDataRequestAcceptAPIView` | `/samplesheets/api/irods/request/accept/{IrodsDataRequest.sodar_uuid}`  |  `sodar_request_accept `  |
| `IrodsDataRequestRejectAPIView` | `/samplesheets/api/irods/request/reject/{IrodsDataRequest.sodar_uuid}`  |  `sodar_request_reject `  |



### Landing Zones API (`landingzones.view_api`):

| SODAR API function | SODAR API link | LimsaR function |
|--------------------|----------------|-----------------|
| `ZoneListAPIView` | `/landingzones/api/list/{Project.sodar_uuid}?finished={integer}`  |  `sodar_lz_list `  |
| `ZoneRetrieveAPIView` | `/landingzones/api/retrieve/{LandingZone.sodar_uuid}`  |  `sodar_lz_retrieve `  |
| `ZoneCreateAPIView` | `/landingzones/api/create/{Project.sodar_uuid}`  |  `sodar_lz_create `  |
| `ZoneUpdateAPIView` | `/landingzones/api/update/{LandingZone.sodar_uuid}`  |  ` `  |
| `ZoneSubmitDeleteAPIView` | `/landingzones/api/submit/delete/{LandingZone.sodar_uuid}`  |  `sodar_lz_delete `  |
| `ZoneSubmitMoveAPIView` | `/landingzones/api/submit/validate/{LandingZone.sodar_uuid}`  for Validation |  `sodar_lz_validate `  |
| `ZoneSubmitMoveAPIView` | `/landingzones/api/submit/move/{LandingZone.sodar_uuid}`  for Moving |  `sodar_lz_move `  |



### iRODS info API (`irodsinfo.view_api`):

| SODAR API function | SODAR API link | LimsaR function |
|--------------------|----------------|-----------------|
| `IrodsEnvRetrieveAPIView` | `/irods/api/environment`  |  `sodar_irods_configuration `  |


### Project Roles API (`projectroles.view_api`):

| SODAR API function | SODAR API link | LimsaR function |
|--------------------|----------------|-----------------|
| `ProjectListAPIView` | `/project/api/list`  |  `sodar_project_list `  |
| `ProjectRetrieveAPIView` | `/project/api/retrieve/{Project.sodar_uuid}`  |  `sodar_project_retrieve `  |
| `ProjectCreateAPIView` | `/project/api/create`  |  `sodar_project_create `  |
| `ProjectUpdateAPIView` | `/project/api/update/{Project.sodar_uuid}`  |  `sodar_project_update `  |
| `RoleAssignmentCreateAPIView` | `/project/api/roles/create/{Project.sodar_uuid}`  |  ` `  |
| `RoleAssignmentUpdateAPIView` | `/project/api/roles/update/{RoleAssignment.sodar_uuid}`  |  ` `  |
| `RoleAssignmentDestroyAPIView` | `/project/api/roles/destroy/{RoleAssignment.sodar_uuid}`  |  ` `  |
| `RoleAssignmentOwnerTransferAPIView` | `/project/api/roles/owner-transfer/{Project.sodar_uuid}`  |  ` `  |
| `ProjectInviteListAPIView` | `/project/api/invites/list/{Project.sodar_uuid}`  |  ` `  |
| `ProjectInviteCreateAPIView` | `/project/api/invites/create/{Project.sodar_uuid}`  |  ` `  |
| `ProjectInviteRevokeAPIView` | `/project/api/invites/revoke/{ProjectInvite.sodar_uuid}`  |  ` `  |
| `ProjectInviteResendAPIView` | `/project/api/invites/resend/{ProjectInvite.sodar_uuid}`  |  ` `  |
| `ProjectSettingRetrieveAPIView` | `project/api/settings/retrieve/{Project.sodar_uuid}`  |  ` `  |
| `ProjectSettingSetAPIView` | `project/api/settings/set/{Project.sodar_uuid}`  |  ` `  |
| `UserSettingRetrieveAPIView` | `project/api/settings/retrieve/user`  |  ` `  |
| `UserSettingSetAPIView` | `project/api/settings/set/user`  |  ` `  |
| `UserListAPIView` | `/project/api/users/list`  |  ` `  |
| `CurrentUserRetrieveAPIView` | `/project/api/users/current`  |  `sodar_whoami `  |






## Why LimsaR

Limsa is "Soda" in Finnish.
