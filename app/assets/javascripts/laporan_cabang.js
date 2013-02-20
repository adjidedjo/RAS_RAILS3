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
    
    /* (function($) {
        
        $.fn.dataTableExt.oApi.fnGetColumnData = function ( oSettings, iColumn, bUnique, bFiltered, bIgnoreEmpty ) {
            // check that we have a column id
            if ( typeof iColumn == "undefined" ) return new Array();
            // by default we only wany unique data
            if ( typeof bUnique == "undefined" ) bUnique = true;
            // by default we do want to only look at filtered data
            if ( typeof bFiltered == "undefined" ) bFiltered = true;
            // by default we do not wany to include empty values
            if ( typeof bIgnoreEmpty == "undefined" ) bIgnoreEmpty = true;
            // list of rows which we're going to loop through
            var aiRows;
            // use only filtered rows
            if (bFiltered == true) aiRows = oSettings.aiDisplay; 
            // use all rows
            else aiRows = oSettings.aiDisplayMaster; // all row numbers
            // set up data array	
            var asResultData = new Array();

            for (var i=0,c=aiRows.length; i<c; i++) {
                iRow = aiRows[i];
                var aData = this.fnGetData(iRow);
                var sValue = aData[iColumn];
                // ignore empty values?
                if (bIgnoreEmpty == true && sValue.length == 0) continue;
                // ignore unique values?
                else if (bUnique == true && jQuery.inArray(sValue, asResultData) > -1) continue;
                // else push the value onto the result data array
                else asResultData.push(sValue);
            }
	
            return asResultData;
        }
    }(jQuery)); */
    
    // Add a tabletool to export to pdf, excel and csv
    var oTable = $('#laporancabang').dataTable({
        bJQueryUI: true,
        sPaginationType: "full_numbers",
        sDom: '<"H"Tfr>t<"F"ip>',
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
    new FixedHeader( oTable);
});