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

loading_screen <- function(code) {
  if (is_portable()) {
    loading_screen_initialize()
  } else if (is.null(code)) {
    loading_screen_redirect()
  } else {
    loading_screen_initialize()
  }
}

loading_screen_redirect <- function() {
  div(
    div(style="display: block; margin-left: auto; margin-right: auto; width: 30%",
        img("heat-assets/img/who-logo-white.png")
    ),
    d2("Health Equity Assessment Toolkit") %>% 
      font(color = "white"),
    d2("Plus") %>%
      font(color = "green") %>%
      margin(bottom = 5, right = 2, left = 2),
    div(
      buttonInput(
        class = "btn-lg",
        id = NULL,
        label = list("Login with Microsoft", shiny::icon("arrow-up-right-from-square")),
        onclick = HTML(glue::glue(
          "window.location.replace('{ azure_auth_uri() }')"
        ))
      ) %>% 
        font(size = "xl") %>% 
        background("green")
    ) %>%
      margin(top = -2)
  )
}
loading_screen_initialize <- function() {
  div(
    div(style="display: block; margin-left: auto; margin-right: auto; width: 30%",
        img("heat-assets/img/who-logo-white.png")
    ),
    d2("Health Equity Assessment Toolkit") %>% 
      font(color = "white"),
    d2("Plus") %>%
      font(color = "green") %>%
      margin(bottom = 5, right = 2, left = 2),
    tags$h1("Initializing") %>%
      font(color = "white"),
    div(
      waiter::spin_circle()
    ) %>%
      margin(top = -2)
  )
}