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
    }
  });
});