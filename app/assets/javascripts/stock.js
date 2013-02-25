/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

$(document).ready(function(){
    $('#stock_category').multiselect({
        selectedList: 4
    });
    
    $('#date').datepicker({
        dateFormat: 'yy-mm-dd'
    }).attr('readonly','readonly');
    
    var oTable = $('#stock.display').dataTable({
        sScrollY: "200px",
        bPaginate: false,
        bJQueryUI: true
    }).columnFilter({
        aoColumns: [
        {
            type: "checkbox",
            values: ["Classic", "Elite", "Grand", "Lady Americana", "Royal", "Serenity"]
        }
        ]
    });
});