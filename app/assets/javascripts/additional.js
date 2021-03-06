var formChanges;
// --------- avoid unsaved modal --------

var confirmLeavePage = false;
window.onbeforeunload = askConfirm;
function askConfirm(){
  if (confirmLeavePage != false){
      return confirmLeavePage;
  }
}

// --------- declarations ---------

var autoSaveFun = function autosave() {
  $('form.autosave').each(function(index) {
    if(formChanges[index] && !$(this).hasClass('no-autosave')){
      $(this).ajaxSubmit(function(data) {
        confirmLeavePage = false;
        formChanges[index] = false;
        if(data && data.new_url) this.attr('action', data.new_url).attr('method', 'patch');
        window.SnackBar({message: "<i class='far fa-save'></i>", position: "tr", dismissible: false, timeout: 2000});
      }.bind($(this)))
    }
  });
}

var setModalPositioning = function modalPosition(){
  let num_open = $(".modal.show").length;
  $(".modal-backdrop.show").css('opacity', 0.5/num_open);
  $.each($(".modal.show").toArray().sort((a, b) => a.getAttribute('data-depth') - b.getAttribute('data-depth')), function(i, v) {
    $(v).css({width: (100/num_open)+'%', marginLeft: ((100/num_open)*i)+'%'});
  });
}

function timeoutReload(location_hash, time=300){
  console.log("timeout reloading running");
  if(location_hash){
    location.hash = location_hash;
  } else {
    location.hash = '';
  }
  setTimeout(function(){
    // if(location_hash) 
      window.location.reload(true);
    // else window.location.href = window.location.href;
  }, time)
}

function saveForm(form, input_for_id=null, callback=null) {
  var id;
  console.log("form", form, input_for_id);
  confirmLeavePage = false;
  form.ajaxSubmit(function(data) {
    if(data && data.new_url) {form.attr('action', data.new_url).attr('method', 'patch')};
    window.SnackBar({message: "<i class='far fa-save'></i>", position: "tr", dismissible: false, timeout: 2000});
    console.log("record id", data.id);
    if(input_for_id) input_for_id.val(data.id).change();
    if(callback != null) callback();
  })
}

function saveAllForms() {
  $('form.autosave').each(function() {
    saveForm($(this));
  });
}

function saveBeforeModalForms() {
  $('form.autosave.save-before-modals').each(function() {
      saveForm($(this));
    })
}

function createModalListeners(selector) {
  $(selector).on('shown.bs.modal', setModalPositioning);
  $(selector).each(function() {
    if($(this).data('depth') < 1) $(this).on('shown.bs.modal', function() {
      saveBeforeModalForms();
    });
  });
  $(selector).on('hidden.bs.modal', setModalPositioning);
}

function reenableButton(btn){
  console.log("functin urnning", btn);
  btn.prop("disabled", false).find("i").remove();
}

// --------- rdy ---------

$(function() {
  setTimeout(function() {

    $("button.disable-on-click").on("click", function() {
      $(this).prop("disabled", true).prepend("<i class='fas fa-spinner fa-pulse me-2'></i>");
    });

    $('form.autosave').each(function(index) {
      if(!$(this).hasClass('block-submit')){
        let form = $(this);
        $(this).ajaxForm({
          success: function(data, x, y, form) {
            confirmLeavePage = false;
            formChanges[index] = false;
            if(data && data.new_url) form.attr('action', data.new_url).attr('method', 'patch');
            window.SnackBar({message: "<i class='far fa-save'></i>", position: "tr", dismissible: false, timeout: 2000});
            if(form.hasClass("base-form")) $('.adjacent-base-form').each(function() {
              saveForm($(this));
            })
          }
        });
      }
    });
    $('.modal').modal({backdrop: 'static', keyboard: false})  

    formChanges = $('form.autosave').map(function() { return false; });

    $('form.autosave').each(function(index) {
      $(this).find('input, select, textarea').change(function() {
        formChanges[index] = true;
      });
    });
      
    $("textarea").each(function () {
      $(this).css("height", Math.max(38, this.scrollHeight) + "px").css('overflow-y','hidden');
    }).on("input", function () {
      var confirmLeavePage = "Are you sure you want to exit this page, you have unsaved changes...";
      this.style.height = "auto";
      this.style.height = (Math.max(38, this.scrollHeight)) + "px";
    });

    $("textarea.one-line").keydown(function(e){
      if (e.keyCode == 13 && !e.shiftKey) e.preventDefault();
    });

    setInterval(autoSaveFun,10000);

  }, 250);
 
  $('[data-bs-toggle="popover"]').popover();

  createModalListeners(".modal");
  if($(location.hash).hasClass("modal")) setTimeout(function() {
    if($(location.hash).find('span.second-modal').length > 0){
      $($(location.hash).find('span.second-modal').data("other-render")).modal('show');
    }
    $(location.hash).modal('show');
  }, 100);

});

// -------- Tom Select presets --------

var ts_sort_text_asc_max_null = {
  sortField: {
    field: "text",
    direction: "asc"
  },
  maxItems: null,
  maxOptions: null,
  closeAfterSelect: true,
  hidePlaceholder: true,
  onDropdownClose: function(d) {
    $("*:focus").blur();
  },
  hideSelected: false,
};

var ts_max_null = {
  maxItems: null,
  maxOptions: null,
  closeAfterSelect: true,
  hidePlaceholder: true,
  onDropdownClose: function(d) {
    $("*:focus").blur();
  },
  hideSelected: false,
};

var ts_max_1 = {
  maxItems: 1,
  maxOptions: null,
  hidePlaceholder: true,
};

var ts_sort_text_asc_max_1 = {
  sortField: {
    field: "text",
    direction: "asc"
  },
  maxItems: 1,
  maxOptions: null,
  hidePlaceholder: true,
};

var ts_sort_text_asc_max_1_create = {
  sortField: {
    field: "text",
     direction: "asc"
  },
  maxItems: 1,
  create: true,
  maxOptions: null,
  hidePlaceholder: true,
};


// ----   AG Grid functions -------
function autoSizeAll(gridOpt, skipHeader) {
  const allColumnIds = [];
  gridOpt.columnApi.getAllColumns().forEach((column) => {
    allColumnIds.push(column.getId());
  });

  gridOpt.columnApi.autoSizeColumns(allColumnIds, skipHeader);
}

function onlyUnique(value, index, self) {
  return self.indexOf(value) == index;
}