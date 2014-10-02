$(document).ready(function(){    
  $('#faktur').dataTable({
    iDisplayLength: 10,
    "bAutoWidth": false,
    "aoColumns" : [
    {
      sWidth: '30px'
    },
    {
      sWidth: '50px'
    },
    {
      sWidth: '50px'
    }
    ]  
  });
    
  $('.form-accounting-price-list select').tooltipster({ 
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });
    
  $('.form-accounting-price-list').validate({
    onclick: false,
    rules: {
      tipe: {
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
      tipe: {
        required: "Pilih Tipe"
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