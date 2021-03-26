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

#' HEAT Plus
#' 
#' The HEAT Plus application.
#' 
#' @import yonder 
#' @import highcharter 
#' @import heat 
#' @import fs
#' @importFrom shiny 
#'   shinyApp NS singleton uiOutput tags span div icon h1 h2 h3
#'   h4 h5 h6 p callModule observe observeEvent reactive eventReactive req
#'   parseQueryString isolate HTML tagAppendAttributes reactiveValues
#'   updateQueryString downloadHandler downloadButton
#' @importFrom glue 
#'   glue glue_data
"_PACKAGE"
