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

dynamo_get <- function(user) {
  res <- processx::run(
    "aws", c(
      "dynamodb", "query",
      "--table-name", "who_heat_upload",
      "--key-condition-expression", "username = :v1",
      "--expression-attribute-values", glue('{{":v1": {{"S": "{ user }"}} }}')
    ),
    error_on_status = FALSE
  )
  
  if (res$stderr != "") {
    warning(res$stderr)
    return(NULL)
  }
  
  jsonlite::fromJSON(res$stdout, simplifyDataFrame = FALSE) %>% 
    .$Items %>% 
    dplyr::bind_rows() %>% 
    tidyr::unnest()    
}

dynamo_put <- function(user, name, url, desc, size) {
  
  record <- list(
    username = list(
      S = user
    ),
    create_dt = list(
      S = format(Sys.time(), "%Y-%m-%dT%H:%M:%S")
    ),
    description = list(
      S = desc
    ),
    file_name = list(
      S = name
    ),
    file_url = list(
      S = url
    ),
    file_id = list(
      S = paste(sample(10000, 5, TRUE), collapse = "-")
    ),
    file_size = list(
      N = as.character(size)
    )
  )
  
  res <- processx::run(
    "aws", c(
      "dynamodb", "put-item",
      "--table-name", "who_heat_upload",
      "--item", jsonlite::toJSON(record, auto_unbox = TRUE)
    ),
    error_on_status = FALSE
  )
  
  if (res$stderr != "") {
    warning(res$stderr)
    return()
  }
  
  invisible(record)
}

dynamo_update <- function(email, id, new_name) {
  key <- list(file_id = list(S = id), username = list(S = email))
  value <- list(":f" = list(S = new_name))
  
  res <- processx::run(
    "aws", c(
      "dynamodb", "update-item",
      "--table-name", "who_heat_upload",
      "--key", jsonlite::toJSON(key, auto_unbox = TRUE),
      "--update-expression", "SET file_name = :f",
      "--expression-attribute-values", jsonlite::toJSON(value, auto_unbox = TRUE)
    ),
    error_on_status = FALSE
  )
  
  if (res$stderr != "") {
    warning(res$stderr)
    return()
  }
  
  invisible(new_name)
}

dynamo_delete <- function(email, id) {
  
  res <- processx::run(
    "aws", c(
      "dynamodb", "delete-item",
      "--table-name", "who_heat_upload",
      "--key", glue::glue('{{"file_id": {{"S": "{id}"}},"username": {{"S": "{email}"}} }}')
    ),
    error_on_status = FALSE
  )
  
  if (res$stderr != "") {
    warning(res$stderr)
    return(NULL)
  }
  
  invisible(id)
}

s3_exists <- function(url) {
 isTRUE(aws.s3::head_object(
   url, config::get(c("aws", "s3", "BUCKET")),
   verbose = TRUE,
   show_progress = TRUE
 ))
}

s3_save_local <- function(url) {
  if (!s3_exists(url)) {
    return(NULL)
  }
  
  t <- tempfile(fileext = ".RDA")
  
  aws.s3::save_object(url, config::get(c("aws", "s3", "BUCKET")), t)
  
  if (file_exists(t)) {
    t
  }
}

s3_delete <- function(url) {
  if (!s3_exists(url)) {
    return(NULL)
  }
  
  aws.s3::delete_object(
    url, config::get(c("aws", "s3", "BUCKET")),
    verbose = TRUE,
    show_progress = TRUE
  )
}

