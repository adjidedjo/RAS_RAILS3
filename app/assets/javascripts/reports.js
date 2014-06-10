$(document).ready(function(){    
  $('#cabang_id').multiselect({
    buttonClass: 'btn',
    buttonWidth: 'auto',
    buttonContainer: '<div class="btn-group" />',
    maxHeight: 400,
    buttonText: function(options) {
      if (options.length == 0) {
        return 'None selected <b class="caret"></b>';
      }
      else if (options.length > 1) {
        return options.length + ' selected <b class="caret"></b>';
      }
      else {
        var selected = '';
        options.each(function() {
          selected += $(this).text() + ', ';
        });
        return selected.substr(0, selected.length -2) + ' <b class="caret"></b>';
      }
    }
  });
  $('#merk_id').multiselect({
    buttonClass: 'btn',
    buttonWidth: 'auto',
    buttonContainer: '<div class="btn-group" />',
    maxHeight: 400,
    buttonText: function(options) {
      if (options.length == 0) {
        return 'None selected <b class="caret"></b>';
      }
      else if (options.length > 1) {
        return options.length + ' selected <b class="caret"></b>';
      }
      else {
        var selected = '';
        options.each(function() {
          selected += $(this).text() + ', ';
        });
        return selected.substr(0, selected.length -2) + ' <b class="caret"></b>';
      }
    }
  });
  $('#type_id').multiselect({
    buttonClass: 'btn',
    buttonWidth: 'auto',
    buttonContainer: '<div class="btn-group" />',
    maxHeight: 400,
    buttonText: function(options) {
      if (options.length == 0) {
        return 'None selected <b class="caret"></b>';
      }
      else if (options.length > 1) {
        return options.length + ' selected <b class="caret"></b>';
      }
      else {
        var selected = '';
        options.each(function() {
          selected += $(this).text() + ', ';
        });
        return selected.substr(0, selected.length -2) + ' <b class="caret"></b>';
      }
    }
  });
    
		
  $('#cus_compare').dataTable({
    iDisplayLength: 10,
    bRetrieve: true
  //        "fnFooterCallback": function ( nRow, aaData ) {
  //            /*
  //             * Calculate the total market share for all browsers in this table (ie inc. outside
  //             * the pagination)
  //             */
  //
  //            var iTotalQtyCity = 0;
  //            
  //            var iTotalQtyJanuary = 0;
  //            var iTotalValueJanuary = 0;
  //
  //            var iTotalQtyFebruary = 0;
  //            var iTotalValueFebruary = 0;
  //
  //            var iTotalQtyMarch = 0;
  //            var iTotalValueMarch = 0;
  //
  //            var iTotalQtyApril = 0;
  //            var iTotalValueApril = 0;
  //
  //            var iTotalQtyMay = 0;
  //            var iTotalValueMay = 0;
  //
  //            var iTotalQtyJune = 0;
  //            var iTotalValueJune = 0;
  //
  //            for ( var i=0 ; i<aaData.length ; i++ )
  //            {
  //                
  //                iTotalQtyJanuary += parseCurrency(aaData[i][2])*1;
  //                iTotalValueJanuary += parseCurrency(aaData[i][3])*1;
  //
  //                iTotalQtyFebruary += parseCurrency(aaData[i][4])*1;
  //                iTotalValueFebruary += parseCurrency(aaData[i][5])*1;
  //
  //                iTotalQtyMarch += parseCurrency(aaData[i][6])*1;
  //                iTotalValueMarch += parseCurrency(aaData[i][7])*1;
  //
  //                iTotalQtyApril += parseCurrency(aaData[i][8])*1;
  //                iTotalValueApril += parseCurrency(aaData[i][9])*1;
  //
  //                iTotalQtyMay += parseCurrency(aaData[i][10])*1;
  //                iTotalValueMay += parseCurrency(aaData[i][11])*1;
  //
  //                iTotalQtyJune += parseCurrency(aaData[i][12])*1;
  //                iTotalValueJune += parseCurrency(aaData[i][13])*1;
  //            }

  /* Modify the footer row to match what we want */
  //            var nCells = nRow.getElementsByTagName('td');
  ////            nCells[1].innerHTML = addCommas(parseInt(iTotalQtyCity))
  //            
  ////            nCells[0].innerHTML = addCommas(parseInt(iTotalQtyJanuary))
  //            nCells[1].innerHTML = addCommas(parseInt(iTotalValueJanuary))
  //
  //            nCells[2].innerHTML = addCommas(parseInt(iTotalQtyFebruary))
  //            nCells[3].innerHTML = addCommas(parseInt(iTotalValueFebruary))
  //
  //            nCells[4].innerHTML = addCommas(parseInt(iTotalQtyMarch))
  //            nCells[5].innerHTML = addCommas(parseInt(iTotalValueMarch))
  //
  //            nCells[6].innerHTML = addCommas(parseInt(iTotalQtyApril))
  //            nCells[7].innerHTML = addCommas(parseInt(iTotalValueApril))
  //
  //            nCells[8].innerHTML = addCommas(parseInt(iTotalQtyMay))
  //            nCells[9].innerHTML = addCommas(parseInt(iTotalValueMay))
  //
  //            nCells[10].innerHTML = addCommas(parseInt(iTotalQtyJune))
  //            nCells[11].innerHTML = addCommas(parseInt(iTotalValueJune))
  //            nCells[12].innerHTML = addCommas(parseInt(iTotalValueJanuary))
  //        }
  });
  $('#cus_compare2').dataTable({
        
    iDisplayLength: 10,
    bRetrieve: true
  //        "fnFooterCallback": function ( nRow, aaData ) {
  //            /*
  //             * Calculate the total market share for all browsers in this table (ie inc. outside
  //             * the pagination)
  //             */
  //            var iTotalQtyCity = 0;
  //            
  //            var iTotalQtyJuly = 0;
  //            var iTotalValueJuly = 0;
  //
  //            var iTotalQtyAugust = 0;
  //            var iTotalValueAugust = 0;
  //
  //            var iTotalQtySeptember = 0;
  //            var iTotalValueSeptember = 0;
  //
  //            var iTotalQtyOctober = 0;
  //            var iTotalValueOctober = 0;
  //
  //            var iTotalQtyNovember = 0;
  //            var iTotalValueNovember = 0;
  //
  //            var iTotalQtyDecember = 0;
  //            var iTotalValueDecember = 0;
  //
  //            for ( var i=0 ; i<aaData.length ; i++ )
  //            {
  ////                iTotalQtyCity += parseCurrency(aaData[i][2])*1;
  //                
  //                iTotalQtyJuly += parseCurrency(aaData[i][2])*1;
  //                iTotalValueJuly += parseCurrency(aaData[i][3])*1;
  //
  //                iTotalQtyAugust += parseCurrency(aaData[i][4])*1;
  //                iTotalValueAugust += parseCurrency(aaData[i][5])*1;
  //
  //                iTotalQtySeptember += parseCurrency(aaData[i][6])*1;
  //                iTotalValueSeptember += parseCurrency(aaData[i][7])*1;
  //
  //                iTotalQtyOctober += parseCurrency(aaData[i][8])*1;
  //                iTotalValueOctober += parseCurrency(aaData[i][9])*1;
  //
  //                iTotalQtyNovember += parseCurrency(aaData[i][10])*1;
  //                iTotalValueNovember += parseCurrency(aaData[i][11])*1;
  //
  //                iTotalQtyDecember += parseCurrency(aaData[i][12])*1;
  //                iTotalValueDecember += parseCurrency(aaData[i][13])*1;
  //            }

  /* Modify the footer row to match what we want */
  //            var nCells = nRow.getElementsByTagName('td');
  ////            nCells[1].innerHTML = addCommas(parseInt(iTotalQtyCity))
  //            
  //            nCells[2].innerHTML = addCommas(parseInt(iTotalQtyJuly))
  //            nCells[3].innerHTML = addCommas(parseInt(iTotalValueJuly))
  //
  //            nCells[4].innerHTML = addCommas(parseInt(iTotalQtyAugust))
  //            nCells[5].innerHTML = addCommas(parseInt(iTotalValueAugust))
  //
  //            nCells[6].innerHTML = addCommas(parseInt(iTotalQtySeptember))
  //            nCells[7].innerHTML = addCommas(parseInt(iTotalValueSeptember))
  //
  //            nCells[8].innerHTML = addCommas(parseInt(iTotalQtyOctober))
  //            nCells[9].innerHTML = addCommas(parseInt(iTotalValueOctober))
  //
  //            nCells[10].innerHTML = addCommas(parseInt(iTotalQtyNovember))
  //            nCells[11].innerHTML = addCommas(parseInt(iTotalValueNovember))
  //
  //            nCells[12].innerHTML = addCommas(parseInt(iTotalQtyDecember))
  //            nCells[13].innerHTML = addCommas(parseInt(iTotalValueDecember))

  //        }
  });
		
  // Add a tabletool to export to pdf, excel and csv
  $('#detail_report').dataTable({
    "bScrollCollapse": true,
    "bPaginate": false,
    "bAutoWidth": false,
    "bInfo": false,  
    "bFilter": false,
    sDom: '<"H"Tfrl>t<"F"ip>',
    oTableTools: {
      sSwfPath: "/copy_csv_xls.swf",
      aButtons: [
      {
        "sExtends": "xls",
        "sFileName": "*.xls",
        "sButtonText": "Export to Excel"
      }
      ]
    }
  });
    
  $('#quick_report').dataTable({
    iDisplayLength: 50,
    bRetrieve: true,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalQtyMonth1 = 0;
      var iTotalValueMonth1 = 0;

      var iTotalQtyMonth2 = 0;
      var iTotalValueMonth2 = 0;

      var iTotalQtyMonth3 = 0;
      var iTotalValueMonth3 = 0;

      var iTotalQtyMonth4 = 0;
      var iTotalValueMonth4 = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQtyMonth1 += aaData[i][1]*1;
        iTotalValueMonth1 += parseCurrency(aaData[i][2])*1;

        iTotalQtyMonth2 += aaData[i][3]*1;
        iTotalValueMonth2 += parseCurrency(aaData[i][4])*1;

        iTotalQtyMonth3 += aaData[i][5]*1;
        iTotalValueMonth3 += parseCurrency(aaData[i][6])*1;

        iTotalQtyMonth4 += aaData[i][7]*1;
        iTotalValueMonth4 += parseCurrency(aaData[i][8])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalQtyMonth1))
      nCells[1].innerHTML = addCommas(parseInt(iTotalValueMonth1))

      nCells[2].innerHTML = addCommas(parseInt(iTotalQtyMonth2))
      nCells[3].innerHTML = addCommas(parseInt(iTotalValueMonth2))

      nCells[4].innerHTML = addCommas(parseInt(iTotalQtyMonth3))
      nCells[5].innerHTML = addCommas(parseInt(iTotalValueMonth3))

      nCells[6].innerHTML = addCommas(parseInt(iTotalQtyMonth4))
      nCells[7].innerHTML = addCommas(parseInt(iTotalValueMonth4))
    }
  });
		
  $('#customer_compare').dataTable({
    iDisplayLength: 10,
    bRetrieve: true,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalQtyJanuary = 0;
      var iTotalValueJanuary = 0;

      var iTotalQtyFebruary = 0;
      var iTotalValueFebruary = 0;

      var iTotalQtyMarch = 0;
      var iTotalValueMarch = 0;

      var iTotalQtyApril = 0;
      var iTotalValueApril = 0;

      var iTotalQtyMay = 0;
      var iTotalValueMay = 0;

      var iTotalQtyJune = 0;
      var iTotalValueJune = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQtyJanuary += parseCurrency(aaData[i][2])*1;
        iTotalValueJanuary += parseCurrency(aaData[i][3])*1;

        iTotalQtyFebruary += parseCurrency(aaData[i][4])*1;
        iTotalValueFebruary += parseCurrency(aaData[i][5])*1;

        iTotalQtyMarch += parseCurrency(aaData[i][6])*1;
        iTotalValueMarch += parseCurrency(aaData[i][7])*1;

        iTotalQtyApril += parseCurrency(aaData[i][8])*1;
        iTotalValueApril += parseCurrency(aaData[i][9])*1;

        iTotalQtyMay += parseCurrency(aaData[i][10])*1;
        iTotalValueMay += parseCurrency(aaData[i][11])*1;

        iTotalQtyJune += parseCurrency(aaData[i][12])*1;
        iTotalValueJune += parseCurrency(aaData[i][13])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[1].innerHTML = addCommas(parseInt(iTotalQtyJanuary))
      nCells[2].innerHTML = addCommas(parseInt(iTotalValueJanuary))

      nCells[3].innerHTML = addCommas(parseInt(iTotalQtyFebruary))
      nCells[4].innerHTML = addCommas(parseInt(iTotalValueFebruary))

      nCells[5].innerHTML = addCommas(parseInt(iTotalQtyMarch))
      nCells[6].innerHTML = addCommas(parseInt(iTotalValueMarch))

      nCells[7].innerHTML = addCommas(parseInt(iTotalQtyApril))
      nCells[8].innerHTML = addCommas(parseInt(iTotalValueApril))

      nCells[9].innerHTML = addCommas(parseInt(iTotalQtyMay))
      nCells[10].innerHTML = addCommas(parseInt(iTotalValueMay))

      nCells[11].innerHTML = addCommas(parseInt(iTotalQtyJune))
      nCells[12].innerHTML = addCommas(parseInt(iTotalValueJune))
    }
  });

  $('#customer_compare2').dataTable({
        
    iDisplayLength: 10,
    bRetrieve: true,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalQtyJuly = 0;
      var iTotalValueJuly = 0;

      var iTotalQtyAugust = 0;
      var iTotalValueAugust = 0;

      var iTotalQtySeptember = 0;
      var iTotalValueSeptember = 0;

      var iTotalQtyOctober = 0;
      var iTotalValueOctober = 0;

      var iTotalQtyNovember = 0;
      var iTotalValueNovember = 0;

      var iTotalQtyDecember = 0;
      var iTotalValueDecember = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQtyJuly += parseCurrency(aaData[i][2])*1;
        iTotalValueJuly += parseCurrency(aaData[i][3])*1;

        iTotalQtyAugust += parseCurrency(aaData[i][4])*1;
        iTotalValueAugust += parseCurrency(aaData[i][5])*1;

        iTotalQtySeptember += parseCurrency(aaData[i][6])*1;
        iTotalValueSeptember += parseCurrency(aaData[i][7])*1;

        iTotalQtyOctober += parseCurrency(aaData[i][8])*1;
        iTotalValueOctober += parseCurrency(aaData[i][9])*1;

        iTotalQtyNovember += parseCurrency(aaData[i][10])*1;
        iTotalValueNovember += parseCurrency(aaData[i][11])*1;

        iTotalQtyDecember += parseCurrency(aaData[i][12])*1;
        iTotalValueDecember += parseCurrency(aaData[i][13])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[1].innerHTML = addCommas(parseInt(iTotalQtyJuly))
      nCells[2].innerHTML = addCommas(parseInt(iTotalValueJuly))

      nCells[3].innerHTML = addCommas(parseInt(iTotalQtyAugust))
      nCells[4].innerHTML = addCommas(parseInt(iTotalValueAugust))

      nCells[5].innerHTML = addCommas(parseInt(iTotalQtySeptember))
      nCells[6].innerHTML = addCommas(parseInt(iTotalValueSeptember))

      nCells[7].innerHTML = addCommas(parseInt(iTotalQtyOctober))
      nCells[8].innerHTML = addCommas(parseInt(iTotalValueOctober))

      nCells[9].innerHTML = addCommas(parseInt(iTotalQtyNovember))
      nCells[10].innerHTML = addCommas(parseInt(iTotalValueNovember))

      nCells[11].innerHTML = addCommas(parseInt(iTotalQtyDecember))
      nCells[12].innerHTML = addCommas(parseInt(iTotalValueDecember))

    }
  });
		
  $('#compare_last').dataTable({
    iDisplayLength: 30,
    bRetrieve: true,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalQty2012 = 0;
      var iTotalValue2012 = 0;

      var iTotalQty2013 = 0;
      var iTotalValue2013 = 0;

      var iTotalQtyGrowth = 0;
      var iTotalValueGrowth = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQty2012 += parseCurrency(aaData[i][1])*1;
        iTotalValue2012 += parseCurrency(aaData[i][2])*1;

        iTotalQty2013 += parseCurrency(aaData[i][3])*1;
        iTotalValue2013 += parseCurrency(aaData[i][4])*1;

        iTotalQtyGrowth += parseCurrency(aaData[i][5])*1;
        iTotalValueGrowth += parseCurrency(aaData[i][6])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalQty2012))
      nCells[1].innerHTML = addCommas(parseInt(iTotalValue2012))

      nCells[2].innerHTML = addCommas(parseInt(iTotalQty2013))
      nCells[3].innerHTML = addCommas(parseInt(iTotalValue2013))

      nCells[4].innerHTML = addCommas(parseInt(iTotalQtyGrowth))
      nCells[5].innerHTML = addCommas(parseInt(iTotalValueGrowth))

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
