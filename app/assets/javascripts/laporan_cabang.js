// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function fnCreateSelect( aData, aSelected )
{
    var r='<select><option value=""></option>', i, iLen=aData.length;
    for ( i=0 ; i<iLen ; i++ )
    {
        r += '<option value="'+aData[i]+'" ';
        if(aSelected == aData[i]) { 
            r +='selected="selected"';
        }
        r +='>'+aData[i]+'</option>';
    }
    return r+'</select>';
}

$(document).ready(function(){
    // Datepicker
    $('#from').datepicker({
        dateFormat: 'yy-mm-dd'
    }).attr('readonly','readonly');
    $('#to').datepicker({
        dateFormat: 'yy-mm-dd'
    }).attr('readonly','readonly');
    $('#week').datepicker({
        dateFormat: 'yy-mm-dd'
    }).attr('readonly','readonly');
    $('#periode').datepicker({
        dateFormat: 'yy-mm-dd'
    }).attr('readonly','readonly');
    
    $('#table_year').dataTable( {
        sPaginationType: "full_numbers",
        bJQueryUI: true,
        iDisplayLength: 20,
        sDom: '<"H"Tfr>t<"F"ip>',
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
         * Calculate the total market share for all browsers in this table (ie inc. outside
         * the pagination)
         */
            var iTotalLastYearMonth = 0;
            var iTotalCurrentYearMonth = 0;
            var iTotalLastYear = 0;
            var iTotalCurrentYear = 0;
        
            var iTotalLastWeekLastYear = 0;
            var iTotalLastWeekCurrentYear = 0;
            var iTotalThisWeekLastYear = 0;
            var iTotalThisWeekCurrentYear = 0;
        
            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalLastYearMonth += parseCurrency(aaData[i][7])*1;
                iTotalCurrentYearMonth += parseCurrency(aaData[i][8])*1;
                iTotalLastYear += parseCurrency(aaData[i][10])*1;
                iTotalCurrentYear += parseCurrency(aaData[i][11])*1;
          
                iTotalLastWeekLastYear += parseCurrency(aaData[i][1])*1;
                iTotalLastWeekCurrentYear += parseCurrency(aaData[i][2])*1;
                iTotalThisWeekLastYear += parseCurrency(aaData[i][4])*1;
                iTotalThisWeekCurrentYear += parseCurrency(aaData[i][5])*1;
            }
             
            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = addCommas(parseInt(iTotalLastWeekLastYear))
            nCells[1].innerHTML = addCommas(parseInt(iTotalLastWeekCurrentYear))
            nCells[3].innerHTML = addCommas(parseInt(iTotalThisWeekLastYear))
            nCells[4].innerHTML = addCommas(parseInt(iTotalThisWeekCurrentYear))
        
            nCells[2].innerHTML = parseInt((iTotalLastWeekCurrentYear - iTotalLastWeekLastYear) / iTotalLastWeekLastYear * 100) + "%"
            nCells[5].innerHTML = parseInt((iTotalThisWeekCurrentYear - iTotalThisWeekLastYear) / iTotalThisWeekLastYear * 100) + "%"
        
            nCells[6].innerHTML = addCommas(parseInt(iTotalLastYearMonth))
            nCells[7].innerHTML = addCommas(parseInt(iTotalCurrentYearMonth))
            nCells[9].innerHTML = addCommas(parseInt(iTotalLastYear))
            nCells[10].innerHTML = addCommas(parseInt(iTotalCurrentYear))
            nCells[8].innerHTML = parseInt((iTotalCurrentYearMonth - iTotalLastYearMonth) / iTotalLastYearMonth * 100) + "%" ;
            nCells[11].innerHTML = parseInt((iTotalCurrentYear - iTotalLastYear) / iTotalLastYear * 100) + "%" ;
        },
        "fnRowCallback": function( nRow, aData, iDisplayIndex ) {
        
            var iTotalLastYearMonth = 0;
        
            for ( var i=0 ; i< aData.length ; i++ )
            {
                iTotalLastYearMonth = aData[i][2];
            }
        },
        oTableTools: {
            sSwfPath: "/copy_csv_xls.swf",
            aButtons: [
            {
                "sExtends": "xls",
                "sButtonText": "Export to Excel"
            }
            ]
        }
    });
    $('#table_year_elite').dataTable({
        sPaginationType: "full_numbers",
        bJQueryUI: true,
        iDisplayLength: 20,
        sDom: '<"H"Tfr>t<"F"ip>',
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
         * Calculate the total market share for all browsers in this table (ie inc. outside
         * the pagination)
         */
            
            var iTotalLastWeekLastYear = 0;
            var iTotalLastWeekCurrentYear = 0;
            var iTotalThisWeekLastYear = 0;
            var iTotalThisWeekCurrentYear = 0;
        
            var iTotalLastWeekLastYear2 = 0;
            var iTotalLastWeekCurrentYear2 = 0;
            var iTotalThisWeekLastYear2 = 0;
            var iTotalThisWeekCurrentYear2 = 0;
        
            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalLastWeekLastYear += parseCurrency(aaData[i][1])*1;
                iTotalLastWeekCurrentYear += parseCurrency(aaData[i][2])*1;
                iTotalThisWeekLastYear += parseCurrency(aaData[i][4])*1;
                iTotalThisWeekCurrentYear += parseCurrency(aaData[i][5])*1;
          
                iTotalLastWeekLastYear2 += parseCurrency(aaData[i][7])*1;
                iTotalLastWeekCurrentYear2 += parseCurrency(aaData[i][8])*1;
                iTotalThisWeekLastYear2 += parseCurrency(aaData[i][10])*1;
                iTotalThisWeekCurrentYear2 += parseCurrency(aaData[i][11])*1;
            }
             
            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = addCommas(parseInt(iTotalLastWeekLastYear))
            nCells[1].innerHTML = addCommas(parseInt(iTotalLastWeekCurrentYear))
            nCells[3].innerHTML = addCommas(parseInt(iTotalThisWeekLastYear))
            nCells[4].innerHTML = addCommas(parseInt(iTotalThisWeekCurrentYear))
        
            nCells[2].innerHTML = parseInt((iTotalLastWeekCurrentYear - iTotalLastWeekLastYear) / iTotalLastWeekLastYear * 100) + "%"
            nCells[5].innerHTML = parseInt((iTotalThisWeekCurrentYear - iTotalThisWeekLastYear) / iTotalThisWeekLastYear * 100) + "%"
        
            nCells[6].innerHTML = addCommas(parseInt(iTotalLastWeekLastYear2))
            nCells[7].innerHTML = addCommas(parseInt(iTotalLastWeekCurrentYear2))
            nCells[9].innerHTML = addCommas(parseInt(iTotalThisWeekLastYear2))
            nCells[10].innerHTML = addCommas(parseInt(iTotalThisWeekCurrentYear2))
        
            nCells[8].innerHTML = parseInt((iTotalLastWeekCurrentYear2 - iTotalLastWeekLastYear2) / iTotalLastWeekLastYear2 * 100) + "%"
            nCells[11].innerHTML = parseInt((iTotalThisWeekCurrentYear2 - iTotalThisWeekLastYear2) / iTotalThisWeekLastYear2 * 100) + "%"
        
        },
        oTableTools: {
            sSwfPath: "/copy_csv_xls.swf",
            aButtons: [
            {
                "sExtends": "xls",
                "sButtonText": "Export to Excel"
            }
            ]
        }
    });
    $('#table_year_elite_month_and_year').dataTable({
        sPaginationType: "full_numbers",
        bJQueryUI: true,
        iDisplayLength: 20,
        sDom: '<"H"Tfr>t<"F"ip>',
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
         * Calculate the total market share for all browsers in this table (ie inc. outside
         * the pagination)
         */
            var iTotalLastYearMonth = 0;
            var iTotalCurrentYearMonth = 0;
            var iTotalLastYear = 0;
            var iTotalCurrentYear = 0;
            
            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalLastYearMonth += parseCurrency(aaData[i][1])*1;
                iTotalCurrentYearMonth += parseCurrency(aaData[i][2])*1;
                iTotalLastYear += parseCurrency(aaData[i][4])*1;
                iTotalCurrentYear += parseCurrency(aaData[i][5])*1;
            }
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = addCommas(parseInt(iTotalLastYearMonth))
            nCells[1].innerHTML = addCommas(parseInt(iTotalCurrentYearMonth))
            nCells[3].innerHTML = addCommas(parseInt(iTotalLastYear))
            nCells[4].innerHTML = addCommas(parseInt(iTotalCurrentYear))
            nCells[2].innerHTML = parseInt((iTotalCurrentYearMonth - iTotalLastYearMonth) / iTotalLastYearMonth * 100) + "%" ;
            nCells[5].innerHTML = parseInt((iTotalCurrentYear - iTotalLastYear) / iTotalLastYear * 100) + "%" ;
            
        },
        oTableTools: {
            sSwfPath: "/copy_csv_xls.swf",
            aButtons: [
            {
                "sExtends": "xls",
                "sButtonText": "Export to Excel"
            }
            ]
        }
    });
    
    // Add a tabletool to export to pdf, excel and csv
    var oTable = $('#laporancabang').dataTable({
        bJQueryUI: true,
        sPaginationType: "full_numbers",
        iDisplayLength: 10,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
        sDom: '<"H"Tfrl>t<"F"ip>',
        bRetrieve: true,
        fnRowCallback: function( nRow, aData, iDisplayIndex ) {
            return nRow;
        },
        "fnFooterCallback": function ( nRow, aaData, iStart, iEnd, aiDisplay ) {
            /*
         * Calculate the total market share for all browsers in this table (ie inc. outside
         * the pagination)
         */
            var iTotalQuantity = 0;
            var iTotalValue = 0;

            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalQuantity += parseCurrency(aaData[i][11])*1;
                iTotalValue += parseCurrency(aaData[i][12])*1;
            }

            var iPageQuantity = 0;
            var iPageValue = 0;
            for ( var i=iStart ; i<iEnd ; i++ )
            {
                iPageQuantity += aaData[ aiDisplay[i] ][11]*1;
                iPageValue += parseCurrency(aaData[ aiDisplay[i] ][12])*1;
            }

            var nCells = nRow.getElementsByTagName('td');
            nCells[10].innerHTML = addCommas(parseInt(iPageQuantity) + ' ('+ parseInt(iTotalQuantity) +')');
            nCells[11].innerHTML = addCommas(parseInt(iPageValue) + ' ('+ parseInt(iTotalValue) +')');

        },
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
            type: "checkbox",
            values: ["Bandung", "Narogong", "Bali", "Medan", "Surabaya", "Semarang", "Cirebon",
            "Yogyakarta", "Palembang", "Lampung", "Meruya", "Makasar", "Pekanbaru", "Jember"]
        },
        {
            sSelector: "#customer",
            type: "checkbox"
        },
        null,
        null,
        {
            sSelector: "#brand",
            type: "checkbox",
            values: ["Classic", "Elite", "Grand", "Lady Americana", "Royal", "Serenity"]
        },
        null,
        {
            sSelector: "#tipe",
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
        null,
        ]
    });
    $('#table_control_branch').dataTable({
        bJQueryUI: true,
        sPaginationType: "full_numbers"
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