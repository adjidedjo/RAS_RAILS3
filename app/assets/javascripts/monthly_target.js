$(document).ready(function(){
  $('#monthly_target_sales').dataTable({
    iDisplayLength: 10,
    bRetrieve: true,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalTarget = 0;
      var iTotalSales = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalTarget += parseCurrency(aaData[i][2])*1;
        iTotalSales += parseCurrency(aaData[i][3])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[1].innerHTML = addCommas(parseInt(iTotalTarget))
      nCells[2].innerHTML = addCommas(parseInt(iTotalSales))
    }
  });
  
  $('#monthly_target_branch').dataTable({
    iDisplayLength: 10,
    bRetrieve: true,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalTarget = 0;
      var iTotalSales = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalTarget += parseCurrency(aaData[i][1])*1;
        iTotalSales += parseCurrency(aaData[i][2])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalTarget))
      nCells[1].innerHTML = addCommas(parseInt(iTotalSales))
    }
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
