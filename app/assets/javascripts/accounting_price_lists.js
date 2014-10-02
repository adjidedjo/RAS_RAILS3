$(document).ready(function(){    
  $('#price_list').dataTable({
    iDisplayLength: 50,
    bRetrieve: true
  });
    
  $('.form-accounting-faktur select').tooltipster({ 
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });
    
  $('.form-accounting-faktur').validate({
    onclick: false,
    rules: {
      month: {
        required: true
      },
      branch: {
        required: true
      },
      brand: {
        required: true
      }
    },
    messages:{
      month:{
        required: "Pilih Bulan"
      },
      branch:{
        required: "Pilih Cabang"
      },
      brand:{
        required: "Pilih Brand"
      }
    },
    highlight: function (element) {
      $(element).closest('.control-group').removeClass('success').addClass('error');
    },
    errorPlacement: function (error, element) {
      $(element).tooltipster('update', $(error).text());
      $(element).tooltipster('show');
    },
    success: function (element) {
      $(element).tooltipster('hide');
    }
  });
});