$(document).ready(function(){
  $('#check_price_list').dataTable({
    bAutoWidth: true,
    bProcessing: false,
    bFilter: false,
    sScrollX: "300px",
    bScrollCollapse: true,
    bPaginate: false,
    bInfo: false,
    bSort: false
  });

  $('#check_all').click(function(){
    if(this.checked) {
      // Iterate each checkbox
      $(':checkbox').each(function() {
        this.checked = true;
      });
    }
    else {
      $(':checkbox').each(function() {
        this.checked = false;
      });
    }
  });

  $('#price_list').dataTable({
    iDisplayLength: 10,
    bRetrieve: true,
    bAutoWidth: false
  });

  $('.form-accounting-price-list select').tooltipster({
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });

  $('.form-accounting-price-list').validate({

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
      tipe: {
        required: true
      },
      branch_price_list: {
        required: true
      },
      brand_price_list: {
        required: true
      },
      month_price_list: {
        required: true
      }
    },
    messages:{
      tipe: {
        required: "Pilih Tipe"
      },
      branch_price_list:{
        required: "Pilih Cabang"
      },
      brand_price_list:{
        required: "Pilih Brand"
      },
      month_price_list:{
        required: "Pilih Bulan"
      }
    }
  });
});