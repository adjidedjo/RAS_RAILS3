$(document).ready(function(){
  $('#sales_cabang_per_brand').dataTable({
    bFilter: false,
    bInfo: false,
    bPaginate: false,
    bJQueryUI: true,
    iDisplayLength: -1,
    bSort: false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
               * Calculate the total market share for all browsers in this table (ie inc. outside
               * the pagination)
               */

      for ( var i = 0; i < 50; i++ ) {
        var iTotalQty1 = 0;
        var iTotalVal2 = 0;
        var iTotalQty3 = 0;
        var iTotalVal4 = 0;
        var iTotalQty5 = 0;
        var iTotalVal6 = 0;
        var iTotalQty7 = 0;
        var iTotalVal8 = 0;
        var iTotalQty9 = 0;
        var iTotalVal10 = 0;
        var iTotalQty11 = 0;
        var iTotalVal12 = 0;
        var iTotalQty13 = 0;
        var iTotalVal14 = 0;
      }

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQty1 += parseCurrency(aaData[i][1])*1;
        iTotalVal2 += parseCurrency(aaData[i][2])*1;
        iTotalQty3 += parseCurrency(aaData[i][3])*1;
        iTotalVal4 += parseCurrency(aaData[i][4])*1;
        iTotalQty5 += parseCurrency(aaData[i][5])*1;
        iTotalVal6 += parseCurrency(aaData[i][6])*1;
        iTotalQty7 += parseCurrency(aaData[i][7])*1;
        iTotalVal8 += parseCurrency(aaData[i][8])*1;
        iTotalQty9 += parseCurrency(aaData[i][9])*1;
        iTotalVal10 += parseCurrency(aaData[i][10])*1;
        iTotalQty11 += parseCurrency(aaData[i][11])*1;
        iTotalVal12 += parseCurrency(aaData[i][12])*1;
        iTotalQty13 += parseCurrency(aaData[i][13])*1;
        iTotalVal14 += parseCurrency(aaData[i][14])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalQty1))
      nCells[1].innerHTML = addCommas(parseInt(iTotalVal2))
      nCells[2].innerHTML = addCommas(parseInt(iTotalQty3))
      nCells[3].innerHTML = addCommas(parseInt(iTotalVal4))
      nCells[4].innerHTML = addCommas(parseInt(iTotalQty5))
      nCells[5].innerHTML = addCommas(parseInt(iTotalVal6))
      nCells[6].innerHTML = addCommas(parseInt(iTotalQty7))
      nCells[7].innerHTML = addCommas(parseInt(iTotalVal8))
      nCells[8].innerHTML = addCommas(parseInt(iTotalQty9))
      nCells[9].innerHTML = addCommas(parseInt(iTotalVal10))
      nCells[10].innerHTML = addCommas(parseInt(iTotalQty11))
      nCells[11].innerHTML = addCommas(parseInt(iTotalVal12))
      nCells[12].innerHTML = addCommas(parseInt(iTotalQty13))
      nCells[13].innerHTML = addCommas(parseInt(iTotalVal14))

    }
  });

  $('#cabang_scp').multiselect({
    numberDisplayed: 1,
    maxHeight: 200
  });
  $('#brand_scb').multiselect({
    numberDisplayed: 1,
    maxHeight: 200
  });
  $('#branch').multiselect({
    numberDisplayed: 1,
    maxHeight: 200
  });
  $('#brand').multiselect({
    numberDisplayed: 1
  });
  $('#artikel').multiselect({
    maxHeight: 200,
    numberDisplayed: 1,
    enableFiltering: true,
    enableCaseInsensitiveFiltering: true
  });
  $('#produk').multiselect({
    maxHeight: 200,
    numberDisplayed: 1,
    enableFiltering: true,
    enableCaseInsensitiveFiltering: true
  });
  $('#kain').multiselect({
    maxHeight: 200,
    numberDisplayed: 1,
    enableFiltering: true,
    enableCaseInsensitiveFiltering: true
  });
  $('#lebar').multiselect({
    maxHeight: 200,
    numberDisplayed: 1
  });

  $('#search_by_salesman').dataTable({
    iDisplayLength: 50,
    bRetrieve: true,
    bAutoWidth: false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
               * Calculate the total market share for all browsers in this table (ie inc. outside
               * the pagination)
               */
      var iTotalQty = 0;
      var iTotalVal = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQty += parseCurrency(aaData[i][5])*1;
        iTotalVal += parseCurrency(aaData[i][6])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[4].innerHTML = addCommas(parseInt(iTotalQty))
      nCells[5].innerHTML = addCommas(parseInt(iTotalVal))

    }
  });

  $('#search_by_customer').dataTable({
    iDisplayLength: 50,
    bRetrieve: true,
    bAutoWidth: false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
               * Calculate the total market share for all browsers in this table (ie inc. outside
               * the pagination)
               */
      var iTotalQty = 0;
      var iTotalVal = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQty += parseCurrency(aaData[i][4])*1;
        iTotalVal += parseCurrency(aaData[i][5])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[3].innerHTML = addCommas(parseInt(iTotalQty))
      nCells[4].innerHTML = addCommas(parseInt(iTotalVal))

    }
  });

  $('#search_by_ukuran').dataTable({
    iDisplayLength: 50,
    bRetrieve: true,
    bAutoWidth: false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
               * Calculate the total market share for all browsers in this table (ie inc. outside
               * the pagination)
               */
      var iTotalQty = 0;
      var iTotalVal = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQty += parseCurrency(aaData[i][7])*1;
        iTotalVal += parseCurrency(aaData[i][8])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[6].innerHTML = addCommas(parseInt(iTotalQty))
      nCells[7].innerHTML = addCommas(parseInt(iTotalVal))

    }
  });

  $('#search_by_kain').dataTable({
    iDisplayLength: 50,
    bRetrieve: true,
    bAutoWidth: false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
               * Calculate the total market share for all browsers in this table (ie inc. outside
               * the pagination)
               */
      var iTotalQty = 0;
      var iTotalVal = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQty += parseCurrency(aaData[i][5])*1;
        iTotalVal += parseCurrency(aaData[i][6])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[4].innerHTML = addCommas(parseInt(iTotalQty))
      nCells[5].innerHTML = addCommas(parseInt(iTotalVal))

    }
  });

  $('#search_by_artikel').dataTable({
    iDisplayLength: 50,
    bRetrieve: true,
    bAutoWidth: false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
               * Calculate the total market share for all browsers in this table (ie inc. outside
               * the pagination)
               */
      var iTotalQty = 0;
      var iTotalVal = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQty += parseCurrency(aaData[i][4])*1;
        iTotalVal += parseCurrency(aaData[i][5])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[3].innerHTML = addCommas(parseInt(iTotalQty))
      nCells[4].innerHTML = addCommas(parseInt(iTotalVal))

    }
  });

  $('#search_by_type').dataTable({
    iDisplayLength: 50,
    bRetrieve: true,
    bAutoWidth: false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
               * Calculate the total market share for all browsers in this table (ie inc. outside
               * the pagination)
               */
      var iTotalQty = 0;
      var iTotalVal = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQty += parseCurrency(aaData[i][3])*1;
        iTotalVal += parseCurrency(aaData[i][4])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[2].innerHTML = addCommas(parseInt(iTotalQty))
      nCells[3].innerHTML = addCommas(parseInt(iTotalVal))

    }
  });

  $('#search_by_brand').dataTable({
    iDisplayLength: 50,
    bRetrieve: true,
    bAutoWidth: false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
               * Calculate the total market share for all browsers in this table (ie inc. outside
               * the pagination)
               */
      var iTotalQty = 0;
      var iTotalVal = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQty += parseCurrency(aaData[i][2])*1;
        iTotalVal += parseCurrency(aaData[i][3])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[1].innerHTML = addCommas(parseInt(iTotalQty))
      nCells[2].innerHTML = addCommas(parseInt(iTotalVal))

    }
  });

  $('.search_main input[type="text"], .search_main input[type="radio"]').tooltipster({
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });

  $('.search_main').validate({
    errorPlacement: function (error, element) {

      var lastError = $(element).data('lastError'),
      newError = $(error).text();

      $(element).data('lastError', newError);

      if(newError !== '' && newError !== lastError){
        $(element).tooltipster('content', newError);
        $(element).tooltipster('show');
      }
    },
    success: function (label, element) {
      $(element).tooltipster('hide');
      $(element).closest('.control-group').removeClass('error').addClass('success');
    },
    highlight: function (element) {
      $(element).closest('.control-group').removeClass('success').addClass('error');
    },
    rules: {
      from: {
        required: true
      },
      to: {
        required: true
      },
      sales: {
        required: true
      }
    }
  });

  $('.search_sales input[type="text"], .search_sales input[type="radio"]').tooltipster({
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });

  $('.search_sales').validate({
    errorPlacement: function (error, element) {

      var lastError = $(element).data('lastError'),
      newError = $(error).text();

      $(element).data('lastError', newError);

      if(newError !== '' && newError !== lastError){
        $(element).tooltipster('content', newError);
        $(element).tooltipster('show');
      }
    },
    success: function (label, element) {
      $(element).tooltipster('hide');
      $(element).closest('.control-group').removeClass('error').addClass('success');
    },
    highlight: function (element) {
      $(element).closest('.control-group').removeClass('success').addClass('error');
    },
    rules: {
      from: {
        required: true
      },
      to: {
        required: true
      },
      sales: {
        required: true
      }
    }
  });

  $('.quick_view_month input[type="checkbox"]').tooltipster({
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });

  $('.quick_view_month').validate({
    errorPlacement: function (error, element) {

      var lastError = $(element).data('lastError'),
      newError = $(error).text();

      $(element).data('lastError', newError);

      if(newError !== '' && newError !== lastError){
        $(element).tooltipster('content', newError);
        $(element).tooltipster('show');
      }
    },
    success: function (label, element) {
      $(element).tooltipster('hide');
      $(element).closest('.control-group').removeClass('error').addClass('success');
    },
    highlight: function (element) {
      $(element).closest('.control-group').removeClass('success').addClass('error');
    },
    rules: {
      "quick_view_brand[]": {
        required: true
      }
    },
    messages:{
      "quick_view_brand[]":{
        required: "Pilih Minimal 1 Merk"
      }
    }
  });

  $('.quick_view input[type="radio"]').tooltipster({
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });

  $('.quick_view').validate({
    errorPlacement: function (error, element) {

      var lastError = $(element).data('lastError'),
      newError = $(error).text();

      $(element).data('lastError', newError);

      if(newError !== '' && newError !== lastError){
        $(element).tooltipster('content', newError);
        $(element).tooltipster('show');
      }
    },
    success: function (label, element) {
      $(element).tooltipster('hide');
      $(element).closest('.control-group').removeClass('error').addClass('success');
    },
    highlight: function (element) {
      $(element).closest('.control-group').removeClass('success').addClass('error');
    },
    rules: {
      quick_view: {
        required: true
      }
    },
    messages:{
      quick_view:{
        required: "Pilih Tipe"
      }
    }
  });

  for ( var i = 0; i < 50; i++ ) {
    $('#table_total_' + i).dataTable({
      bFilter: false,
      bInfo: false,
      bPaginate: false,
      bJQueryUI: true,
      iDisplayLength: -1,
      bSort: false,
      "fnFooterCallback": function ( nRow, aaData ) {
        /*
               * Calculate the total market share for all browsers in this table (ie inc. outside
               * the pagination)
               */
        var iTotalQtyElite = 0;
        var iTotalValElite = 0;
        var iTotalQtyLady = 0;
        var iTotalValLady = 0;
        var iTotalQtyRoyal = 0;
        var iTotalValRoyal = 0;
        var iTotalQtySer = 0;
        var iTotalValSer = 0;

        for ( var i=0 ; i<aaData.length ; i++ )
        {
          iTotalQtyElite += parseCurrency(aaData[i][1])*1;
          iTotalValElite += parseCurrency(aaData[i][2])*1;
          iTotalQtyLady += parseCurrency(aaData[i][3])*1;
          iTotalValLady += parseCurrency(aaData[i][4])*1;
          iTotalQtyRoyal += parseCurrency(aaData[i][5])*1;
          iTotalValRoyal += parseCurrency(aaData[i][6])*1;
          iTotalQtySer += parseCurrency(aaData[i][7])*1;
          iTotalValSer += parseCurrency(aaData[i][8])*1;
        }

        /* Modify the footer row to match what we want */
        var nCells = nRow.getElementsByTagName('td');
        nCells[0].innerHTML = addCommas(parseInt(iTotalQtyElite))
        nCells[1].innerHTML = addCommas(parseInt(iTotalValElite))
        nCells[2].innerHTML = addCommas(parseInt(iTotalQtyLady))
        nCells[3].innerHTML = addCommas(parseInt(iTotalValLady))
        nCells[4].innerHTML = addCommas(parseInt(iTotalQtyRoyal))
        nCells[5].innerHTML = addCommas(parseInt(iTotalValRoyal))
        nCells[6].innerHTML = addCommas(parseInt(iTotalQtySer))
        nCells[7].innerHTML = addCommas(parseInt(iTotalValSer))

      }
    });
  }

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
    iDisplayLength: -1,
    "bFilter" : false,
    "bLengthChange": false,
    bRetrieve: true,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalQtyMonth1 = 0;
      var iTotalValueMonth1 = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQtyMonth1 += parseCurrency(aaData[i][1])*1;
        iTotalValueMonth1 += parseCurrency(aaData[i][2])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalQtyMonth1))
      nCells[1].innerHTML = addCommas(parseInt(iTotalValueMonth1))
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
