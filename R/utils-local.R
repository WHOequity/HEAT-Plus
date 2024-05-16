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

local_storage <- function() {
  if (is.null(.global$local)) {
    .global$local <- config::get(c("local", "DIR"))
  } 
  
  .global$local
}

local_dir_exists <- function(dir) {
  dir_exists(path(local_storage(), dir))
}

local_dir_init <- function(dir) {
  try(dir_create(path(local_storage(), dir)), silent = TRUE)
}

local_dir_create_record <- function(dir, name) {
  try(dir_create(path(local_storage(), dir, name)), silent = TRUE)
}

local_dir_delete_record <- function(dir, name) {
  dir_delete(path(local_storage(), dir, name))
}

local_dir_has_record <- function(dir, name) {
  file_exists(path(local_storage(), dir, name))
}

local_dir_peek_record <- function(dir, name) {
  # readLines(path(local_storage(), dir, record, "NAME"))
  if (!local_dir_has_record(dir, name)) {
    return(NULL)
  }
  
  name
}

local_dir_load_record <- function(dir, name) {
  paths <- dir_ls(path(local_storage(), dir, name), glob = "*.rds")
  
  if (!length(paths)) {
    return(NULL)
  }
  
  dat <- lapply(paths, readRDS)
  names(dat) <- path_ext_remove(path_file(paths))

  dat
}

local_dir_populate_record <- function(dir, name, x) {
  stopifnot(!is.null(names(x)))
  
  n <- names(x)
  loc <- local_storage()
  
  paths <- lapply(seq_along(x), function(i) {
    p <- path(loc, dir, name, n[[i]], ext = "rds")
    saveRDS(x[[i]], p)
    p
  })
  
  paths
}

local_dir_rename_record <- function(dir, record, new) {
  # cat(new, file = path(local_storage(), dir, record, "NAME"))
  loc <- local_storage()
  file_move(path(loc, dir, record), path(loc, dir, new))
}

local_dir_check_record <- function(dir, name, files) {
  all(file_exists(path(local_storage(), dir, name, files)))
}

local_dir_list_records <- function(dir) {
  if (!local_dir_exists(dir)) {
    return(NULL)
  }
  

  path(local_storage(), dir) %>% 
    dir_info(recurse = FALSE) %>% 
    dplyr::arrange(dplyr::desc(birth_time)) %>% 
    dplyr::pull(path) %>% 
    path_file()
}

