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

sql_config <- function() {
  config::get("sql")
}

sql_connect <- function() {
  with(sql_config(), {
    DBI::dbConnect(
      driver = DRIVER,
      database = DATABASE,
      uid = UID,
      pwd = PWD,
      host = HOST,
      port = PORT
    )
  })
}

sql_user_put <- function(user, token) {
  # called when adding new user  
}

sql_user_get <- function(user, token) {
  # user != token then bad auth
}
