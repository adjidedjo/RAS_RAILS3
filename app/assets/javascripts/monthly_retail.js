$(document).ready(function(){
 // Datepicker
  $('#from').datepicker({
  	 dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#to').datepicker({
     dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');

	$('#monthly_retail').dataTable({
		bJQueryUI: false
	});

});
