/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

$(document).ready(function(){
    $('#category').multiselect({
        noneSelectedText: 'Select car/boat manufacturers',
        selectedList: 4
    });
    
    $('#date').datepicker({
        dateFormat: 'yy-mm-dd'
    }).attr('readonly','readonly');
});