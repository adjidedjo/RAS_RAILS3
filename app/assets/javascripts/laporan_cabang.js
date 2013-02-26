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
    
    // Add a tabletool to export to pdf, excel and csv
    var oTable = $('#laporancabang').dataTable({
        bJQueryUI: true,
        sPaginationType: "full_numbers",
        sDom: '<"H"Tfr>t<"F"ip>',
        bRetrieve: true,
        fnRowCallback: function( nRow, aData, iDisplayIndex ) {
            var id = aData[5];
            $(nRow).attr("id",id);
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
});