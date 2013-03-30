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
            sSelector: "#brand",
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
        }
        ]
    });
});