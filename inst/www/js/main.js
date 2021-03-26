$(function() {
  
    $("#heat-header-title").on("click", function () {
    $("#heatplus-nav>li>button:first").click();
  });
    //$("#heat-header-title").click(function () {
    //$("#heatplus-pane_main").removeClass("active");
    //$("#heatplus-pane_other").removeClass("active");
    //$("#heatplus-pane_home").addClass("active");
  //});
  // Initialize custom file input
  $(document).on("shown.bs.modal", ".heat-plus-management-modal", function(event) {
    bsCustomFileInput.init();
    $("[data-toggle='tooltip']").tooltip();
  });
  
  $(document).on("click", ".heat-plus-record__input:not(.editing)", function(e) {
    $(e.currentTarget).blur();
  });
  
  $(document).on("click", ".heat-plus-record__input.editing", function(e) {
    e.stopPropagation();
  });
  
  $(document).on("click", ".heat-plus-record__buttons", function(e) {
    e.stopPropagation();
  });
  
  // User login ----
  Shiny.addCustomMessageHandler("heatplus:user-login", function(msg) {
    var label = document.querySelector(".heat-plus-management-dropdown__label");
    
    label.innerText = msg.username;
  });
  
  // Edit record name ----
  $(document).on("click", ".heat-plus-record__buttons button[value='edit']", function(event) {
    var $button = $(event.currentTarget);
    var $record = $button.closest(".heat-plus-record");
    var $name = $(".heat-plus-record__input", $record);
    var $warning = $(".heat-plus-record__warning", $record);

    $record.addClass("in-progress");

    $name.addClass("editing");
    $name.focus();
    $name[0].select();
    
    var prev = $name.val();
    
    $name.on("blur.heatplus keydown.heatplus", function(e) {
      if (e.type === "blur" ||
          (e.type === "keydown" && (e.which == 13 || e.keyCode == 13 || e.code == "Enter"))) {
        var value = $name.val();
        
        if (!value || /^\s+$/.test(value)) {
          $name.val(prev);
        } else {
          if (!/^[-a-zA-Z0-9_. ]+$/.test(value)) {
            $name.addClass("invalid");
            $warning.html("Please use only letters, numbers, _, ., -, or spaces");
            return;
          } else {
            $name.removeClass("invalid");
            $warning.html("");
          }
          
          Shiny.setInputValue("dm-rename_record", {
            "current": $record.attr("data-record"),
            "new": $name.val()
          });
        }
        
        $name.off(".heatplus");
        $name.blur();
        $name.removeClass("editing");
      }
    });
  });

  Shiny.addCustomMessageHandler("heatplus:rename-record", function(event) {
    var previousName = event["previous"];
    var newName = event["new"];
    
    if (!previousName) {
      throw "cannot complete rename";
    }
    
    var $modal = $(document.querySelector(".heat-plus-management-modal"));
    var $record = $(".heat-plus-record[data-record='" + previousName + "']", $modal);
    var $input = $(".heat-plus-record__input", $record);
    
    if (newName) {
      $record.attr("data-record", newName);
      $input.val(newName);
    } else {
      $input.val(previousName);
    }
    
    $record.removeClass("in-progress");
  });
  
  // Select record ----
  $(document).on("click", ".heat-plus-record:not(.active)", function(e) {
    var $record = $(e.currentTarget);
    
    $record.siblings(".active").removeClass("active");
    $record.addClass("active in-progress");
    
    $(".heat-plus-management-modal .alert").alert("close");
    
    Shiny.setInputValue("dm-select_record", $record.attr("data-record"));
  });
  
  Shiny.addCustomMessageHandler("heatplus:selected-record", function(msg) {

    var record = document.querySelector(".heat-plus-record-list .heat-plus-record.in-progress");
    console.log(msg)
    if (record) {
      $("#heatplus-explore_disag_line-setting").one("select.select.yonder", function(e) {
        document.querySelector(".heat-plus-management-modal .modal-body")
          .insertAdjacentHTML(
            "beforeend",
            "<div class='alert alert-green alert-data-opened my-3 fade show'>" +
              msg['msg'],
              '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>' + 
              "</div>"
          );
          
        record.classList.remove("in-progress");
        record.classList.add("active");
      });
    }
  });
  
  // Prepend new record
  Shiny.addCustomMessageHandler("heatplus:prepend-record", function(msg) {
    var recordList = document.querySelector(".heat-plus-record-list");
    var newRecord = msg.record;
    
    if (!newRecord) {
      throw "no record specified for prepending";
    }
    
    if (recordList) {
      $(recordList.querySelector(".heat-plus-record-no-data")).remove();
      $(recordList.querySelectorAll(".active")).removeClass("active");
      recordList.insertAdjacentHTML("afterbegin", newRecord);
    }
    
    var label = document.querySelector(".heat-plus-management-upload .custom-file-label");
    
    if (label) {
      label.innerHTML = "Choose file";
    }
    
    var saveAs = document.querySelector(".heat-plus-management-save-as input");
    
    if (saveAs) {
      saveAs.value = "";
    }
  });
  
  // Remove record
  $(document).on("click", ".heat-plus-record__buttons button[value='delete']", function(e) {
    var $record = $(e.currentTarget).closest(".heat-plus-record");
    
    $record.addClass("in-progress");
    
    Shiny.setInputValue("dm-delete_record", $record.attr("data-record"));
  });
  
  Shiny.addCustomMessageHandler("heatplus:remove-record", function(msg) {
    var recordList = document.querySelector(".heat-plus-record-list");
    var name = msg.name;
    
    if (!name) {
      throw "no record name specified for removal";
    }
    
    if (recordList) {
      $(recordList.querySelector(".heat-plus-record[data-record='" + name + "']")).remove();
    }
    
    if (recordList.children.length === 0) {
      recordList.insertAdjacentHTML(
        "beforeend",
        "<div class='list-group-item heat-plus-record-no-data'>No data uploaded</div>"
      );
    }
  });
  
  // Upload record
  $(document).on("change", ".heat-plus-management-upload", function(event) {
    var label = document.querySelector(".heat-plus-management-upload .custom-file-label");
    var saveAs = document.querySelector(".heat-plus-management-save-as input");
    // var begin = document.querySelector(".heat-plus-management-begin");
    
    if (saveAs) {
      saveAs.value = label.innerText.replace(/[.][^.]*$/, "");
    }
    
    // if (begin) {
    //   begin.removeAttribute("disabled");
    // }
  });
  
  Shiny.addCustomMessageHandler("heatplus:enable-upload", function(msg) {

    var begin = document.querySelector(".heat-plus-management-begin");
    
    if (begin) {
      $(".heat-plus-management-begin i").remove();
      begin.removeAttribute("disabled");
    }
  });
  
  $(document).on("change", ".heat-plus-management-upload", function(e) {
      
      const txt = $(".heat-plus-management-begin").text();
      $(".heat-plus-management-begin").html(txt + ' ' + '<i class="fas fa-spinner fa-pulse progress-icon"></i>')
  });
  
  
  $(document).on("click", ".heat-plus-management-begin", function(event) {
    var saveAs = document.querySelector(".heat-plus-management-save-as input");
    
    if (saveAs.value === "") {
      return;
    }
    
    var warningsList = document.querySelector(".heat-plus-management-warnings");
    
    if (warningsList) {
      warningsList.innerHTML = "";
    }
    
    var progress = document.querySelector(".heat-plus-management-progress");
    
    if (progress) {
      progress.children[0].style.width = 0;
    }
    
    var message = document.querySelector(".heat-plus-management-progress-text small");
    
    if (message) {

      const lang = $('#lang').val();
      let txt = 'start txt';
      
      switch(lang){
        case "en":
          txt = "Upload starting"
          break;
        case "fr":
          txt = "Téléchargement"
           break;
        case "pt":
          txt = "Iniciando o carregamento"
           break;
        case "es":
          txt = "Se inició el cargado"
      }
      
      message.innerHTML = txt; //"<span data-i18n="manager.uploads.start"></span>""; //"Upload starting";
    }
    
    var begin = document.querySelector(".heat-plus-management-begin");
    
    if (begin) {
      begin.setAttribute("disabled", "");
    }
  });
  
  // message ----
  Shiny.addCustomMessageHandler("heatplus:management-message", function(msg) {
    var messages = document.querySelector(".heat-plus-management-warnings");
    
    if (messages) {
      messages.insertAdjacentHTML("afterbegin", msg.message);
    }
  });
  
  Shiny.addCustomMessageHandler("heatplus:management-upload-progress", function(msg) {
    var progress = document.querySelector(".heat-plus-management-progress");
    var message = document.querySelector(".heat-plus-management-progress-text small");
    
    if (progress) {
      progress.children[0].style.width = msg.width;
      // $(progress.children[0]).animate({ width: msg.width }, 500, "linear");
    }
    
    if (message) {
      var $message = $(message);
      
      if (msg.text === "") {
        $message.fadeOut(function() { $message.text("") });
      } else {
        $message.fadeOut(function() { $message.text(msg.text) }).fadeIn();
      }
    }
  });
});
