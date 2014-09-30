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
    
  $('.form-accounting-faktur select').tooltipster({ 
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });
    
  $('.form-accounting-faktur').validate({
    onclick: false,
    rules: {
      branch: {
        required: true
      },
      brand: {
        required: true
      }
    },
    messages:{
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