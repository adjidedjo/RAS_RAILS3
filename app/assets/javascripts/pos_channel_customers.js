// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){
  $('#v_penjualan').dataTable({
    iDisplayLength: 10,
    bRetrieve: true,
    bAutoWidth: false,
    bDestroy: true
  });
});