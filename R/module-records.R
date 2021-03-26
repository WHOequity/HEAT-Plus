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

dataManagementDropdown <- function(id) {
  ns <- NS(id)
  
  if (is_portable()) {
    return(
      dropdown(
        class = "mr-2",
        align = "right",
        label = span(
          icon("user", class = "ml-1"),
          span(
            class = "heat-plus-management-dropdown__label"
          )
        ),
        buttonInput(
          id = ns("manage"),
          label = div(i18n("manager.labels.managedata"))
        )
      )
    )
  }
  
  dropdown(
    align = "right",
    class = "mr-2",
    label = span(
      icon("user", class = "ml-1"),
      span(
        class = "heat-plus-management-dropdown__label"
      )
    ),
    buttonInput(
      id = ns("manage"),
      label = div(i18n("manager.labels.managedata")) #"Manage data"
    ),
    tags$a(
      class = "btn btn-grey",
      role = "button",
      href = "https://account.microsoft.com/account/manage-my-account",
      target = "_blank",
      i18n("navigation.labels.account") # Go to account
    ),
    buttonInput(
      id = ns("logout"),
      label = div(i18n("navigation.labels.logout")) #"Logout"
    )
  )
}

dataManagementRecord <- function(name, activate = FALSE) {
  div(
    class = paste(
      "list-group-item heat-plus-record",
      if (activate) "active"
    ),
    `data-record` = name,
    div(
      class = "heat-plus-record__icon",
      tags$i(class = "far fa-circle inactive-icon"),
      tags$i(class = "far fa-dot-circle active-icon"),
      tags$i(class = "fas fa-spinner fa-pulse progress-icon")
    ),
    div(
      class = "heat-plus-record__entry",
      tags$input(
        class = "heat-plus-record__input",
        value = name
      ),
      tags$small(
        class = "heat-plus-record__warning"
      )
    ),
    buttonGroupInput(
      class = "heat-plus-record__buttons",
      id = NULL,
      choices = list(
        icon("pencil-alt"),
        icon("trash-alt")
      ),
      values = c(
        "edit",
        "delete"
      )
    )  
  )
}

dataManagementModal <- function(ns, records, active = NULL, language = NULL) {
  items <- lapply(records, function(r) {
    dataManagementRecord(r, activate = isTRUE(r == active))
  })
  
  lang <- language
  
  m <- modal(
    size = "lg",
    id = ns("modal"),
    header = h5(i18n("manager.labels.managedata")) %>% margin(bottom = 0),
    h5(i18n("manager.labels.uploadnew")), #"Upload new database"
    formGroup(
      label = list(
        h6(i18n("manager.labels.select")) %>% #Select database
          display("inline"),
        icon("info-circle") %>% 
          tagAppendAttributes(
            `data-toggle` = "tooltip",
            #
            # translate() example
            #
            title = translate(c(lang, "manager", "labels", "disclaimer"))
            # title = "Databases require a specific format in order to be uploaded to HEAT Plus. The HEAT Plus template exemplifies the required structure, variables, order, etc. Please refer to the HEAT Plus user manual for further information on specific requirements and instructions on how to prepare databases for use in HEAT Plus."
          )
      ),
      fileInput(
        id = ns("new_database"),
        class = "heat-plus-management-upload",
        placeholder = translate(c(lang, "manager", "labels", "choose")), #"Choose file",
        multiple = FALSE,
        browse = translate(c(lang, "manager", "labels", "browse"))
      ),
      #
      # This is not simple to translate as it currently is
      #
      help = div(
        translate(c(lang, "manager", "labels", "downloads")), #"Download the",
        tags$a(
          href = "heatplus-assets/locales/en/heat_plus_template_validation.xlsm",
          download = NA,
          translate(c(lang, "manager", "labels", "downloadsa")) #"template and validation tool"
        ),
        translate(c(lang, "manager", "labels", "downloadsb")), #"and",
        tags$a(
          href = "heatplus-assets/locales/en/User_manual.pdf",
          download = NA,
          translate(c(lang, "manager", "labels", "downloadsc")), #"user manual"
        )
        # downloadButton(ns("template")) %>% 
        #   tag_class("btn-link shiny-download-link") %>% 
        #   tag_content("template"),
        # "and",
        # downloadButton(ns("user_manual")) %>% 
        #   tag_class("btn-link shiny-download-link") %>% 
        #   tag_content("user manual"),
        # "."
      )
    ),
    formGroup(
      label = h6(i18n("manager.labels.saveas")), #Save database as
      textInput(
        class = "heat-plus-management-save-as",
        id = ns("save_database_as"),
        #
        # translate() example
        #
        placeholder = translate(c(lang, "manager", "labels", "choosename")) %||% "missing", # "Choose filename"
      )
    ),
    buttonInput(
      class = "heat-plus-management-begin",
      disabled = NA,
      id = ns("upload_database"),
      #
      # translate() example
      #
      label = translate(c(lang, "manager", "labels", "upload")) %||% "missing" # "Upload database"
    ) %>% 
      background("green") %>% 
      margin(bottom = 2),
    div(
      class = "progress heat-plus-management-progress",
      div(
        style = "width: 0;",
        class = "progress-bar progress-bar-striped progress-bar-animated"
      )
    ),
    div(
      class = "heat-plus-management-progress-text mb-3",
      tags$small()
    ),
    div(
      class = "heat-plus-management-warnings"
    ),
    div(
      class = "d-flex align-items-center",
      hr(class = "flex-grow-1"),
      div(class = "px-2 text-uppercase", i18n("manager.text.or")), #or
      hr(class = "flex-grow-1")
    ),
    #
    # Here we have the option to use i18n() or translate() because we added
    # JavaScript to double-check for elements in need of translation
    #
    # h5("Open existing database"),
    h5(i18n("manager.labels.open")), # Open existing database
    div(
      class = "list-group heat-plus-record-list",
      if (length(items) == 0) {
        div(
          class = "list-group-item heat-plus-record-no-data",
          "No data uploaded"
        )  
      } else {
        items
      }
    ),
    footer = buttonInput(
      id = ns("done"),
      label = translate(c(lang, "manager", "text", "done"))#"Done"
    ) %>% 
      background("green")
  )
  
  m <- tagAppendAttributes(m, class = "heat-plus-management-modal")
  
  m
}

