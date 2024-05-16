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

#' HEAT Plus Application
#' 
#' The HEAT Plus application.
#' 
#' @export
heatPlusApp <- function(launch.browser = TRUE, port = NA) {
  if (!is_portable()) {
    aws <- config::get("aws")
    Sys.setenv(
      AWS_ACCESS_KEY_ID = aws$KEY,
      AWS_SECRET_ACCESS_KEY = aws$SECRET,
      AWS_DEFAULT_REGION = "us-east-1"
    )
  }
  
  
  port <- ifelse(is.na(port), as.numeric(config::get(c("shiny", "PORT"))), port)

  message("The port is: ", port)
  
  options(
    # shiny.launch.browser = interactive(),
    shiny.launch.browser = launch.browser,
    shiny.port = port,
    shiny.maxRequestSize = 100 * 1024^2,
    shiny.fullstacktrace = !is_portable() && interactive(),
    shiny.host = '0.0.0.0',
    heat.plus = TRUE
  )
  
  shinyApp(
    ui = heatPlusUI(),
    server = heatPlusServer()
  )
}

heatPlusUI <- function() {
  function(req) {
    qs <- parseQueryString(req$QUERY_STRING)
    
    list(
      waiter::use_waiter(),
      #htmltools::htmlDependencies(highchartOutput(NULL)),
      tags$head(
        heat::locales(),
        heat::assets(),
        assets()
      ),
      waiter::waiter_show_on_load(
        html = loading_screen(qs[["code"]]),
        color = "#008dc9"#,
        # logo = "heat-assets/img/who-logo-white.png"
      ),
      heatUI(
        id = "heatplus",
        home = homeUI("home"),
        nav_extra = dataManagementDropdown("dm")
      )
    )
  }
}

heatPlusServer <- function() {
  function(input, output, session) {
    qs <- isolate(shiny::parseQueryString(session$clientData$url_search))


    r_lang <- reactive({
      input$lang
    })
    
    m_home <- callModule(
      homeServer, "home"
    )
    
    m_auth <- callModule(
      authServer, "auth"  
    )
    
    m_data_management <- callModule(
      dataManagementServer, "dm",
      auth = m_auth, 
      open_data_manage = m_home$open_manage_data,
      language = r_lang
    )
    
    go_to_explore <- reactive({
      req(
        isolate(input[["heatplus-nav"]] == "home") && 
          !is.null(m_data_management$main())
      )
    })
    
    callModule(
      heat::heatServer, "heatplus",
      Data = m_data_management,
      open_explore = list(m_home$open_explore, go_to_explore),
      open_compare = m_home$open_compare,
      nullify = m_data_management$delete_active,
      on_data_open = function() {
        msg <- translate(c(isolate(r_lang()), "manager", "labels", "successopen"))
        print(msg)
        session$sendCustomMessage("heatplus:selected-record", list(msg = msg))
      },
      language = r_lang
    )
    
    if (!is.null(qs$code) || is_portable()) {
      session$onFlushed(function() {
 
        waiter::waiter_hide()
        showModal(heat:::licenseModal())
      })
    }
  }
}
