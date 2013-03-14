/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

$(document).ready(function(){
    $('#brand_select').multiselect({
        selectedList: 4
    });
    
    $('#brand_product_select').multiselect({
        selectedList: 4
    });
    
    $('#artikel_select').multiselect({
        selectedList: 4
    });
    
    $('#date').datepicker({
        dateFormat: 'yy-mm-dd'
    }).attr('readonly','readonly');
    
    $('#stock').dataTable({
        sScrollY: "200px",
        bPaginate: false,
        sScrollX: "100%",
        sScrollXInner: "110%",
        bScrollCollapse: true,
        bJQueryUI: true
    }).columnFilter({
        sPlaceHolder: "head:after",
        aoColumns: [
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
        {
            type: "checkbox"
        }
        ]
    });
});