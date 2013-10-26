(function(){
Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

if (!Object.keys){
  Object.keys = function(obj) {
      var key;
      var keys=[];
      for (key in obj) {
          if (obj.hasOwnProperty(key)) keys.push(key);
      }
      return keys;
  };
}
  
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
    
    
    cols = [];
    if (Object.size(htable.data) === htable.types.length && 
        htable.types instanceof Array){
      // One type for each column, data.frame-like object.
      for (var i = 0; i < Object.size(htable.data); i++){
        cols.push({
          type: htable.types[i]
        });
      }  
    } else if (typeof htable.types === 'string'){
      for (var i = 0; i < htable.data.length; i++){
        // one type globally, like a matrix. Use the same type everywhere.
        cols.push({
          type: htable.types,
          format: '0.00'
        });
      }  
    }
    
    
    //massage into handsontable-friendly format
    if (!(htable.data instanceof Array)){
      // object, needs to be parsed by row
      var buffer = Array();
      var row;
      var keys = Object.keys(htable.data);
      for (var i = 0; i < htable.data[Object.keys(htable.data)[0]].length; i++){
        row = Array();
        for (var col = 0; col < Object.size(htable.data); col++){
          var key = keys[col];
          row.push(htable.data[key][i]);
        }
        buffer.push(row);
      }
      htable.data = buffer;
    }
    
    var settings = {
      readOnly: false,
      data: htable.data,
      colHeaders: htable.colnames,
      columnSorting: false,
      columns: cols
    };
    
    var headersMode = $(el).data('htable-headers');
    if (headersMode == 'enabled'){      
      settings.colHeaders = true;
    } else if (headersMode == 'disabled'){ 
      settings.colHeaders = false;
    } else if (headersMode == 'provided' && htable.headers){
      settings.colHeaders = htable.headers;  
    }
    
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
 * Track the changes made to an htable. Due to the arrangement of callbacks, 
 * we're not able to pass the changes into the function, so we need to store it
 * externally. The changes will be stored here, indexed by the ID.
 */
var changeRegistry = {};

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
  getType: function(){
    return "htable";
  },
  getValue: function(el) {
    if (changeRegistry[el.id]){
      var changes = changeRegistry[el.id];
      delete changeRegistry[el.id];
      return changes;
    }
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
        
        if (changes[el.id]){
          console.log("WARNING: Overwriting a change before it was picked up by the server.");
        }
        changeRegistry[el.id] = changes;
        
        callback(false);
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