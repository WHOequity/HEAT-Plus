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

.global <- new.env(parent = emptyenv())

highcharterDependencies <- function() {
  htmltools::htmlDependencies(highchartOutput(NULL))[-2]
}

tag_class <- function(.tag, x) {
  if (missing(x)) {
    return(.tag$attribs$class)
  }
  
  .tag$attribs$class <- x
  .tag
}

tag_content <- function(.tag, x) {
  if (missing(x)) {
    return(.tag$children)
  }
  
  .tag$children <- list()
  .tag$children[[1]] <- x
  .tag
}

str_truthy <- function(x) {
  isTRUE(nzchar(x))  
}

`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}

read_data <- function(path) {
  ext <- path_ext(path)
  
  if (ext %in% c("csv", "tsv")) {
    encodings <- path %>% 
      readr::guess_encoding() %>% 
      dplyr::pull(encoding)
    
    read_ <- if (ext == "csv") readr::read_csv else readr::read_delim
    
    for (enc in encodings) {
      result <- tryCatch(
        read_(path, locale = readr::locale(encoding = enc), guess_max = 21474836),
        error = function(e) {
          NULL
        })
      
      if (!is.null(result)) {
        return(result)
      }
    }
    
    return(NA)
  }
  
  switch(
    ext,
    xls = readxl::read_xls(path, progress = FALSE, guess_max = 21474836),
    xlsx = readxl::read_xlsx(path, progress = FALSE, guess_max = 21474836),
    NA
  )
}

retrieve_data <- function(url) {
  path_local <- s3_save_local(url)
  
  if (is.null(path_local)) {
    return(NULL)
  }
  
  on.exit({
    if (file_exists(path_local)) file_delete(path_local)
  })
  
  temp_env <- new.env(parent = emptyenv())
  
  load(path_local, envir = temp_env)
  
  list(
    main = temp_env$data_heat,
    measures = temp_env$data_measures,
    country_info = temp_env$data_country_info,
    strata = temp_env$data_strata,
    setting_yr_src = temp_env$data_setting_years
  )
}


HEATPlus_create_country_info <- function(.data) {
  country_selection <- heatdata::data_countries %>% 
    dplyr::select(setting, iso3, whoreg6, whoreg6_name, wbincome, wbincome_name)

  iso_joined <- .data %>% 
    dplyr::left_join(
      dplyr::select(country_selection, -setting), 
      by = "iso3"
    ) %>% 
  # git 381
  # setting_joined <- iso_joined %>% 
  #   dplyr::filter(is.na(whoreg6_name)) %>% 
  #   dplyr::select(-whoreg6, -whoreg6_name, -wbincome, -wbincome_name) %>% 
  #   dplyr::left_join(
  #     dplyr::select(country_selection, -iso3),
  #     by = "setting"
  #   ) %>% 
    dplyr::mutate(
      whoreg6 = dplyr::if_else(
        is.na(whoreg6_name), 
        true = "No WHO region defined", 
        false = whoreg6
      ),
      whoreg6_name = dplyr::if_else(
        is.na(whoreg6_name), 
        true = "No WHO region defined", 
        false = whoreg6_name
      ),
      wbincome = dplyr::if_else(
        is.na(wbincome_name), 
        true = "No income group defined",
        false = wbincome
      ),
      wbincome_name = dplyr::if_else(
        is.na(wbincome_name), 
        true = "No income group defined",
        false = wbincome_name
      )
    )
  # git 381
  # dplyr::bind_rows(
  #   dplyr::filter(iso_joined, !is.na(whoreg6_name)),
  #   setting_joined
  # )
  
  iso_joined
}
