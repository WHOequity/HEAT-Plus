# © Copyright World Health Organization (WHO) 2016-2021.
# This file is part of the WHO Health Equity Assessment Toolkit 
# (HEAT and HEAT Plus), a software application for assessing 
# health inequalities in countries.
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>. 

azure_auth_uri <- function() {
  azure <- config::get("azure")

  with(azure, {
    AzureAuth::build_authorization_uri(
      resource = RESOURCE,
      tenant = TENANT,
      app = APP,
      redirect_uri = REDIRECT,
      version = 2,
      prompt = "login"
    )
  })
}

azure_auth_user <- function(code) {
  if (is.null(code)) {
    return()
  }

  azure <- config::get("azure")

  if (getOption("heat.debug", 0) >= 1) {
    with_verbose <- httr::with_verbose
  } else {
    with_verbose <- function(x) x
  }

  with_verbose(
    with(azure, {
      AzureAuth::get_azure_token(
        resource = RESOURCE,
        tenant = TENANT,
        app = APP,
        password = SECRET,
        auth_type = "authorization_code",
        authorize_args = list(
          redirect_uri = REDIRECT
        ),
        auth_code = code,
        use_cache = FALSE,
        version = 2
      )
    })
  )
}

azure_auth_graph <- function(user) {
  if (is.null(user)) {
    return()
  }

  azure <- config::get("azure")
  
  if (getOption("heat.debug", 0) >= 1) {
    with_verbose <- httr::with_verbose
  } else {
    with_verbose <- function(x) x
  }

  with_verbose(
    with(azure, {
      AzureGraph::create_graph_login(
        token = user
      )
    })
  )
}

azure_graph_name <- function(user) {
  if (is.null(user) || !AzureGraph::is_user(user)) {
    return(NULL)
  }
  
  props <- user$properties
  
  props$givenName %||% 
    props$userPrincipalName %||%
    props$mailNickname %||%
    props$displayName
}

azure_graph_email <- function(user) {
  if (is.null(user) || !AzureGraph::is_user(user)) {
    return(NULL)
  }
  
  props <- user$properties
  
  props$mail %||%
    (if (length(props$identities)) props$identities[[1]]$issuerAssignedId) %||%
    props$onPremisesUserPrincipalName %||%
    props$userPrincipalName %||%
    (if (length(props$otherMails)) props$otherMails[[1]])
}

azure_graph_id <- function(user) {
  if (is.null(user) || !AzureGraph::is_user(user)) {
    return(NULL)
  }
  
  props <- user$properties
  
  props$id
}
