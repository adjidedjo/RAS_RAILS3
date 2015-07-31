$(document).on("click", ".modal-history", function () {
     var barang = $(this).data('id');
     var ukuran = $(this).data('size');
     $(".modal-body #barang").val( barang );
     $(".modal-body #ukuran").val( ukuran );
     // $.ajax({
     //  datatype: 'script',
     //  url: "/regionals/modal_history",
     //  data: { brg: barang, size: ukuran }
     //})
     // As pointed out in comments,
     // it is superfluous to have to manually call the modal.
     // $('#addBookDialog').modal('show');
});

$(document).ready(function() {
  $('.from_period').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('.to_period').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');

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

  $('#list_cabang').dataTable({
    bPaginate: false,
    bAutoWidth: false,
    bInfo: false,
    bFilter: false
  });

  $('#show_history_product').dataTable({
    bPaginate: false,
    bAutoWidth: false,
    bInfo: false,
    bFilter: false,
    bSortable: false
  });

  $('#show_history_products1, #show_history_products2, #show_history_products3, \n\
#show_history_products5, #show_history_products4, \n\
#show_history_products6, #show_history_products7').dataTable({
    bPaginate: false,
    bAutoWidth: false,
    bInfo: false,
    bFilter: false,
    bSortable: false,
    bDestroy: true
  });

  $('#list_selected_goods').dataTable({
    "bPaginate": true,
    "bAutoWidth": false,
    "bInfo": false,
    iDisplayLength: 10
  });

  $('#list_goods').dataTable({
    "bPaginate": true,
    "bAutoWidth": false,
    iDisplayLength: 10
  });

  $('#list_produk').DataTable({
    iDisplayLength: 25
  });

  $('#future_price_list_upgrade_starting_at').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#future_price_list_discount_starting_at').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#future_price_list_cashback_starting_at').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#future_price_list_special_price_starting_at').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#future_price_list_harga_starting_at').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#price_list_program_starting_at').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');

  $('.test add').tooltipster({
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });

  $('.test').validate({
    onclick: false,
    rules: {
      "produk_ids[]": {required: true},
      "add": {required: true}
    },
    messages: {
      "checkbox": "CHECK ME"
    },
    highlight: function (element) {
      $(element).closest('.control-group').removeClass('success').addClass('error');
    },
    errorPlacement: function (error, element) {
//      $(element).tooltipster('update', $(error).text());
//      $(element).tooltipster('show');
    },
    success: function (element) {
//      $(element).tooltipster('hide');
    }
  });
});