dataManagementServer <- function(input, output, session, auth, 
                                 open_data_management, language = NULL) {
  r_user <- reactive({
    req(is.function(auth$user), is.list(auth$user()))
    
    auth$user()
  })
  
  r_user_id <- reactive({
    r_user()$id
  })
  
  State <- reactiveValues(
    modal = NULL,
    files = NULL,
    active = NULL,
    
    refresh_records = 0,
    records = NULL,
    delete_active = 0,
    
    main = NULL,
    measures = NULL,
    setting_yr_src = NULL,
    dimensions = NULL,
    subregion_extrema = NULL,
    strata = NULL,
    country_info = NULL
  )
  
  # ├ utils ----
  set_active <- function(name) {
    State$active <- name
  }
  
  delete_active <- function() {
    State$delete_active <- State$delete_active + 1
  }
  
  is_active <- function(name) {
    isTRUE(State$active == name)
  }
  
  load_data <- function(data) {
    keys <- names(data)
    
    for (i in seq_along(data)) {
      State[[keys[[i]]]] <- data[[i]]
    }
  }
  
  refresh_records <- function() {
    State$records <- local_dir_list_records(r_user_id())
  }

  # ├ reactives ----
  r_records <- reactive(State$records)  
  r_active <- reactive(State$active)
  r_delete_active <- reactive(State$delete_active)
  
  r_select_record <- reactive(input$select_record)
  r_delete_record <- reactive(input$delete_record)  
  r_rename_record <- reactive(input$rename_record)
  
  r_begin <- eventReactive(input$upload_database, {
    req(r_user_id(), input$new_database)
    input$upload_database
  })
  r_upload <- reactive(input$new_database)
  r_save <- reactive(input$save_database_as)
  
  # ├ enable upload button ----
  observeEvent(input$new_database, {
    print("# observeEvent(input$new_database) ----")
    print(sprintf("  Date/Time: %s", Sys.time()))
    session$sendCustomMessage("heatplus:enable-upload", list())
  })
  
  # ├ data upload ----
  m_upload <- callModule(
    dataUploadServer, "upload",
    r_user_id = r_user_id,
    r_begin = r_begin,
    r_upload = r_upload,
    r_save = r_save,
    language = language
  )
  
  # │├ new record ----
  observeEvent(m_upload$record(), {
    req(
      m_upload$record()
    )
    
    set_active(m_upload$record())
    
    record <- dataManagementRecord(m_upload$record(), activate = TRUE)
    
    session$sendCustomMessage("heatplus:prepend-record", list(
      record = HTML(as.character(record))
    ))
    
    refresh_records()
  })
  
  # │├ new data ----
  observeEvent(m_upload$data(), {
    load_data(m_upload$data())
  })
  
  # │├ on error ----
  observeEvent(m_upload$error(), {
    req(m_upload$error())
    
    alerts <- HTML(paste0(
      vapply(m_upload$error(), function(msg) {
        alert(
          h6(i18n("manager.warnings.fileerror")), #Error in file
          hr(class = "mt-0"), 
          HTML(msg)
        ) %>% 
          background("red") %>% 
          as.character()
      }, character(1)),
      collapse = "\n"
    ))
    
    session$sendCustomMessage("heatplus:management-message", list(
      message = alerts
    ))
  })
  
  # │├ on success ----
  observeEvent(m_upload$success(), {
    req(m_upload$success())
    
    alerts <- alert(
      h6(i18n("manager.uploads.success")), #"Upload successful"
      hr(class = "mt-0"),
      HTML(m_upload$success())
    ) %>% 
      background("green")
    
    session$sendCustomMessage("heatplus:management-message", list(
      message = HTML(as.character(alerts))
    ))
  })
  
  # refresh current records ----
  observeEvent(r_user_id(), {
    req(r_user_id())
    refresh_records()
  })
  
  # ├ data management modal ----
  r_modal <- reactive({
    dataManagementModal(
      ns = session$ns, 
      records = r_records(),
      active = r_active(),
      language = language()
    )
  })
    
  # │├ open modal ----
  observeEvent(input$manage, {
    showModal(r_modal())
  })
  
  observeEvent(open_data_management(), {
    showModal(r_modal())
  })
  
  # │├ close modal ----
  observeEvent(input$done, {
    closeModal()
  })
  
  # ├ logout user ----
  observeEvent(input$logout, {
    updateQueryString("?", mode = "push")
    session$reload()
  })
  
  # ├ select a record ----
  observeEvent(c(r_select_record()), {

    req(
      r_user_id(),
      r_select_record(),
      local_dir_has_record(r_user_id(), r_select_record())
    )

    record_data <- local_dir_load_record(r_user_id(), r_select_record())
    
    if (is.null(record_data)) {
      return()
    }
    
    set_active(r_select_record())
    
    load_data(record_data)
  })
  
  # ├ rename a record ----
  observeEvent(r_rename_record(), {
    req(r_user_id())
    
    current <- path_file(r_rename_record()$current)
    new <- path_file(r_rename_record()$new)
    
    if (!local_dir_has_record(r_user_id(), current)) {
      message("Could not rename record")
      return()
    }
    
    if (local_dir_has_record(r_user_id(), new)) {
      message("Already record of same name")
      return()
    }
    
    local_dir_rename_record(r_user_id(), current, new)
    
    refresh_records()
    
    session$sendCustomMessage("heatplus:rename-record", list(
      previous = current,
      new = new
    ))
  })
  
  # ├ delete a record ----
  observeEvent(r_delete_record(), {
    req(
      r_user_id(),
      r_delete_record(),
      local_dir_has_record(r_user_id(), r_delete_record())
    )
    
    local_dir_delete_record(r_user_id(), r_delete_record())
    
    if (is_active(r_delete_record())) {
      set_active(NULL)
      delete_active()
    }
    
    refresh_records()
      
    session$sendCustomMessage("heatplus:remove-record", list(
      name = r_delete_record()
    ))
  })
  
  # ├ download template file ----
  output$template <- downloadHandler("heat-plus-template.xlsx", function(f) {
    file_copy(
      path_package("heatplus", "downloads", "heat-plus-template.xlsx"),
      f
    )
  })
  
  # ├ download user manual file ----
  output$user_manual <- downloadHandler("heat-plus-user-manul.pdf", function(f) {
    file_copy(
      path_package("heatplus", "downloads", "user-manual.pdf"),
      f
    )  
  })

  list(
    main = reactive(State$main),
    measures = reactive(State$measures),
    country_info = reactive(State$country_info),
    strata = reactive(State$strata),
    setting_yr_src = reactive(State$setting_yr_src),
    delete_active = r_delete_active
  )
}

