
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

### Authentication

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

If you are a user of [cubi-tk](https://github.com/bihealth/cubi-tk),
chances are you have already set up the SODAR configuration in your
`~/.cubitkrc.toml` file. In that case, you can use the `configur` package
to load the configuration:


```r
library(configr)

access <- read.config("~/.cubitkrc.toml")

sodar_config(sodar_api_token = access$global$sodar_api_token,
             sodar_url = access$global$sodar_server_url)
```




### Working with SODAR

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







## Why LimsaR

Limsa is "Soda" in Finnish.
