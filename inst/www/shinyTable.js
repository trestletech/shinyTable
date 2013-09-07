var shinyTableOutputBinding = new Shiny.OutputBinding();
$.extend(shinyTableOutputBinding, {
  find: function(scope) {
    return $(scope).find('.shiny-htable-output');
  },
  renderValue: function(el, htable) {
    if (!htable){
      return;
    }
    
    //TODO: Is there some jQuery builtin for this?
    cols = [];
    for (var i = 0; i < htable.colnames.length; i++){
      cols.push({
        type: htable.types[i]
      });
    }
    
    var settings = {
      readOnly: true,
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