dataUploadServer <- function(input, output, session, 
                             r_user_id, r_begin, r_upload, r_save,
                             language) {
  httr::set_config(httr::config(http_version = 0))
  
  ns <- session$ns
  
  State <- reactiveValues(
    data = NULL,
    record = NULL,
    
    success = NULL,
    error = NULL
  )
  
  r_data <- reactive(State$data)
  r_record <- reactive(State$record)
  r_success <- reactive(State$success)
  r_error <- reactive(State$error)
  
  msg_error <- function(msg) {
    State$error <- msg
  }
  
  msg_success <- function(msg) {
    State$success <- msg
  }
  
  set_data <- function(name, data) {
    State$data <- data
    local_dir_populate_record(r_user_id(), name, data)
  }
  
  set_record <- function(name) {
    State$record <- name
  }
  
  r_upload_path <- reactive({
    req(r_upload())
    r_upload()$datapath
  })
  
  r_upload_size <- reactive({
    req(r_upload())
    r_upload()$size
  })
  
  r_upload_name <- reactive({
    req(r_upload())
    r_upload()$name
  })
  
  observeEvent(r_begin(), {
    req(
      r_user_id(), 
      r_upload(),
      r_upload_path(),
      r_upload_size(),
      r_upload_name()
    )
    
    lang <- language()
    
    msg_success(NULL)
    msg_error(NULL)
    
    if (is.null(r_save())) {
      record_name <- path_ext_remove(path_file(r_upload_name()))
    } else {
      record_name <- r_save()
    }
    
    if (local_dir_has_record(r_user_id(), record_name)) {
      msg_error(translate(c(lang, "manager", "warnings", "filename")))
      # paste(
      #   "Filename already exists",
      #   "<br/>",
      #   "Please delete the file below first or choose another filename"
      # )
      return()
    }
  
    upload_data <- read_data(r_upload_path())

    if (isTRUE(is.na(upload_data))) {
      msg_error(translate(c(lang, "manager", "warnings", "extension"))) #"Invalid file extension"
      return()
    }
    
    check_names <- heatdata::test_has_required_variables(upload_data)

    if (!check_names$pass) {
      msg_error(
        translate(
          c(
            lang,
            check_names$namespace,
            check_names$subject,
            check_names$key
            )
          )
        )
      return()
    }
    
    data_id <- heatmeasures::add_strata_id(upload_data)
    
    data_heat <- data_id %>% 
      heatdata::HEAT_data_fixes("heat_data") %>% 
      heatdata::HEAT_force_variable_types("heat_data") %>% 
      heatdata::HEAT_drop_defective_strata()
    
    if (NROW(data_heat) == 0) {
      msg_error(translate(c(lang, "manager", "warnings", "strata")))
      return()
    }
    
    data_vars <- data_heat %>% 
      heatdata::HEAT_rename_variables("heat_data") %>% 
      heatdata::HEAT_data_add_variables("heat_data")
    
    data_tests <- heatdata::HEAT_table_validation_tests(
      data_vars,
      grep("^test_", names(heatdata::HEAT_variable_descriptions), value = TRUE)
    )
    data_tests$passed_test[is.na(data_tests$passed_test)] <- FALSE
    
    if (!all(data_tests$passed_test)) {
      failed_tests <- dplyr::filter(data_tests, !passed_test)
      
      failed_tests_warning_msg <- sapply(1:nrow(failed_tests),function(i){
        translate(c(lang, failed_tests$namespace[i], failed_tests$subject[i], failed_tests$key[i]))
      })

      msg_error(failed_tests_warning_msg)
      return()
    }
    
    total_steps <- 5
    i <- 0
    
    msg_progress <- function(text) {
      i <<- i + 1
      session$sendCustomMessage("heatplus:management-upload-progress", list(
        width = paste0(floor(i / total_steps * 100), "%"),
        text = as.character(text)
      ))
    }
    
    msg_progress(translate(c(lang, "manager", "uploads", "measures")))
    # Creating summary measures
    data_measures <- heatmeasures::HEAT_measures_full_process(data_vars)
    
    msg_progress(translate(c(lang, "manager", "uploads", "strata"))) 
    # Creating strata
    data_strata <- heatdata::HEAT_create_strata_table(data_vars)
    
 
    data_setting_years <- heatdata::HEAT_create_setyrsrc_table(data_vars)
    
    msg_progress(translate(c(lang, "manager", "uploads", "dimensions")))
    # Creating dimensions
    data_dimensions <- heatdata::HEAT_create_dimension_table(data_vars)
    
    data_subregion_extrema <- heatdata::HEAT_create_subregionminmax_table(data_vars)
    
    # append colors to data_heat
    data_heat <- dplyr::left_join(
      data_vars, data_dimensions, 
      by = c("dimension", "subgroup", "subgroup_order")
    )

    data_country_info <- HEATPlus_create_country_info(data_strata)
    
    msg_progress(translate(c(lang, "manager", "uploads", "saving")))
    # Saving results
    
    # create new record folder under user folder
    local_dir_create_record(r_user_id(), record_name)

    # save data frames as rds files in record
    set_data(record_name, list(
      main = data_heat, 
      measures = data_measures, 
      setting_yr_src = data_setting_years, 
      dimensions = data_dimensions,
      subregion_extrema = data_subregion_extrema, 
      strata = data_strata, 
      country_info = data_country_info
    ))
    
    set_record(record_name)
    
    Sys.sleep(1)

    msg_progress(translate(c(lang, "manager", "uploads", "complete")))
    # Upload complete

    msg_success(translate(c(lang, "manager", "uploads", "uploaded")))
    # The database was uploaded
  })

  list(
    data = r_data,
    record = r_record,
    error = r_error,
    success = r_success
  )
}
