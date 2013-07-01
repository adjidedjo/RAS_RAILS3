$(document).ready(function(){
    // Add a tabletool to export to pdf, excel and csv
    $('#detail_report').dataTable({
				"bScrollCollapse": true,
        "bPaginate": false,
				"bAutoWidth": false,
        "bInfo": false,  
        "bFilter": false,
        sDom: '<"H"Tfrl>t<"F"ip>',
        oTableTools: {
            sSwfPath: "/copy_csv_xls.swf",
            aButtons: [
            {
                "sExtends": "xls",
								"sFileName": "*.xls",
                "sButtonText": "Export to Excel"
            }
            ]
        }
    });
});
