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

    $('#group_by_cabang').dataTable({
        sPaginationType: "full_numbers",
        bJQueryUI: true,
        iDisplayLength: 10,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
        sDom: '<"H"Tfrl>t<"F"ip>',
        bRetrieve: true,
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */
            
            var iTotalQtyClassic = 0;
            var iTotalValueClassic = 0;
            var iTotalQtyElite = 0;
            var iTotalValueElite = 0;
        
            var iTotalQtyLady = 0;
            var iTotalValueLady = 0;
            var iTotalQtyRoyal = 0;
            var iTotalValueRoyal = 0;
            var iTotalQtySerenity = 0;
            var iTotalValueSerenity = 0;
            var iTotalQtyGrand = 0;
            var iTotalValueGrand = 0;
            var iTotalAllQty = 0;
            var iTotalAllValue = 0;
        
            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalQtyClassic += parseCurrency(aaData[i][1])*1;
                iTotalQtyElite += parseCurrency(aaData[i][3])*1;
                iTotalQtyLady += parseCurrency(aaData[i][7])*1;
                iTotalQtyRoyal += parseCurrency(aaData[i][9])*1;
                iTotalQtySerenity += parseCurrency(aaData[i][11])*1;
                iTotalQtyGrand += parseCurrency(aaData[i][5])*1;
								
                iTotalValueClassic += parseCurrency(aaData[i][2])*1;
                iTotalValueElite += parseCurrency(aaData[i][4])*1;
                iTotalValueLady += parseCurrency(aaData[i][8])*1;
                iTotalValueRoyal += parseCurrency(aaData[i][10])*1;
                iTotalValueSerenity += parseCurrency(aaData[i][12])*1;
                iTotalValueGrand += parseCurrency(aaData[i][6])*1;
								
                iTotalAllQty = iTotalQtyClassic + iTotalQtyElite  + iTotalQtyLady + iTotalQtyRoyal + iTotalQtySerenity + iTotalQtyGrand
                iTotalAllValue = iTotalValueClassic + iTotalValueElite + iTotalValueLady + iTotalValueRoyal + iTotalValueSerenity + iTotalValueGrand
            }
             
            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = addCommas(parseInt(iTotalQtyClassic) + ' ('+ parseInt(iTotalAllQty) +')');
            nCells[1].innerHTML = addCommas(parseInt(iTotalValueClassic) + ' ('+ parseInt(iTotalAllValue) +')');
            nCells[2].innerHTML = addCommas(parseInt(iTotalQtyElite)+ ' ('+ parseInt(iTotalAllQty) +')');
            nCells[3].innerHTML = addCommas(parseInt(iTotalValueElite)+ ' ('+ parseInt(iTotalAllValue) +')');
        
            nCells[4].innerHTML = addCommas(parseInt(iTotalQtyGrand)+ ' ('+ parseInt(iTotalAllQty) +')');
            nCells[5].innerHTML = addCommas(parseInt(iTotalValueGrand)+ ' ('+ parseInt(iTotalAllValue) +')');
            nCells[6].innerHTML = addCommas(parseInt(iTotalQtyLady)+ ' ('+ parseInt(iTotalAllQty) +')');
            nCells[7].innerHTML = addCommas(parseInt(iTotalValueLady)+ ' ('+ parseInt(iTotalAllValue) +')');
            nCells[8].innerHTML = addCommas(parseInt(iTotalQtyRoyal)+ ' ('+ parseInt(iTotalAllQty) +')');
            nCells[9].innerHTML = addCommas(parseInt(iTotalValueRoyal)+ ' ('+ parseInt(iTotalAllValue) +')');
            nCells[10].innerHTML = addCommas(parseInt(iTotalQtySerenity)+ ' ('+ parseInt(iTotalAllQty) +')');
            nCells[11].innerHTML = addCommas(parseInt(iTotalValueSerenity)+ ' ('+ parseInt(iTotalAllValue) +')');
        
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
    
    $('#group_by_category').dataTable({
        sPaginationType: "full_numbers",
        bJQueryUI: true,
        iDisplayLength: 10,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
        sDom: '<"H"Tfrl>t<"F"ip>',
        bRetrieve: true,
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */
            
            var iTotalQtyBandung = 0;
            var iTotalValueBandung = 0;
            var iTotalQtyNarogong = 0;
            var iTotalValueNarogong = 0;
        
            var iTotalQtyBali = 0;
            var iTotalValueBali = 0;
            var iTotalQtyMedan = 0;
            var iTotalValueMedan = 0;
            var iTotalQtySurabaya = 0;
            var iTotalValueSurabaya = 0;
            var iTotalQtySemarang = 0;
            var iTotalValueSemarang = 0;
            var iTotalQtyCirebon = 0;
            var iTotalValueCirebon = 0;
            var iTotalQtyJogyakarta = 0;
            var iTotalValueJogyakarta = 0;
            var iTotalQtyPalembang = 0;
            var iTotalValuePalembang = 0;
            var iTotalQtyLampung = 0;
            var iTotalValueLampung = 0;
            var iTotalQtyMakasar = 0;
            var iTotalValueMakasar = 0;
            var iTotalQtyPekanbaru = 0;
            var iTotalValuePekanbaru = 0;
            var iTotalQtyJember = 0;
            var iTotalValueJember = 0;
        
            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalQtyBandung += parseCurrency(aaData[i][1])*1;
                iTotalValueBandung += parseCurrency(aaData[i][2])*1; 
                iTotalQtyNarogong += parseCurrency(aaData[i][3])*1;
                iTotalValueNarogong += parseCurrency(aaData[i][4])*1;
                iTotalQtyBali += parseCurrency(aaData[i][5])*1;
                iTotalValueBali += parseCurrency(aaData[i][6])*1;
                iTotalQtyMedan += parseCurrency(aaData[i][7])*1;
                iTotalValueMedan += parseCurrency(aaData[i][8])*1;
                iTotalQtySurabaya += parseCurrency(aaData[i][9])*1;
                iTotalValueSurabaya += parseCurrency(aaData[i][10])*1;
                iTotalQtySemarang += parseCurrency(aaData[i][11])*1;
                iTotalValueSemarang += parseCurrency(aaData[i][12])*1;
                iTotalQtyCirebon += parseCurrency(aaData[i][13])*1;
                iTotalValueCirebon += parseCurrency(aaData[i][14])*1;
                iTotalQtyJogyakarta += parseCurrency(aaData[i][15])*1;
                iTotalValueJogyakarta += parseCurrency(aaData[i][16])*1;
                iTotalQtyPalembang += parseCurrency(aaData[i][17])*1;
                iTotalValuePalembang += parseCurrency(aaData[i][18])*1;
                iTotalQtyLampung += parseCurrency(aaData[i][19])*1;
                iTotalValueLampung += parseCurrency(aaData[i][20])*1;
                iTotalQtyMakasar += parseCurrency(aaData[i][21])*1;
                iTotalValueMakasar += parseCurrency(aaData[i][22])*1;
                iTotalQtyPekanbaru += parseCurrency(aaData[i][23])*1;
                iTotalValuePekanbaru += parseCurrency(aaData[i][24])*1;
                iTotalQtyJember += parseCurrency(aaData[i][25])*1;
                iTotalValueJember += parseCurrency(aaData[i][26])*1;
            }
             
            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = addCommas(parseInt(iTotalQtyBandung))
            nCells[1].innerHTML = addCommas(parseInt(iTotalValueBandung))

            nCells[2].innerHTML = addCommas(parseInt(iTotalQtyNarogong))
            nCells[3].innerHTML = addCommas(parseInt(iTotalValueNarogong))

            nCells[4].innerHTML = addCommas(parseInt(iTotalQtyBali))
            nCells[5].innerHTML = addCommas(parseInt(iTotalValueBali))

            nCells[6].innerHTML = addCommas(parseInt(iTotalQtyMedan))
            nCells[7].innerHTML = addCommas(parseInt(iTotalValueMedan))

            nCells[8].innerHTML = addCommas(parseInt(iTotalQtySurabaya))
            nCells[9].innerHTML = addCommas(parseInt(iTotalValueSurabaya))

            nCells[10].innerHTML = addCommas(parseInt(iTotalQtySemarang))
            nCells[11].innerHTML = addCommas(parseInt(iTotalValueSemarang))

            nCells[12].innerHTML = addCommas(parseInt(iTotalQtyCirebon))
            nCells[13].innerHTML = addCommas(parseInt(iTotalValueCirebon))

            nCells[14].innerHTML = addCommas(parseInt(iTotalQtyJogyakarta))
            nCells[15].innerHTML = addCommas(parseInt(iTotalValueJogyakarta))

            nCells[16].innerHTML = addCommas(parseInt(iTotalQtyPalembang))
            nCells[17].innerHTML = addCommas(parseInt(iTotalValuePalembang))

            nCells[18].innerHTML = addCommas(parseInt(iTotalQtyLampung))
            nCells[19].innerHTML = addCommas(parseInt(iTotalValueLampung))

            nCells[20].innerHTML = addCommas(parseInt(iTotalQtyMakasar))
            nCells[21].innerHTML = addCommas(parseInt(iTotalValueMakasar))

            nCells[24].innerHTML = addCommas(parseInt(iTotalQtyJember))
            nCells[25].innerHTML = addCommas(parseInt(iTotalValueJember))

            nCells[22].innerHTML = addCommas(parseInt(iTotalQtyPekanbaru))
            nCells[23].innerHTML = addCommas(parseInt(iTotalValuePekanbaru))
        
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
        "aoColumnDefs": [{
            "bVisible": false,
            "aTargets": [2]
        }],
        "fnFooterCallback": function ( nRow, aaData, iStart, iEnd, aiDisplay ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */
            var iTotalQuantity = 0;
            var iTotalValue = 0;

            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalQuantity += parseCurrency(aaData[i][12])*1;
                iTotalValue += parseCurrency(aaData[i][13])*1;
            }

            var iPageQuantity = 0;
            var iPageValue = 0;
            for ( var i=iStart ; i<iEnd ; i++ )
            {
                iPageQuantity += aaData[ aiDisplay[i] ][12]*1;
                iPageValue += parseCurrency(aaData[ aiDisplay[i] ][13])*1;
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
        {
            sSelector: "#market",
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
