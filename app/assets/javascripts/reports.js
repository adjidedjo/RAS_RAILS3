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
		
		$('#compare_last').dataTable({
        iDisplayLength: 30,
        bRetrieve: true,
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

            var iTotalQty2012 = 0;
            var iTotalValue2012 = 0;

            var iTotalQty2013 = 0;
            var iTotalValue2013 = 0;

            var iTotalQtyGrowth = 0;
            var iTotalValueGrowth = 0;

            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalQty2012 += parseCurrency(aaData[i][1])*1;
                iTotalValue2012 += parseCurrency(aaData[i][2])*1;

                iTotalQty2013 += parseCurrency(aaData[i][3])*1;
                iTotalValue2013 += parseCurrency(aaData[i][4])*1;

                iTotalQtyGrowth += parseCurrency(aaData[i][5])*1;
                iTotalValueGrowth += parseCurrency(aaData[i][6])*1;
            }

            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = addCommas(parseInt(iTotalQty2012))
            nCells[1].innerHTML = addCommas(parseInt(iTotalValue2012))

            nCells[2].innerHTML = addCommas(parseInt(iTotalQty2013))
            nCells[3].innerHTML = addCommas(parseInt(iTotalValue2013))

            nCells[4].innerHTML = addCommas(parseInt(iTotalQtyGrowth))
            nCells[5].innerHTML = addCommas(parseInt(iTotalValueGrowth))

        }
    });

		function parseCurrency( num ) {
        return parseFloat( num.replace(/\./g, '') );
    }

    function addCommas(nStr)
    {
        nStr += '';
        x = nStr.split('.');
        x1 = x[0];
        x2 = x.length > 1 ? '.' + x[1] : '';
        var rgx = /(\d+)(\d{3})/;
        while (rgx.test(x1)) {
            x1 = x1.replace(rgx, '$1' + '.' + '$2');
        }
        return x1 + x2;
    }
});
