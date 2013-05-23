/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

$(document).ready(function(){

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

    $('#stock').dataTable({
        bJQueryUI: true,
        sPaginationType: "bootstrap",
        iDisplayLength: 50,
        bRetrieve: true
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
        }
        ]
    });
});
