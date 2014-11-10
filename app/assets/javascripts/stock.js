/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
$(document).ready(function(){
  
  $('.stock_index input[type="text"]').tooltipster({ 
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });
    
  $('.stock_index').validate({
    errorPlacement: function (error, element) {
                        
      var lastError = $(element).data('lastError'),
      newError = $(error).text();
            
      $(element).data('lastError', newError);
                            
      if(newError !== '' && newError !== lastError){
        $(element).tooltipster('content', newError);
        $(element).tooltipster('show');
      }
    },
    success: function (label, element) {
      $(element).tooltipster('hide');
      $(element).closest('.control-group').removeClass('error').addClass('success');
    },
    highlight: function (element) {
      $(element).closest('.control-group').removeClass('success').addClass('error');
    },
    rules: {
      date: {
        required: true
      }
    },
    messages:{
      date:{
        required: "Pilih Tanggal"
      }
    }
  });

  $('#date').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');

  $('#special_size').dataTable({
    bJQueryUI: true,
    sPaginationType: "full_numbers",
    iDisplayLength: 10,
    "bPaginate": false,
    sDom: '<"H"Tfrl>t<"F"ip>',
    bRetrieve: true,
    oTableTools: {
      sSwfPath: "/copy_csv_xls.swf",
      aButtons: [
      {
        "sExtends": "xls",
        "sButtonText": "Export to Excel"
      }
      ]
    }
  }).columnFilter({
    sPlaceHolder: "head:before",
    aoColumns: [
    {
      sSelector: "#cabang",
      type: "checkbox"
    },
    {
      sSelector: "#jenis",
      type: "checkbox"
    },
    {
      sSelector: "#brand",
      type: "checkbox"
    },
    {
      sSelector: "#artikel",
      type: "checkbox"
    },
    {
      sSelector: "#kain",
      type: "checkbox"
    },
    {
      sSelector: "#panjang",
      type: "checkbox"
    },
    {
      sSelector: "#lebar",
      type: "checkbox"
    },
    null,
    null
    ]
  });

  $('#stock_a').dataTable({
    iDisplayLength: 50,
    bRetrieve: true,
    bAutoWidth: false
  });
});
