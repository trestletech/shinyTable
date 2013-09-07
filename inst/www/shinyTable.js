(function(){
var shinyTableOutputBinding = new Shiny.OutputBinding();
$.extend(shinyTableOutputBinding, {
  find: function(scope) {
    return $(scope).find('.shiny-htable');
  },
  renderValue: function(el, htable) {
    if (!htable){
      return;
    }
    
    Shiny.onInputChange('.clientdata_output_' + el.id + '_init', true, false);
    
    //TODO: Is there some jQuery builtin for this?
    cols = [];
    for (var i = 0; i < htable.colnames.length; i++){
      cols.push({
        type: htable.types[i]
      });
    }
    
    var settings = {
      readOnly: false,
      data: htable.data,
      colHeaders: htable.colnames,
      columnSorting: false,
      columns: cols
    };
    
    var tbl = $(el).handsontable('getInstance');
    if (tbl){
      //already exists, just update
      tbl.updateSettings(settings)
    } else{
      //new table, create from scratch.
      $(el).handsontable(settings);
    }
  }
});
Shiny.outputBindings.register(shinyTableOutputBinding, 'shinyTable.tableBinding');



/**
 * Track the event callbacks bound to each htable so that we have the option
 * of unsubscribing them at a later point in time.
 */
var callbacks = {};

/**
 * Register a callback for one event on a particular htable.
 */
function registerCallback(table, element, event, fun){
  table.addHook(event, fun);
  if (!callbacks[element.id]){
    callbacks[element.id] = {};
  }
  callbacks[element.id][event] = fun;
}

/**
 * Deregister all callbacks on a particular htable.
 */
function deregisterCallbacks(table, element){
  $.each( callbacks[element.id], function(key, value){
    table.removeHook(key, value);
    delete callbacks[element.id][key];
  });
  delete callbacks[element.id];
}

var shinyTableInputBinding = new Shiny.InputBinding();
$.extend(shinyTableInputBinding, {
  find: function(scope) {
    return $(scope).find(".shiny-htable");
  },
  getValue: function(el) {
    // Won't ever want to send the entire state of this table from the client.
    // We'll just send changes, so return null.
    return null;
  },
  setValue: function(el, value) {
    //TODO
  },
  subscribe: function(el, callback) {
    var tbl = $(el).handsontable('getInstance');
    if (!tbl){
      // Create if it doesn't exist yet.
      $(el).handsontable();
      tbl = $(el).handsontable('getInstance');
    }
    
    registerCallback(tbl, el, "afterChange", function(changes, source){
      if (source !== "loadData" && source !== "server-update"){
        // Not a re-init from the server.
        Shiny.onInputChange('.clientdata_output_' + el.id + '_changes', changes);
        
        // Won't call callback, because we want to send changes ourselves rather
        // than have Shiny send the entire state.
      }
    })
  },
  unsubscribe: function(el) {
    var tbl = $(el).handsontable('getInstance');
    deregisterCallbacks(tbl, el);
  }
});

Shiny.inputBindings.register(shinyTableInputBinding);

Shiny.addCustomMessageHandler('htable-change', function(data) {
  var $el = $('#' + data.id);
  if (!$el || !data.changes)
    return;

  var tbl = $el.handsontable('getInstance');
  for( var i = 0; i < data.changes.length; i++){
    var change = data.changes[i];
    console.log("Change = ");
    console.log(change);
    tbl.setDataAtCell(
      parseInt(change.row), 
      parseInt(change.col),
      change.new,
      "server-update");
  };
});

})();