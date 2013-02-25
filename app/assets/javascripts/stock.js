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
    
    $('#stock.display').dataTable({
        "sScrollY": "200px",
        "bScrollCollapse": true,
        "bPaginate": false,
        "bJQueryUI": true,
        "aoColumnDefs": [
        {
            "aTargets": [ -1 ]
        }
        ]
    });
});