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
  
  $('.control_branches input[type="text"], .control_branches select').tooltipster({ 
    trigger: 'custom', // default is 'hover' which is no good here
    onlyOne: false,    // allow multiple tips to be open at a time
    position: 'right'  // display the tips to the right of the element
  });
    
  $('.control_branches').validate({
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
    rules: {
      from: {
        required: true
      },
      to: {
        required: true
      },
      category: {
        required: true
      }
    },
    highlight: function (element) {
      $(element).closest('.control-group').removeClass('success').addClass('error');
    }
  });
  
  // Datepicker
  $('#from').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#to').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#from_period').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#to_period').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#week').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#periode').datepicker({
    dateFormat: 'yy-mm-dd'
  }).attr('readonly','readonly');
  $('#periode_week').datepicker({
    dateFormat: 'dd-mm-yy'
  }).attr('readonly','readonly');

  $('#customer_monthly').dataTable({
        
    iDisplayLength: 30,
    aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
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
        iTotalQtyJanuary += parseCurrency(aaData[i][1])*1;
        iTotalValueJanuary += parseCurrency(aaData[i][2])*1;

        iTotalQtyFebruary += parseCurrency(aaData[i][3])*1;
        iTotalValueFebruary += parseCurrency(aaData[i][4])*1;

        iTotalQtyMarch += parseCurrency(aaData[i][5])*1;
        iTotalValueMarch += parseCurrency(aaData[i][6])*1;

        iTotalQtyApril += parseCurrency(aaData[i][7])*1;
        iTotalValueApril += parseCurrency(aaData[i][8])*1;

        iTotalQtyMay += parseCurrency(aaData[i][9])*1;
        iTotalValueMay += parseCurrency(aaData[i][10])*1;

        iTotalQtyJune += parseCurrency(aaData[i][11])*1;
        iTotalValueJune += parseCurrency(aaData[i][12])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalQtyJanuary))
      nCells[1].innerHTML = addCommas(parseInt(iTotalValueJanuary))

      nCells[2].innerHTML = addCommas(parseInt(iTotalQtyFebruary))
      nCells[3].innerHTML = addCommas(parseInt(iTotalValueFebruary))

      nCells[4].innerHTML = addCommas(parseInt(iTotalQtyMarch))
      nCells[5].innerHTML = addCommas(parseInt(iTotalValueMarch))

      nCells[6].innerHTML = addCommas(parseInt(iTotalQtyApril))
      nCells[7].innerHTML = addCommas(parseInt(iTotalValueApril))

      nCells[8].innerHTML = addCommas(parseInt(iTotalQtyMay))
      nCells[9].innerHTML = addCommas(parseInt(iTotalValueMay))

      nCells[10].innerHTML = addCommas(parseInt(iTotalQtyJune))
      nCells[11].innerHTML = addCommas(parseInt(iTotalValueJune))

    }
  });

  $('#customer_monthly2').dataTable({
        
    iDisplayLength: 30,
    aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
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
        iTotalQtyJuly += parseCurrency(aaData[i][1])*1;
        iTotalValueJuly += parseCurrency(aaData[i][2])*1;

        iTotalQtyAugust += parseCurrency(aaData[i][3])*1;
        iTotalValueAugust += parseCurrency(aaData[i][4])*1;

        iTotalQtySeptember += parseCurrency(aaData[i][5])*1;
        iTotalValueSeptember += parseCurrency(aaData[i][6])*1;

        iTotalQtyOctober += parseCurrency(aaData[i][7])*1;
        iTotalValueOctober += parseCurrency(aaData[i][8])*1;

        iTotalQtyNovember += parseCurrency(aaData[i][9])*1;
        iTotalValueNovember += parseCurrency(aaData[i][10])*1;

        iTotalQtyDecember += parseCurrency(aaData[i][11])*1;
        iTotalValueDecember += parseCurrency(aaData[i][12])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalQtyJuly))
      nCells[1].innerHTML = addCommas(parseInt(iTotalValueJuly))

      nCells[2].innerHTML = addCommas(parseInt(iTotalQtyAugust))
      nCells[3].innerHTML = addCommas(parseInt(iTotalValueAugust))

      nCells[4].innerHTML = addCommas(parseInt(iTotalQtySeptember))
      nCells[5].innerHTML = addCommas(parseInt(iTotalValueSeptember))

      nCells[6].innerHTML = addCommas(parseInt(iTotalQtyOctober))
      nCells[7].innerHTML = addCommas(parseInt(iTotalValueOctober))

      nCells[8].innerHTML = addCommas(parseInt(iTotalQtyNovember))
      nCells[9].innerHTML = addCommas(parseInt(iTotalValueNovember))

      nCells[10].innerHTML = addCommas(parseInt(iTotalQtyDecember))
      nCells[11].innerHTML = addCommas(parseInt(iTotalValueDecember))

    }
  });

  $('#customer_by_store').dataTable({
        
    iDisplayLength: 30,
    aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
    bRetrieve: true
  });

  $('#group_by_size_comparison').dataTable({
        
    iDisplayLength: 30,
    aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
    bRetrieve: true,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalRow1 = 0;
      var iTotalRow2 = 0;
      var iTotalRow3 = 0;
      var iTotalRow4 = 0;
      var iTotalRow5 = 0;
      var iTotalRow6 = 0;
      var iTotalRow7 = 0;
      var iTotalRow8 = 0;
      var iTotalRow9 = 0;
      var iTotalRow10 = 0;
      var iTotalRow11 = 0;
      var iTotalRow12 = 0;
      var iTotalRow13 = 0;
      var iTotalRow14 = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalRow1 += parseCurrency(aaData[i][1])*1;
        iTotalRow2 += parseCurrency(aaData[i][2])*1;
        iTotalRow3 += parseCurrency(aaData[i][3])*1;
        iTotalRow4 += parseCurrency(aaData[i][4])*1;
        iTotalRow5 += parseCurrency(aaData[i][5])*1;
        iTotalRow6 += parseCurrency(aaData[i][6])*1;
        iTotalRow7 += parseCurrency(aaData[i][7])*1;
        iTotalRow8 += parseCurrency(aaData[i][8])*1;
        iTotalRow9 += parseCurrency(aaData[i][9])*1;
        iTotalRow10 += parseCurrency(aaData[i][10])*1;
        iTotalRow11 += parseCurrency(aaData[i][11])*1;
        iTotalRow12 += parseCurrency(aaData[i][12])*1;
        iTotalRow13 += parseCurrency(aaData[i][13])*1;
        iTotalRow14 += parseCurrency(aaData[i][14])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalRow1))
      nCells[1].innerHTML = addCommas(parseInt(iTotalRow2))
      nCells[2].innerHTML = addCommas(parseInt(iTotalRow3))
      nCells[3].innerHTML = addCommas(parseInt(iTotalRow4))
      nCells[4].innerHTML = addCommas(parseInt(iTotalRow5))
      nCells[5].innerHTML = addCommas(parseInt(iTotalRow6))
      nCells[6].innerHTML = addCommas(parseInt(iTotalRow7))
      nCells[7].innerHTML = addCommas(parseInt(iTotalRow8))
      nCells[8].innerHTML = addCommas(parseInt(iTotalRow9))
      nCells[9].innerHTML = addCommas(parseInt(iTotalRow10))
      nCells[10].innerHTML = addCommas(parseInt(iTotalRow11))
      nCells[11].innerHTML = addCommas(parseInt(iTotalRow12))
      nCells[12].innerHTML = addCommas(parseInt(iTotalRow13))
      nCells[13].innerHTML = addCommas(parseInt(iTotalRow14))

    }
  });

  $('#monthly_comparison').dataTable({
    iDisplayLength: 30,
    bRetrieve: true,
    "bPaginate": false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iQtyLast = 0;
      var iQtyCurrent = 0;
      var iValueLast = 0;
      var iValueCurrent = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iQtyLast += parseCurrency(aaData[i][1])*1;
        iValueLast += parseCurrency(aaData[i][2])*1;
        iQtyCurrent += parseCurrency(aaData[i][3])*1;
        iValueCurrent += parseCurrency(aaData[i][4])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iQtyLast))
      nCells[1].innerHTML = addCommas(parseInt(iValueLast))
      nCells[2].innerHTML = addCommas(parseInt(iQtyCurrent))
      nCells[3].innerHTML = addCommas(parseInt(iValueCurrent))

      nCells[4].innerHTML = parseInt((iQtyCurrent - iQtyLast) / iQtyLast * 100) + "%"
      nCells[5].innerHTML = parseInt((iValueCurrent - iValueLast) / iValueLast * 100) + "%"

    }
  });

  $('#group_by_customer').dataTable({
        
    iDisplayLength: 30,
    aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
    bRetrieve: true,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalRow1 = 0;
      var iTotalRow2 = 0;
      var iTotalRow3 = 0;
      var iTotalRow4 = 0;
      var iTotalRow5 = 0;
      var iTotalRow6 = 0;
      var iTotalRow7 = 0;
      var iTotalRow8 = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalRow1 += parseCurrency(aaData[i][1])*1;
        iTotalRow2 += parseCurrency(aaData[i][2])*1;
        iTotalRow3 += parseCurrency(aaData[i][3])*1;
        iTotalRow4 += parseCurrency(aaData[i][4])*1;
        iTotalRow5 += parseCurrency(aaData[i][5])*1;
        iTotalRow6 += parseCurrency(aaData[i][6])*1;
        iTotalRow7 += parseCurrency(aaData[i][7])*1;
        iTotalRow8 += parseCurrency(aaData[i][8])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalRow1))
      nCells[1].innerHTML = addCommas(parseInt(iTotalRow2))
      nCells[2].innerHTML = addCommas(parseInt(iTotalRow3))
      nCells[3].innerHTML = addCommas(parseInt(iTotalRow4))
      nCells[4].innerHTML = addCommas(parseInt(iTotalRow5))
      nCells[5].innerHTML = addCommas(parseInt(iTotalRow6))
      nCells[6].innerHTML = addCommas(parseInt(iTotalRow7))
      nCells[7].innerHTML = addCommas(parseInt(iTotalRow8))

    }
  });
  $('#weekly_report_sales').dataTable({
    iDisplayLength: 30,
    "sScrollX": "100%",
    "sScrollXInner": "150%",
    "bScrollCollapse": true
  });

  $('#weekly_report_sales_total').dataTable({
    iDisplayLength: 30,
    "sScrollX": "100%",
    "sScrollXInner": "150%",
    "bScrollCollapse": true
  });

  $('#yearly_report_sales_total').dataTable({
    iDisplayLength: 30,
    "sScrollX": "100%",
    "sScrollXInner": "150%",
    "bScrollCollapse": true
  });

  $('#classic_weekly_sales_report').dataTable({
    iDisplayLength: 30,
    "sScrollX": "100%",
    "sScrollXInner": "150%",
    "bScrollCollapse": true
  });

  $('#table_year').dataTable( {
    sPaginationType: "full_numbers",
        
    iDisplayLength: 20,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */
      var iTotalLastYearMonth = 0;
      var iTotalCurrentYearMonth = 0;
      var iTotalLastYear = 0;
      var iTotalCurrentYear = 0;

      var iTotalLastWeekLastYear = 0;
      var iTotalLastWeekCurrentYear = 0;
      var iTotalThisWeekLastYear = 0;
      var iTotalThisWeekCurrentYear = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalLastYearMonth += parseCurrency(aaData[i][7])*1;
        iTotalCurrentYearMonth += parseCurrency(aaData[i][8])*1;
        iTotalLastYear += parseCurrency(aaData[i][10])*1;
        iTotalCurrentYear += parseCurrency(aaData[i][11])*1;

        iTotalLastWeekLastYear += parseCurrency(aaData[i][1])*1;
        iTotalLastWeekCurrentYear += parseCurrency(aaData[i][2])*1;
        iTotalThisWeekLastYear += parseCurrency(aaData[i][4])*1;
        iTotalThisWeekCurrentYear += parseCurrency(aaData[i][5])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalLastWeekLastYear))
      nCells[1].innerHTML = addCommas(parseInt(iTotalLastWeekCurrentYear))
      nCells[3].innerHTML = addCommas(parseInt(iTotalThisWeekLastYear))
      nCells[4].innerHTML = addCommas(parseInt(iTotalThisWeekCurrentYear))

      nCells[2].innerHTML = parseInt((iTotalLastWeekCurrentYear - iTotalLastWeekLastYear) / iTotalLastWeekLastYear * 100) + "%"
      nCells[5].innerHTML = parseInt((iTotalThisWeekCurrentYear - iTotalThisWeekLastYear) / iTotalThisWeekLastYear * 100) + "%"

      nCells[6].innerHTML = addCommas(parseInt(iTotalLastYearMonth))
      nCells[7].innerHTML = addCommas(parseInt(iTotalCurrentYearMonth))
      nCells[9].innerHTML = addCommas(parseInt(iTotalLastYear))
      nCells[10].innerHTML = addCommas(parseInt(iTotalCurrentYear))
      nCells[8].innerHTML = parseInt((iTotalCurrentYearMonth - iTotalLastYearMonth) / iTotalLastYearMonth * 100) + "%" ;
      nCells[11].innerHTML = parseInt((iTotalCurrentYear - iTotalLastYear) / iTotalLastYear * 100) + "%" ;
    },
    "fnRowCallback": function( nRow, aData, iDisplayIndex ) {

      var iTotalLastYearMonth = 0;

      for ( var i=0 ; i< aData.length ; i++ )
      {
        iTotalLastYearMonth = aData[i][2];
      }
    }
  });

  $('#group_by_cabang_2').dataTable({
    sPaginationType: "full_numbers",
        
    iDisplayLength: 30,
    aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
    bRetrieve: true,
    "bPaginate": false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */


      var iTotalQtyJogyakarta = 0;
      var iTotalValueJogyakarta = 0;
      var iTotalQtyPalembang = 0;
      var iTotalValuePalembang = 0;
      var iTotalQtyLampung = 0;
      var iTotalValueLampung = 0;
      var iTotalQtyMakasar = 0;
      var iTotalValueMakasar = 0;
      var iTotalQtyPekanbaru = 0;
      var iTotalValuePekanbaru = 0;
      var iTotalQtyJember = 0;
      var iTotalValueJember = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {

        iTotalQtyJogyakarta += parseCurrency(aaData[i][1])*1;
        iTotalValueJogyakarta += parseCurrency(aaData[i][2])*1;
        iTotalQtyPalembang += parseCurrency(aaData[i][3])*1;
        iTotalValuePalembang += parseCurrency(aaData[i][4])*1;
        iTotalQtyLampung += parseCurrency(aaData[i][5])*1;
        iTotalValueLampung += parseCurrency(aaData[i][6])*1;
        iTotalQtyMakasar += parseCurrency(aaData[i][7])*1;
        iTotalValueMakasar += parseCurrency(aaData[i][8])*1;
        iTotalQtyPekanbaru += parseCurrency(aaData[i][9])*1;
        iTotalValuePekanbaru += parseCurrency(aaData[i][10])*1;
        iTotalQtyJember += parseCurrency(aaData[i][11])*1;
        iTotalValueJember += parseCurrency(aaData[i][12])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');


      nCells[0].innerHTML = addCommas(parseInt(iTotalQtyJogyakarta))
      nCells[1].innerHTML = addCommas(parseInt(iTotalValueJogyakarta))

      nCells[2].innerHTML = addCommas(parseInt(iTotalQtyPalembang))
      nCells[3].innerHTML = addCommas(parseInt(iTotalValuePalembang))

      nCells[4].innerHTML = addCommas(parseInt(iTotalQtyLampung))
      nCells[5].innerHTML = addCommas(parseInt(iTotalValueLampung))

      nCells[6].innerHTML = addCommas(parseInt(iTotalQtyMakasar))
      nCells[7].innerHTML = addCommas(parseInt(iTotalValueMakasar))

      nCells[8].innerHTML = addCommas(parseInt(iTotalQtyPekanbaru))
      nCells[9].innerHTML = addCommas(parseInt(iTotalValuePekanbaru))

      nCells[10].innerHTML = addCommas(parseInt(iTotalQtyJember))
      nCells[11].innerHTML = addCommas(parseInt(iTotalValueJember))

    }
  });

  $('#group_by_cabang').dataTable({
        
    iDisplayLength: 30,
    aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
    bRetrieve: true,
    "bPaginate": false,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalQtyBandung = 0;
      var iTotalValueBandung = 0;
      var iTotalQtyNarogong = 0;
      var iTotalValueNarogong = 0;

      var iTotalQtyBali = 0;
      var iTotalValueBali = 0;
      var iTotalQtyMedan = 0;
      var iTotalValueMedan = 0;
      var iTotalQtySurabaya = 0;
      var iTotalValueSurabaya = 0;
      var iTotalQtySemarang = 0;
      var iTotalValueSemarang = 0;
      var iTotalQtyCirebon = 0;
      var iTotalValueCirebon = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalQtyBandung += parseCurrency(aaData[i][1])*1;
        iTotalValueBandung += parseCurrency(aaData[i][2])*1;
        iTotalQtyNarogong += parseCurrency(aaData[i][3])*1;
        iTotalValueNarogong += parseCurrency(aaData[i][4])*1;
        iTotalQtyBali += parseCurrency(aaData[i][5])*1;
        iTotalValueBali += parseCurrency(aaData[i][6])*1;
        iTotalQtyMedan += parseCurrency(aaData[i][7])*1;
        iTotalValueMedan += parseCurrency(aaData[i][8])*1;
        iTotalQtySurabaya += parseCurrency(aaData[i][9])*1;
        iTotalValueSurabaya += parseCurrency(aaData[i][10])*1;
        iTotalQtySemarang += parseCurrency(aaData[i][11])*1;
        iTotalValueSemarang += parseCurrency(aaData[i][12])*1;
        iTotalQtyCirebon += parseCurrency(aaData[i][13])*1;
        iTotalValueCirebon += parseCurrency(aaData[i][14])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalQtyBandung))
      nCells[1].innerHTML = addCommas(parseInt(iTotalValueBandung))

      nCells[2].innerHTML = addCommas(parseInt(iTotalQtyNarogong))
      nCells[3].innerHTML = addCommas(parseInt(iTotalValueNarogong))

      nCells[4].innerHTML = addCommas(parseInt(iTotalQtyBali))
      nCells[5].innerHTML = addCommas(parseInt(iTotalValueBali))

      nCells[6].innerHTML = addCommas(parseInt(iTotalQtyMedan))
      nCells[7].innerHTML = addCommas(parseInt(iTotalValueMedan))

      nCells[8].innerHTML = addCommas(parseInt(iTotalQtySurabaya))
      nCells[9].innerHTML = addCommas(parseInt(iTotalValueSurabaya))

      nCells[10].innerHTML = addCommas(parseInt(iTotalQtySemarang))
      nCells[11].innerHTML = addCommas(parseInt(iTotalValueSemarang))

      nCells[12].innerHTML = addCommas(parseInt(iTotalQtyCirebon))
      nCells[13].innerHTML = addCommas(parseInt(iTotalValueCirebon))

    }
  });

  $('#table_year_elite').dataTable({
    sPaginationType: "full_numbers",
        
    iDisplayLength: 20,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

      var iTotalLastWeekLastYear = 0;
      var iTotalLastWeekCurrentYear = 0;
      var iTotalThisWeekLastYear = 0;
      var iTotalThisWeekCurrentYear = 0;

      var iTotalLastWeekLastYear2 = 0;
      var iTotalLastWeekCurrentYear2 = 0;
      var iTotalThisWeekLastYear2 = 0;
      var iTotalThisWeekCurrentYear2 = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalLastWeekLastYear += parseCurrency(aaData[i][1])*1;
        iTotalLastWeekCurrentYear += parseCurrency(aaData[i][2])*1;
        iTotalThisWeekLastYear += parseCurrency(aaData[i][4])*1;
        iTotalThisWeekCurrentYear += parseCurrency(aaData[i][5])*1;

        iTotalLastWeekLastYear2 += parseCurrency(aaData[i][7])*1;
        iTotalLastWeekCurrentYear2 += parseCurrency(aaData[i][8])*1;
        iTotalThisWeekLastYear2 += parseCurrency(aaData[i][10])*1;
        iTotalThisWeekCurrentYear2 += parseCurrency(aaData[i][11])*1;
      }

      /* Modify the footer row to match what we want */
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalLastWeekLastYear))
      nCells[1].innerHTML = addCommas(parseInt(iTotalLastWeekCurrentYear))
      nCells[3].innerHTML = addCommas(parseInt(iTotalThisWeekLastYear))
      nCells[4].innerHTML = addCommas(parseInt(iTotalThisWeekCurrentYear))

      nCells[2].innerHTML = parseInt((iTotalLastWeekCurrentYear - iTotalLastWeekLastYear) / iTotalLastWeekLastYear * 100) + "%"
      nCells[5].innerHTML = parseInt((iTotalThisWeekCurrentYear - iTotalThisWeekLastYear) / iTotalThisWeekLastYear * 100) + "%"

      nCells[6].innerHTML = addCommas(parseInt(iTotalLastWeekLastYear2))
      nCells[7].innerHTML = addCommas(parseInt(iTotalLastWeekCurrentYear2))
      nCells[9].innerHTML = addCommas(parseInt(iTotalThisWeekLastYear2))
      nCells[10].innerHTML = addCommas(parseInt(iTotalThisWeekCurrentYear2))

      nCells[8].innerHTML = parseInt((iTotalLastWeekCurrentYear2 - iTotalLastWeekLastYear2) / iTotalLastWeekLastYear2 * 100) + "%"
      nCells[11].innerHTML = parseInt((iTotalThisWeekCurrentYear2 - iTotalThisWeekLastYear2) / iTotalThisWeekLastYear2 * 100) + "%"

    }
  });
  $('#table_year_elite_month_and_year').dataTable({
    sPaginationType: "full_numbers",
        
    iDisplayLength: 20,
    "fnFooterCallback": function ( nRow, aaData ) {
      /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */
      var iTotalLastYearMonth = 0;
      var iTotalCurrentYearMonth = 0;
      var iTotalLastYear = 0;
      var iTotalCurrentYear = 0;
      var iTotalTargetMonth = 0;
      var iTotalTargetYear = 0;

      for ( var i=0 ; i<aaData.length ; i++ )
      {
        iTotalLastYearMonth += parseCurrency(aaData[i][1])*1;
        iTotalCurrentYearMonth += parseCurrency(aaData[i][2])*1;
        iTotalLastYear += parseCurrency(aaData[i][4])*1;
        iTotalCurrentYear += parseCurrency(aaData[i][5])*1;
        iTotalTargetMonth += parseCurrency(aaData[i][7])*1;
        iTotalTargetYear += parseCurrency(aaData[i][9])*1;

      }
      var nCells = nRow.getElementsByTagName('td');
      nCells[0].innerHTML = addCommas(parseInt(iTotalLastYearMonth))
      nCells[1].innerHTML = addCommas(parseInt(iTotalCurrentYearMonth))
      nCells[3].innerHTML = addCommas(parseInt(iTotalLastYear))
      nCells[4].innerHTML = addCommas(parseInt(iTotalCurrentYear))
      nCells[2].innerHTML = parseInt((iTotalCurrentYearMonth - iTotalLastYearMonth) / iTotalLastYearMonth * 100) + "%" ;
      nCells[5].innerHTML = parseInt((iTotalCurrentYear - iTotalLastYear) / iTotalLastYear * 100) + "%" ;
      nCells[6].innerHTML = addCommas(parseInt(iTotalTargetMonth))
      nCells[8].innerHTML = addCommas(parseInt(iTotalTargetYear))

    }
  });

  $('#group_by_cabang_total').dataTable({
        
    bPaginate: false,
    bFilter: false
  });

  // Add a tabletool to export to pdf, excel and csv
  $('#standard_analyze').dataTable({
    iDisplayLength: 50,
    bRetrieve: true
  });

  $("#laporancabang").css("width","100%")
  // Add a tabletool to export to pdf, excel and csv
  $('#laporancabang').dataTable({
    "sScrollX": "100%",
    "sScrollXInner": "110%",
    "bScrollCollapse": true,
    iDisplayLength: -1,
    sDom: '<"H"Tfrl>t<"F"ip>',
    bRetrieve: true,
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
  }).columnFilter({
    sPlaceHolder: "head:before",
    aoColumns: [
    null,
    null,
    null,
    null,
    null,
    {
      sSelector: "#customer",
      type: "text"
    },
    {
      sSelector: "#market",
      type: "text"
    },
    null,
    null,
    {
      sSelector: "#kodebrg",
      type: "text"
    },
    {
      sSelector: "#qty",
      type: "text"
    }
    ]
  });

  $('#table_control_branch').dataTable({
    bFilter: false, 
    bInfo: false,
    bPaginate: false,
    autoWidth: false,
    "scrollX": true
  });
  
  $('#table_control_branch2').dataTable({
    bFilter: false, 
    bInfo: false,
    bPaginate: false,
    autoWidth: false,
    "scrollX": true
  });
  $('#table_total').dataTable({
    bFilter: false, 
    bInfo: false,
    bPaginate: false,
    autoWidth: false,
    bJQueryUI: true,
    iDisplayLength: -1
  });
  $('#table_total2').dataTable({
    bFilter: false, 
    bInfo: false,
    bPaginate: false,
    bJQueryUI: true,
    iDisplayLength: -1
  });
  $('#table_grand_total').dataTable({
    bFilter: false, 
    bInfo: false,
    bPaginate: false,
    autoWidth: false,
    iDisplayLength: -1
  });
  $('#table_grand_total2').dataTable({
    bFilter: false, 
    bInfo: false,
    bPaginate: false,
    iDisplayLength: -1
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
