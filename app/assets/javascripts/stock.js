/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

$(document).ready(function(){
    $('#brand_select').multiselect({
        selectedList: 4
    });

    $('#brand_product_select').multiselect({
        selectedList: 4
    });

    $('#artikel_select').multiselect({
        selectedList: 4
    });

    $('#date').datepicker({
        dateFormat: 'yy-mm-dd'
    }).attr('readonly','readonly');

    $('#stock').dataTable({
        bJQueryUI: true,
        sPaginationType: "full_numbers",
        iDisplayLength: 10,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
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
            sSelector: "#ukuran",
            type: "checkbox"
        }
        ]
    });
});
