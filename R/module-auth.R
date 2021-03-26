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

authServer <- function(input, output, session) {
  if (is_portable()) {
    portable_username <- "User"
    
    session$sendCustomMessage("heatplus:user-login", list(
      username = portable_username
    ))
    
    return(list(
      user = function() {
        list(name = portable_username, email = "user@local.com", id = 12345)
      }
    ))
  }
  
  qs <- isolate(parseQueryString(session$clientData$url_search))
  
  if (is.null(qs$code)) {
    return(NULL)
  }
  
  auth_token <- tryCatch(
    azure_auth_user(qs$code),
    error = function(e) {
      message(e$message)
      updateQueryString("?", mode = "push")
      session$reload()
      return(NULL)
    }
  )
  
  if (is.null(auth_token)) {
    return(NULL)
  }
  
  graph_client <- azure_auth_graph(auth_token)
  auth_user <- graph_client$get_user()
  
  user_name <- azure_graph_name(auth_user)
  user_email <- azure_graph_email(auth_user)
  user_id <- azure_graph_id(auth_user)
  
  observe({
    if (!is.null(user_name)) {
      session$sendCustomMessage("heatplus:user-login", list(
        username = user_name
      ))
    }
  })
  
  list(
    user = function() {
      list(name = user_name, email = user_email, id = user_id)
    }
  )
}
