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
                iTotalLastYearMonth += aaData[i][7]*1;
                iTotalCurrentYearMonth += aaData[i][8]*1;
                iTotalLastYear += aaData[i][10]*1;
                iTotalCurrentYear += aaData[i][11]*1;
          
                iTotalLastWeekLastYear += aaData[i][1]*1;
                iTotalLastWeekCurrentYear += aaData[i][2]*1;
                iTotalThisWeekLastYear += aaData[i][4]*1;
                iTotalThisWeekCurrentYear += aaData[i][5]*1;
            }
             
            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = parseInt(iTotalLastWeekLastYear)
            nCells[1].innerHTML = parseInt(iTotalLastWeekCurrentYear)
            nCells[3].innerHTML = parseInt(iTotalThisWeekLastYear)
            nCells[4].innerHTML = parseInt(iTotalThisWeekCurrentYear)
        
            nCells[2].innerHTML = parseInt((iTotalLastWeekCurrentYear - iTotalLastWeekLastYear) / iTotalLastWeekLastYear * 100)
            nCells[5].innerHTML = parseInt((iTotalThisWeekCurrentYear - iTotalThisWeekLastYear) / iTotalThisWeekLastYear * 100)
        
            nCells[6].innerHTML = parseInt(iTotalLastYearMonth)
            nCells[7].innerHTML = parseInt(iTotalCurrentYearMonth)
            nCells[9].innerHTML = parseInt(iTotalLastYear)
            nCells[10].innerHTML = parseInt(iTotalCurrentYear)
            nCells[8].innerHTML = parseInt((iTotalCurrentYearMonth - iTotalLastYearMonth) / iTotalLastYearMonth * 100) ;
            nCells[11].innerHTML = parseInt((iTotalCurrentYear - iTotalLastYear) / iTotalLastYear * 100) ;
        },
        "fnRowCallback": function( nRow, aData, iDisplayIndex ) {
        
            var iTotalLastYearMonth = 0;
        
            for ( var i=0 ; i< aData.length ; i++ )
            {
                iTotalLastYearMonth = aData[i][2];
            }
        }
    });
    $('#table_year_elite').dataTable({
        sPaginationType: "full_numbers",
        bJQueryUI: true,
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
        
            var iTotalLastWeekLastYear2 = 0;
            var iTotalLastWeekCurrentYear2 = 0;
            var iTotalThisWeekLastYear2 = 0;
            var iTotalThisWeekCurrentYear2 = 0;
        
            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalLastYearMonth += aaData[i][13]*1;
                iTotalCurrentYearMonth += aaData[i][14]*1;
                iTotalLastYear += aaData[i][16]*1;
                iTotalCurrentYear += aaData[i][17]*1;
          
                iTotalLastWeekLastYear += aaData[i][1]*1;
                iTotalLastWeekCurrentYear += aaData[i][2]*1;
                iTotalThisWeekLastYear += aaData[i][4]*1;
                iTotalThisWeekCurrentYear += aaData[i][5]*1;
          
                iTotalLastWeekLastYear2 += aaData[i][7]*1;
                iTotalLastWeekCurrentYear2 += aaData[i][8]*1;
                iTotalThisWeekLastYear2 += aaData[i][10]*1;
                iTotalThisWeekCurrentYear2 += aaData[i][11]*1;
            }
             
            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = parseInt(iTotalLastWeekLastYear)
            nCells[1].innerHTML = parseInt(iTotalLastWeekCurrentYear)
            nCells[3].innerHTML = parseInt(iTotalThisWeekLastYear)
            nCells[4].innerHTML = parseInt(iTotalThisWeekCurrentYear)
        
            nCells[2].innerHTML = parseInt((iTotalLastWeekCurrentYear - iTotalLastWeekLastYear) / iTotalLastWeekLastYear * 100)
            nCells[5].innerHTML = parseInt((iTotalThisWeekCurrentYear - iTotalThisWeekLastYear) / iTotalThisWeekLastYear * 100)
        
            nCells[6].innerHTML = parseInt(iTotalLastWeekLastYear2)
            nCells[7].innerHTML = parseInt(iTotalLastWeekCurrentYear2)
            nCells[9].innerHTML = parseInt(iTotalThisWeekLastYear2)
            nCells[10].innerHTML = parseInt(iTotalThisWeekCurrentYear2)
        
            nCells[8].innerHTML = parseInt((iTotalLastWeekCurrentYear2 - iTotalLastWeekLastYear2) / iTotalLastWeekLastYear2 * 100)
            nCells[11].innerHTML = parseInt((iTotalThisWeekCurrentYear2 - iTotalThisWeekLastYear2) / iTotalThisWeekLastYear2 * 100)
        
            nCells[12].innerHTML = parseInt(iTotalLastYearMonth)
            nCells[13].innerHTML = parseInt(iTotalCurrentYearMonth)
            nCells[15].innerHTML = parseInt(iTotalLastYear)
            nCells[16].innerHTML = parseInt(iTotalCurrentYear)
            nCells[14].innerHTML = parseInt((iTotalCurrentYearMonth - iTotalLastYearMonth) / iTotalLastYearMonth * 100) ;
            nCells[17].innerHTML = parseInt((iTotalCurrentYear - iTotalLastYear) / iTotalLastYear * 100) ;
        }
    });
    
    // Add a tabletool to export to pdf, excel and csv
    var oTable = $('#laporancabang').dataTable({
        bJQueryUI: true,
        sPaginationType: "full_numbers",
        sDom: '<"H"Tfr>t<"F"ip>',
        bRetrieve: true,
        fnRowCallback: function( nRow, aData, iDisplayIndex ) {
            return nRow;
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
        sPlaceHolder: "head:after",
        aoColumns: [
        null,
        null,
        {
            type: "checkbox",
            values: ["Bandung", "Narogong", "Bali", "Medan", "Surabaya", "Semarang", "Cirebon",
            "Yogyakarta", "Palembang", "Lampung", "Meruya", "Makasar", "Pekanbaru", "Jember"]
        },
        {
            type: "text",
            bRegex: true,
            bSmart: true
        },
        null,
        null,
        {
            type: "checkbox",
            values: ["Classic", "Elite", "Grand", "Lady Americana", "Royal", "Serenity"]
        },
        null,
        null,
        {
            type: "checkbox"
        },
        {
            type: "checkbox"
        },
        {
            type: "checkbox"
        },
        {
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
});