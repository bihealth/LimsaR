
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

The table below contains the current SODAR API and the names of
corresponding LimsaR functions.


| SODAR API function | SODAR API link | Area | GET or POST | Description | LimsaR function |
|--------------------|----------------|------|-------------|-------------|-----------------|
| `projectroles.views_api.ProjectListAPIView` | `/project/api/list` notes= | ClassRoles | GET |   |  `sodar_`  |
| `projectroles.views_api.ProjectRetrieveAPIView` | `/project/api/retrieve/{Project.sodar_uuid}` notes= | ClassRoles | GET |   |  `sodar_`  |
| `projectroles.views_api.ProjectCreateAPIView` | `/project/api/create` notes= | ClassRoles | POST |   |  `sodar_`  |
| `projectroles.views_api.ProjectUpdateAPIView` | `/project/api/update/{Project.sodar_uuid}` notes= | ClassRoles |   |   |  `sodar_`  |
| `projectroles.views_api.RoleAssignmentCreateAPIView` | `/project/api/roles/create/{Project.sodar_uuid}` notes= | ClassRoles | POST |   |  `sodar_`  |
| `projectroles.views_api.RoleAssignmentUpdateAPIView` | `/project/api/roles/update/{RoleAssignment.sodar_uuid}` notes= | ClassRoles |   |   |  `sodar_`  |
| `projectroles.views_api.RoleAssignmentDestroyAPIView` | `/project/api/roles/destroy/{RoleAssignment.sodar_uuid}` notes= | ClassRoles |   |   |  `sodar_`  |
| `projectroles.views_api.RoleAssignmentOwnerTransferAPIView` | `/project/api/roles/owner-transfer/{Project.sodar_uuid}` notes= | ClassRoles | POST |   |  `sodar_`  |
| `projectroles.views_api.ProjectInviteListAPIView` | `/project/api/invites/list/{Project.sodar_uuid}` notes= | ClassRoles | GET |   |  `sodar_`  |
| `projectroles.views_api.ProjectInviteCreateAPIView` | `/project/api/invites/create/{Project.sodar_uuid}` notes= | ClassRoles | POST |   |  `sodar_`  |
| `projectroles.views_api.ProjectInviteRevokeAPIView` | `/project/api/invites/revoke/{ProjectInvite.sodar_uuid}` notes= | ClassRoles | POST |   |  `sodar_`  |
| `projectroles.views_api.ProjectInviteResendAPIView` | `/project/api/invites/resend/{ProjectInvite.sodar_uuid}` notes= | ClassRoles | POST |   |  `sodar_`  |
| `projectroles.views_api.ProjectSettingRetrieveAPIView` | `project/api/settings/retrieve/{Project.sodar_uuid}` notes= | ClassRoles | GET |   |  `sodar_`  |
| `projectroles.views_api.ProjectSettingSetAPIView` | `project/api/settings/set/{Project.sodar_uuid}` notes= | ClassRoles | POST |   |  `sodar_`  |
| `projectroles.views_api.UserSettingRetrieveAPIView` | `project/api/settings/retrieve/user` notes= | ClassRoles | GET |   |  `sodar_`  |
| `projectroles.views_api.UserSettingSetAPIView` | `project/api/settings/set/user` notes= | ClassRoles | POST |   |  `sodar_`  |
| `projectroles.views_api.UserListAPIView` | `/project/api/users/list` notes= | ClassRoles | GET |   |  `sodar_`  |
| `projectroles.views_api.CurrentUserRetrieveAPIView` | `/project/api/users/current` notes= | ClassRoles | GET |   |  `sodar_`  |
| `irodsinfo.views_api.IrodsEnvRetrieveAPIView` | `/irods/api/environment` notes= | iRODSinfo | GET |   |  `sodar_`  |
| `landingzones.views_api.ZoneListAPIView` | `/landingzones/api/list/{Project.sodar_uuid}?finished={integer}` notes= | LandingZones | GET |   |  `sodar_`  |
| `landingzones.views_api.ZoneRetrieveAPIView` | `/landingzones/api/retrieve/{LandingZone.sodar_uuid}` notes= | LandingZones | GET |   |  `sodar_`  |
| `landingzones.views_api.ZoneCreateAPIView` | `/landingzones/api/create/{Project.sodar_uuid}` notes= | LandingZones | POST |   |  `sodar_`  |
| `landingzones.views_api.ZoneUpdateAPIView` | `/landingzones/api/update/{LandingZone.sodar_uuid}` notes= | LandingZones |   |   |  `sodar_`  |
| `landingzones.views_api.ZoneSubmitDeleteAPIView` | `/landingzones/api/submit/delete/{LandingZone.sodar_uuid}` notes= | LandingZones | POST |   |  `sodar_`  |
| `landingzones.views_api.ZoneSubmitMoveAPIView` | `/landingzones/api/submit/validate/{LandingZone.sodar_uuid}` notes= for Validation | LandingZones | POST |   |  `sodar_`  |
| `landingzones.views_api.ZoneSubmitMoveAPIView` | `/landingzones/api/submit/move/{LandingZone.sodar_uuid}` notes= for Moving | LandingZones | POST |   |  `sodar_`  |
| `samplesheets.views_api.InvestigationRetrieveAPIView` | `/samplesheets/api/investigation/retrieve/{Project.sodar_uuid}` notes= | SampleSheets | GET |   |  `sodar_`  |
| `samplesheets.views_api.SheetImportAPIView` | `/samplesheets/api/import/{Project.sodar_uuid}` notes= | SampleSheets | POST |   |  `sodar_`  |
| `samplesheets.views_api.SheetISAExportAPIView` | `/samplesheets/api/export/zip/{Project.sodar_uuid}` notes= for zip export | SampleSheets | GET |   |  `sodar_`  |
| `samplesheets.views_api.SheetISAExportAPIView` | `/samplesheets/api/export/json/{Project.sodar_uuid}` notes= for JSON export | SampleSheets | GET |   |  `sodar_`  |
| `samplesheets.views_api.IrodsCollsCreateAPIView` | `/samplesheets/api/irods/collections/create/{Project.sodar_uuid}` notes= | SampleSheets | POST |   |  `sodar_`  |
| `samplesheets.views_api.SampleDataFileExistsAPIView` | `/samplesheets/api/file/exists` notes= | SampleSheets | GET |   |  `sodar_`  |
| `samplesheets.views_api.ProjectIrodsFileListAPIView` | `/samplesheets/api/file/list/{Project.sodar_uuid}` notes= | SampleSheets | GET |   |  `sodar_`  |
| `samplesheets.views_api.IrodsAccessTicketRetrieveAPIView` | `/samplesheets/api/irods/ticket/retrieve/{IrodsAccessTicket.sodar_uuid}` notes= | SampleSheets | GET |   |  `sodar_`  |
| `samplesheets.views_api.IrodsAccessTicketListAPIView` | `/samplesheets/api/irods/ticket/list/{Project.sodar_uuid}` notes= | SampleSheets | GET |   |  `sodar_`  |
| `samplesheets.views_api.IrodsAccessTicketCreateAPIView` | `/samplesheets/api/irods/ticket/create/{Project.sodar_uuid}` notes= | SampleSheets | POST |   |  `sodar_`  |
| `samplesheets.views_api.IrodsAccessTicketUpdateAPIView` | `/samplesheets/api/irods/ticket/update/{IrodsAccessTicket.sodar_uuid}` notes= | SampleSheets |   |   |  `sodar_`  |
| `samplesheets.views_api.IrodsAccessTicketDestroyAPIView` | `/samplesheets/api/irods/ticket/delete/{IrodsAccessTicket.sodar_uuid}` notes= | SampleSheets |   |   |  `sodar_`  |
| `samplesheets.views_api.IrodsDataRequestRetrieveAPIView` | `/samplesheets/api/irods/request/retrieve/{IrodsDataRequest.sodar_uuid}` notes= | SampleSheets | GET |   |  `sodar_`  |
| `samplesheets.views_api.IrodsDataRequestListAPIView` | `/samplesheets/api/irods/requests/{Project.sodar_uuid}` notes= | SampleSheets | GET |   |  `sodar_`  |



## Why LimsaR

Limsa is "Soda" in Finnish.
