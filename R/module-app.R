# # © Copyright World Health Organization (WHO) 2016-2021.
# # This file is part of the WHO Health Equity Assessment Toolkit 
# # (HEAT and HEAT Plus), a software application for assessing 
# # health inequalities in countries.
# # 
# # This program is free software: you can redistribute it and/or modify
# # it under the terms of the GNU Affero General Public License as
# # published by the Free Software Foundation, either version 3 of the
# # License, or (at your option) any later version.
# # 
# # This program is distributed in the hope that it will be useful,
# # but WITHOUT ANY WARRANTY; without even the implied warranty of
# # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# # GNU Affero General Public License for more details.
# # 
# # You should have received a copy of the GNU Affero General Public License
# # along with this program.  If not, see <https://www.gnu.org/licenses/>. 
# 
# appTemplate <- function(id) {
#   ns <- NS(id)
#   
#   list(
#     # ├─ includes ----
#     singleton(
#       tags$head(
#         tags$script(src = "heat/js/main.js", type = "text/javascript"),
#         tags$link(rel = "stylesheet", href = "heatplus/css/main.css"),
#         tags$script(src = "heat/html2canvas/html2canvas.min.js", type = "text/javascript"),
#         highcharterDependencies()
#       )
#     ),
#     
#     # ├─ navigation ----
#     tags$header(
#       navbar(
#         brand = div(
#           tags$img(
#             height = "30px",
#             src = "heat/img/who-logo-white.svg"
#           ),
#           span("Health Equity Assessment Toolkit Plus") %>%
#             font(color = "white", weight = "bold") %>%
#             margin(left = 3)
#         ) %>%
#           display("flex") %>%
#           flex(align = "center"),
#         navInput(
#           class = "hover-open",
#           appearance = "pills",
#           id = ns("page"),
#           # │ ├─ choices ----
#           choices = list(
#             span("Home") %>%
#               font(color = "white"),
#             menuInput(
#               id = ns("explore"),
#               label = "Explore",
#               align = "right",
#               choices = c(
#                 "Disaggregated data", # @translate
#                 "Summary data"        # @translate
#               ),
#               values = c(
#                 "explore_disag",
#                 "explore_summary"
#               )
#             ) %>%
#               font(color = "white"),
#             menuInput(
#               id = ns("compare"),
#               label = "Compare",
#               align = "right",
#               choices = c(
#                 "Disaggregated data", # @translate
#                 "Summary data"        # @translate
#               ),
#               values = c(
#                 "compare_disag",
#                 "compare_summary"
#               )
#             ) %>%
#               font(color = "white"),
#             menuInput(
#               id = ns("static"),
#               label = "About",
#               align = "right",
#               choices = c(
#                 "User manual",          # @translate
#                 "Technical notes",      # @translate
#                 "Indicator compendium", # @translate
#                 "Software",             # @translate
#                 "Versions",             # @translate
#                 "License",              # @translate
#                 "Feedback",             # @translate
#                 "Acknowledgements"      # @translate
#               ),
#               values = c(
#                 "usermanual",
#                 "technotes",
#                 "glossary",
#                 "software",
#                 "versions",
#                 "license",
#                 "feedback",
#                 "acknowledgements"
#               )
#             ) %>%
#               font(color = "white")
#           ),
#           # │ ├─ values ----
#           values = c("home", "explore", "compare", "static"),
#           selected = "home"
#         ) %>%
#           margin(left = "auto") %>%
#           active("green"),
#         buttonInput(
#           id = ns("language"),
#           label = icon("language", class = "fa-fw fa-lg")
#         ) %>%
#           height(2) %>% 
#           background("blue") %>%
#           display("flex") %>%
#           flex(align = "center", justify = "around"),
#         authTemplate(
#           id = ns("auth")
#         )
#       ) %>%
#         background("blue") %>%
#         shadow("small") %>%
#         margin(bottom = 3) %>%
#         affix("top")
#     ),
#     
#     # ├─ content ----
#     container(
#       navContent(
#         class = "app-panes",
#         navPane(
#           id = ns("pane_home"),
#           fade = FALSE,
#           homePaneTemplate(
#             id = ns("home"),
#             recordsTemplate(ns("db"))
#           )
#         ),
#         navPane(
#           id = ns("pane_main"),
#           fade = FALSE,
#           heat:::mainTemplate(ns("main"))
#         ),
#         # │ ├─ static ----
#         navPane(
#           id = ns("pane_static"),
#           "Static"
#         )
#       ) %>%
#         height("full")
#     ) %>%
#       height("screen")
#   )
# }
# 
# appServer <- function(input, output, session) {
#   ns <- session$ns
#   browser()
#   # ├─ [change] page ----
#   observe({
#     req(input$page)
#     
#     if (input$page == "home") {
#       showNavPane(ns("pane_home"))
#     } else if (input$page == "static") {
#       showNavPane(ns("pane_static"))
#     } else {
#       showNavPane(ns("pane_main"))
#     }
#   })
#   
#   auth <- callModule(
#     module = authServer,
#     id = "auth"
#   )
#   
#   records <- callModule(
#     module = recordsServer,
#     id = "db",
#     auth = auth
#   )
#   
#   data <- list(
#     main = reactive({
#       records()$main
#     }),
#     measures = reactive({
#       records()$measures
#     }),
#     countries = reactive({
#       records()$countries
#     })
#   )
#   
#   
#   main <- callModule(
#     heat:::mainServer, "main",
#     data = data,
#     view = reactive({
#       req(input$page %in% c("explore", "compare"))
#       
#       if (input$page == "explore") input$explore else input$compare
#     })
#   )
# 
# }
