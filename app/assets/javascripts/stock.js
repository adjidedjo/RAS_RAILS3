/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

$(document).ready(function(){
    $('#brand_select').multiselect({
        selectedList: 4
    });
    
    $('#date').datepicker({
        dateFormat: 'yy-mm-dd'
    }).attr('readonly','readonly');
    
    $('#stock.display').dataTable({
        sScrollY: "200px",
        bPaginate: false,
        sScrollX: "100%",
        sScrollXInner: "110%",
        bScrollCollapse: true,
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