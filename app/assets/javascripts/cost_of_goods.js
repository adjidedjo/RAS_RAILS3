$(document).ready(function(){
  $('#diskon1').dataTable({
    "scrollX": true,
    "bFilter": false,
    "bLengthChange": false,
    "bInfo": false
  });

  $('#diskon2').dataTable({
    "scrollX": true,
    "bFilter": false,
    "bLengthChange": false,
    "bInfo": false
  });

  $('#diskon3').dataTable({
    "scrollX": true,
    "bFilter": false,
    "bLengthChange": false,
    "bInfo": false
  });

  $('#cost_of_good_produk').multiselect({
    maxHeight: 200,
    numberDisplayed: 1,
    enableFiltering: false,
    enableCaseInsensitiveFiltering: true
  });

  $('#cost_of_good_merk').multiselect({
    maxHeight: 200,
    numberDisplayed: 1,
    enableFiltering: false,
    enableCaseInsensitiveFiltering: true
  });

  $('#cost_of_good_artikel').multiselect({
    maxHeight: 200,
    numberDisplayed: 1,
    enableFiltering: true,
    enableCaseInsensitiveFiltering: true
  });

  $('#cost_of_good_cabang_id').multiselect({
    maxHeight: 200,
    numberDisplayed: 1,
    enableFiltering: false,
    enableCaseInsensitiveFiltering: true
  });

  $('#cost_of_good_customer').multiselect({
    maxHeight: 200,
    numberDisplayed: 1,
    enableFiltering: true,
    enableCaseInsensitiveFiltering: true
  });
});
