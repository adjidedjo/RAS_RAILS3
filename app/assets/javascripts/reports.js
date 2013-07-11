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
		
		$('#customer_compare').dataTable({
        iDisplayLength: 10,
        bRetrieve: true,
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

            var iTotalQtyJanuary = 0;
            var iTotalValueJanuary = 0;

            var iTotalQtyFebruary = 0;
            var iTotalValueFebruary = 0;

            var iTotalQtyMarch = 0;
            var iTotalValueMarch = 0;

            var iTotalQtyApril = 0;
            var iTotalValueApril = 0;

            var iTotalQtyMay = 0;
            var iTotalValueMay = 0;

            var iTotalQtyJune = 0;
            var iTotalValueJune = 0;

            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalQtyJanuary += parseCurrency(aaData[i][2])*1;
                iTotalValueJanuary += parseCurrency(aaData[i][3])*1;

                iTotalQtyFebruary += parseCurrency(aaData[i][4])*1;
                iTotalValueFebruary += parseCurrency(aaData[i][5])*1;

                iTotalQtyMarch += parseCurrency(aaData[i][6])*1;
                iTotalValueMarch += parseCurrency(aaData[i][7])*1;

                iTotalQtyApril += parseCurrency(aaData[i][8])*1;
                iTotalValueApril += parseCurrency(aaData[i][9])*1;

                iTotalQtyMay += parseCurrency(aaData[i][10])*1;
                iTotalValueMay += parseCurrency(aaData[i][11])*1;

                iTotalQtyJune += parseCurrency(aaData[i][12])*1;
                iTotalValueJune += parseCurrency(aaData[i][13])*1;
            }

            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[1].innerHTML = addCommas(parseInt(iTotalQtyJanuary))
            nCells[2].innerHTML = addCommas(parseInt(iTotalValueJanuary))

            nCells[3].innerHTML = addCommas(parseInt(iTotalQtyFebruary))
            nCells[4].innerHTML = addCommas(parseInt(iTotalValueFebruary))

            nCells[5].innerHTML = addCommas(parseInt(iTotalQtyMarch))
            nCells[6].innerHTML = addCommas(parseInt(iTotalValueMarch))

            nCells[7].innerHTML = addCommas(parseInt(iTotalQtyApril))
            nCells[8].innerHTML = addCommas(parseInt(iTotalValueApril))

            nCells[9].innerHTML = addCommas(parseInt(iTotalQtyMay))
            nCells[10].innerHTML = addCommas(parseInt(iTotalValueMay))

            nCells[11].innerHTML = addCommas(parseInt(iTotalQtyJune))
            nCells[12].innerHTML = addCommas(parseInt(iTotalValueJune))
				}
    });

		$('#customer_compare2').dataTable({
        
        iDisplayLength: 10,
        bRetrieve: true,
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

            var iTotalQtyJuly = 0;
            var iTotalValueJuly = 0;

            var iTotalQtyAugust = 0;
            var iTotalValueAugust = 0;

            var iTotalQtySeptember = 0;
            var iTotalValueSeptember = 0;

            var iTotalQtyOctober = 0;
            var iTotalValueOctober = 0;

            var iTotalQtyNovember = 0;
            var iTotalValueNovember = 0;

            var iTotalQtyDecember = 0;
            var iTotalValueDecember = 0;

            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalQtyJuly += parseCurrency(aaData[i][2])*1;
                iTotalValueJuly += parseCurrency(aaData[i][3])*1;

                iTotalQtyAugust += parseCurrency(aaData[i][4])*1;
                iTotalValueAugust += parseCurrency(aaData[i][5])*1;

                iTotalQtySeptember += parseCurrency(aaData[i][6])*1;
                iTotalValueSeptember += parseCurrency(aaData[i][7])*1;

                iTotalQtyOctober += parseCurrency(aaData[i][8])*1;
                iTotalValueOctober += parseCurrency(aaData[i][9])*1;

                iTotalQtyNovember += parseCurrency(aaData[i][10])*1;
                iTotalValueNovember += parseCurrency(aaData[i][11])*1;

                iTotalQtyDecember += parseCurrency(aaData[i][12])*1;
                iTotalValueDecember += parseCurrency(aaData[i][13])*1;
            }

            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[1].innerHTML = addCommas(parseInt(iTotalQtyJuly))
            nCells[2].innerHTML = addCommas(parseInt(iTotalValueJuly))

            nCells[3].innerHTML = addCommas(parseInt(iTotalQtyAugust))
            nCells[4].innerHTML = addCommas(parseInt(iTotalValueAugust))

            nCells[5].innerHTML = addCommas(parseInt(iTotalQtySeptember))
            nCells[6].innerHTML = addCommas(parseInt(iTotalValueSeptember))

            nCells[7].innerHTML = addCommas(parseInt(iTotalQtyOctober))
            nCells[8].innerHTML = addCommas(parseInt(iTotalValueOctober))

            nCells[9].innerHTML = addCommas(parseInt(iTotalQtyNovember))
            nCells[10].innerHTML = addCommas(parseInt(iTotalValueNovember))

            nCells[11].innerHTML = addCommas(parseInt(iTotalQtyDecember))
            nCells[12].innerHTML = addCommas(parseInt(iTotalValueDecember))

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
                iTotalQty2012 += parseCurrency(aaData[i][2])*1;
                iTotalValue2012 += parseCurrency(aaData[i][3])*1;

                iTotalQty2013 += parseCurrency(aaData[i][4])*1;
                iTotalValue2013 += parseCurrency(aaData[i][5])*1;

                iTotalQtyGrowth += parseCurrency(aaData[i][6])*1;
                iTotalValueGrowth += parseCurrency(aaData[i][7])*1;
            }

            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[1].innerHTML = addCommas(parseInt(iTotalQty2012))
            nCells[2].innerHTML = addCommas(parseInt(iTotalValue2012))

            nCells[3].innerHTML = addCommas(parseInt(iTotalQty2013))
            nCells[4].innerHTML = addCommas(parseInt(iTotalValue2013))

            nCells[5].innerHTML = addCommas(parseInt(iTotalQtyGrowth))
            nCells[6].innerHTML = addCommas(parseInt(iTotalValueGrowth))

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
