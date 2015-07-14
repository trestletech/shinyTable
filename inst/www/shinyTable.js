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
    
    var tbl = $(el).handsontable('getInstance');
    
    if (htable.hasOwnProperty('cycle')){
      // Null output, just syncing state with the client.
      var rejected = flushChanges(el.id, htable.cycle);
      for (var i = 0; i < rejected.length; i++){
        console.log("Reverting rejected change");
        var thisChange = rejected[i].change[0];
        // safe to assume tbl exists.
        tbl.setDataAtCell(thisChange[0], thisChange[1], 
            thisChange[2], 'rejected-change');
      }    
      if (Object.size(htable) == 1){
        // has no other properties.
        return;
      }
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
      readOnly: processBooleanString($(el).data('read-only')) || false,
      data: htable.data,
      colHeaders: htable.colnames,
      columnSorting: false,
      columns: cols,
      minRows: $(el).data('min-rows'),
      minCols: $(el).data('min-cols')
    };
    
    if ($(el).data('width')){
      settings.width = $(el).data('width');  
    }
    
    if ($(el).data('height')){
      settings.height = $(el).data('height');  
    }
    
    var headersMode = $(el).data('htable-col-names');
    if (headersMode == 'enabled'){      
      settings.colHeaders = true;
    } else if (headersMode == 'disabled'){ 
      settings.colHeaders = false;
    } else if (headersMode == 'provided' && htable.headers){
      settings.colHeaders = htable.headers;
    }
    
    var rowMode = $(el).data('htable-row-names');
    if (rowMode == 'enabled'){
      settings.rowHeaders = true;
    } else if (rowMode == 'disabled'){ 
      settings.rowHeaders = false;
    } else if (rowMode == 'provided' && htable.rownames){
      settings.rowHeaders = htable.rownames;
    }
  
    tbl.updateSettings(settings)
    
    function clearSelection(){
      Shiny.onInputChange($(el).data('click-id'), {
        r1: NaN, c1: NaN, r2: NaN, c2: NaN,
        ".nonce": Math.random()
      });
    }
    
    if ($(el).data('click-id') && !$(el).data('click-handler')){
      tbl.addHook('afterDeselect', function(){
        clearSelection();
      });
      
      // Register a handler for click events
      $(el).data('click-handler', tbl.addHook('afterSelectionEnd',
        function(r, c, r2, c2){
          Shiny.onInputChange($(el).data('click-id'), {
            r1: r+1, c1: c+1, r2: r2+1, c2: c2+1,
            ".nonce": Math.random()
          });
        })
      );
      
      // Seed the input with NAs.
      clearSelection();
    }
  }
});
Shiny.outputBindings.register(shinyTableOutputBinding, 'shinyTable.tableBinding');

/**
 * For some reason we are getting string "FALSE" instead of Booleans, just 
 * detect these kinds of things here.
 **/
function processBooleanString(str){
  if (typeof str === 'boolean'){
    return str;
  }
  
  if (str.match(/^t/i)){
    return true;
  } else if (str.match(/^f/i)){
    return false;
  }
  throw new Error("Cannot process Boolean input string: " + str);
}

/**
 * Track the changes made to an htable. Due to the arrangement of callbacks, 
 * we're not able to pass the changes into the function, so we need to store it
 * externally. The changes will be stored here, indexed by the ID.
 */
 //TODO: Just use the changeCache, will support more than one event.
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


var changeCache = {}
function cacheChange(elementId, change){
  if (!changeCache[elementId]){
    changeCache[elementId] = [];
  }
  changeCache[elementId].push({
    cycle: getCycle(elementId, true),
    change: change
  });
}
/**
 * Flushes all the changes out of the cache that equal or predate the given
 * cycle number.
 */
function flushChanges(elementId, cycle){
  var changes = [];
  if (!changeCache[elementId]){
    return changes;
  }
  
  while (changeCache[elementId].length > 0 && 
      changeCache[elementId][0].cycle <= cycle){
    changes.push(changeCache[elementId].shift());
  }
  return changes;
}

/**
 * Keep a count of what cycle each element is on. Monotonically increasing
 * counter will be echoed by server so we can keep everythin in sync. We are
 * blending reactive model of Shiny with the Command pattern of handsontable,
 * afterall... God help us.
 */
var cycleCounts = {};
function getCycle(elementId, increment){
  if (typeof increment === 'undefined' || arguments.length < 2){
    increment = false;
  }
  if (cycleCounts[elementId]){
    if (increment){
      cycleCounts[elementId]++;
    }    
    return cycleCounts[elementId];
  }
  cycleCounts[elementId] = 1;
  return 1;
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
      return {changes: changes, cycle: getCycle(el.id)};
    }
    return {cycle: getCycle(el.id)};
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
        
        // If the change was rejected by the server, we do want to callback, 
        // so the server can properly update the input, but we don't need to
        // cache the change to support rollback.
        if (source !== 'rejected-change'){
          cacheChange(el.id, changes);
        }
        
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
  if (!$el || !data.changes || !data.cycle)
    return;

  // Flush any changes prior to the given cycle, as they've just been 
  // acknowledged.
  flushChanges(data.id, data.cycle);
  
  var tbl = $el.handsontable('getInstance');
  for( var i = 0; i < data.changes.length; i++){
    var change = data.changes[i];
    tbl.setDataAtCell(
      parseInt(change.row), 
      parseInt(change.col),
      change.new,
      "server-update");
  };
  applyStyles(data.id);
});

cellClasses = {};

Shiny.addCustomMessageHandler('htable-style', function(data) {
  var $el = $('#' + data.id);
  if (!$el || !data.style)
    return;

  if (!cellClasses[data.id]){
    cellClasses[data.id] = {};
  }

  var style = data.style;
  
  // Convert to arrays if they're not already
  style.row = [].concat(style.row);
  style.col = [].concat(style.col);
  
  for (var r = 0; r < style.row.length; r++){
    var row = style.row[r];
    if (!cellClasses[data.id][row]){
      cellClasses[data.id][row] = {};
    }
    
    for (var c = 0; c < style.col.length; c++){
      var col = style.col[c];
      
      cellClasses[data.id][row][col] = style.cssClass;
    }
  }
  
  applyStyles(data.id);
});

function applyStyles(id){
  if (!cellClasses[id]){
    return;
  }
  
  var $el = $('#' + id);
  var tbl = $el.handsontable('getInstance');
  
  var rows = Object.keys(cellClasses[id]);
  $.each(rows, function(i, row){
    var cols = Object.keys(cellClasses[id][row]);
    $.each(cols, function(j, col){
      var td = tbl.getCell(row, col);
      
      // Clear out existing styles
      while (td.classList.length > 0){
        td.classList.remove(td.classList[0]);
      }
      td.classList.add(cellClasses[id][row][col]);
    });
  });
}

})();