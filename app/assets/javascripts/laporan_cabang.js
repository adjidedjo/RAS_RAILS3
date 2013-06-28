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
    // Datepicker
    $('#from').datepicker({
        dateFormat: 'yy-mm-dd'
    }).attr('readonly','readonly');
    $('#to').datepicker({
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
        bJQueryUI: true,
        iDisplayLength: 30,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
        bRetrieve: true
    });

		$('#customer_monthly2').dataTable({
        bJQueryUI: true,
        iDisplayLength: 30,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
        bRetrieve: true
    });

		$('#customer_by_store').dataTable({
        bJQueryUI: true,
        iDisplayLength: 30,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
        bRetrieve: true
    });

		$('#group_by_size_comparison').dataTable({
        bJQueryUI: true,
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
        bJQueryUI: true,
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
        bJQueryUI: true,
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
        bJQueryUI: true,
        iDisplayLength: 30,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
        bRetrieve: true,
				"bAutoWidth": false,
        "bPaginate": false,
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

            var iTotalWeek1 = 0;
            var iTotalWeek2 = 0;
            var iTotalWeek3 = 0;
            var iTotalWeek4 = 0;
            var iTotalWeekS1 = 0;
            var iTotalWeekS2 = 0;
            var iTotalWeekS3 = 0;
            var iTotalWeekS4 = 0;
            var iTotalWeekLastMonth = 0;
            var iTotalWeekLastMonthS = 0;
            var iTotalGrowth = 0;
            var iTotalGrowthS = 0;

            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalWeek1 += parseCurrency(aaData[i][1])*1;
                iTotalWeek2 += parseCurrency(aaData[i][2])*1;
                iTotalWeek3 += parseCurrency(aaData[i][3])*1;
                iTotalWeek4 += parseCurrency(aaData[i][4])*1;
                iTotalWeekLastMonth += parseCurrency(aaData[i][5])*1;
                iTotalGrowth += parseCurrency(aaData[i][6])*1;
                iTotalWeekS1 += parseCurrency(aaData[i][7])*1;
                iTotalWeekS2 += parseCurrency(aaData[i][8])*1;
                iTotalWeekS3 += parseCurrency(aaData[i][9])*1;
                iTotalWeekS4 += parseCurrency(aaData[i][10])*1;
                iTotalWeekLastMonthS += parseCurrency(aaData[i][11])*1;
                iTotalGrowthS += parseCurrency(aaData[i][12])*1;
            }

            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = addCommas(parseInt(iTotalWeek1))
            nCells[1].innerHTML = addCommas(parseInt(iTotalWeek2))
            nCells[2].innerHTML = addCommas(parseInt(iTotalWeek3))
            nCells[3].innerHTML = addCommas(parseInt(iTotalWeek4))
            nCells[4].innerHTML = addCommas(parseInt(iTotalWeekLastMonth))
            nCells[5].innerHTML = addCommas(parseInt(iTotalGrowth))
            nCells[6].innerHTML = addCommas(parseInt(iTotalWeekS1))
            nCells[7].innerHTML = addCommas(parseInt(iTotalWeekS2))
            nCells[8].innerHTML = addCommas(parseInt(iTotalWeekS3))
            nCells[9].innerHTML = addCommas(parseInt(iTotalWeekS4))
            nCells[10].innerHTML = addCommas(parseInt(iTotalWeekLastMonthS))
            nCells[11].innerHTML = addCommas(parseInt(iTotalGrowthS))

        }
    });

		$('#weekly_report_sales_total').dataTable({
        bJQueryUI: true,
        iDisplayLength: 30,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
        bRetrieve: true,
        "bPaginate": false,
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

            var iTotalWeek1 = 0;
            var iTotalWeek2 = 0;
            var iTotalWeek3 = 0;
            var iTotalWeek4 = 0;
            var iTotalWeekLastMonth = 0;
						var iTotalGrowth = 0;
            var iTotalAkumulasiThisMonth = 0;
            var iTotalAkumulasiLastMonth = 0;
            var iTotalGrowthAkumulasi = 0;
            var iTotalTarget = 0;
            var iTotalAcv = 0;

            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalWeek1 += parseCurrency(aaData[i][1])*1;
                iTotalWeek2 += parseCurrency(aaData[i][2])*1;
                iTotalWeek3 += parseCurrency(aaData[i][3])*1;
                iTotalWeek4 += parseCurrency(aaData[i][4])*1;
                iTotalWeekLastMonth += parseCurrency(aaData[i][5])*1;
                iTotalGrowth += parseCurrency(aaData[i][6])*1;
								iTotalAkumulasiThisMonth += parseCurrency(aaData[i][7])*1;
            		iTotalAkumulasiLastMonth += parseCurrency(aaData[i][8])*1;
            		iTotalGrowthAkumulasi += parseCurrency(aaData[i][9])*1;
            		iTotalTarget += parseCurrency(aaData[i][10])*1;
            		iTotalAcv += parseCurrency(aaData[i][11])*1;
            }

            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = addCommas(parseInt(iTotalWeek1))
            nCells[1].innerHTML = addCommas(parseInt(iTotalWeek2))
            nCells[2].innerHTML = addCommas(parseInt(iTotalWeek3))
            nCells[3].innerHTML = addCommas(parseInt(iTotalWeek4))
            nCells[4].innerHTML = addCommas(parseInt(iTotalWeekLastMonth))
            nCells[5].innerHTML = addCommas(parseInt(iTotalGrowth))
						nCells[6].innerHTML = addCommas(parseInt(iTotalAkumulasiThisMonth))
            nCells[7].innerHTML = addCommas(parseInt(iTotalAkumulasiLastMonth))
            nCells[8].innerHTML = addCommas(parseInt(iTotalGrowthAkumulasi))
            nCells[9].innerHTML = addCommas(parseInt(iTotalTarget))
            nCells[10].innerHTML = addCommas(parseInt(iTotalAcv))

        }
    });

		$('#yearly_report_sales_total').dataTable({
        bJQueryUI: true,
        iDisplayLength: 30,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
        bRetrieve: true,
        "bPaginate": false,
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

            var iTotalThisYear = 0;
            var iTotalLastYear = 0;
            var iTotalGrowthYear = 0;
            var iTotalTargetYear = 0;
            var iTotalAcvYear = 0;

            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalThisYear += parseCurrency(aaData[i][1])*1;
                iTotalLastYear += parseCurrency(aaData[i][2])*1;
                iTotalGrowthYear += parseCurrency(aaData[i][3])*1;
                iTotalTargetYear += parseCurrency(aaData[i][4])*1;
                iTotalAcvYear += parseCurrency(aaData[i][5])*1;
            }

            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = addCommas(parseInt(iTotalThisYear))
            nCells[1].innerHTML = addCommas(parseInt(iTotalLastYear))
            nCells[2].innerHTML = addCommas(parseInt(iTotalGrowthYear))
            nCells[3].innerHTML = addCommas(parseInt(iTotalTargetYear))
            nCells[4].innerHTML = addCommas(parseInt(iTotalAcvYear))

        }
    });

		$('#classic_weekly_sales_report').dataTable({
        bJQueryUI: true,
        iDisplayLength: 30,
        aLengthMenu: [[10, 30, 50, 100, -1], [10, 30, 50, 100, "All"]],
        bRetrieve: true,
        "bPaginate": false,
        "fnFooterCallback": function ( nRow, aaData ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */

            var iTotalWeek1 = 0;
            var iTotalWeek2 = 0;
            var iTotalWeek3 = 0;
            var iTotalWeek4 = 0;
            var iTotalWeekLastMonth = 0;
						var iTotalGrowth = 0;

            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalWeek1 += parseCurrency(aaData[i][1])*1;
                iTotalWeek2 += parseCurrency(aaData[i][2])*1;
                iTotalWeek3 += parseCurrency(aaData[i][3])*1;
                iTotalWeek4 += parseCurrency(aaData[i][4])*1;
                iTotalWeekLastMonth += parseCurrency(aaData[i][5])*1;
                iTotalGrowth += parseCurrency(aaData[i][6])*1;
            }

            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('td');
            nCells[0].innerHTML = addCommas(parseInt(iTotalWeek1))
            nCells[1].innerHTML = addCommas(parseInt(iTotalWeek2))
            nCells[2].innerHTML = addCommas(parseInt(iTotalWeek3))
            nCells[3].innerHTML = addCommas(parseInt(iTotalWeek4))
            nCells[4].innerHTML = addCommas(parseInt(iTotalWeekLastMonth))
            nCells[5].innerHTML = addCommas(parseInt(iTotalGrowth))

        }
    });

    $('#table_year').dataTable( {
        sPaginationType: "full_numbers",
        bJQueryUI: true,
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
        bJQueryUI: true,
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
        bJQueryUI: true,
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
        bJQueryUI: true,
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
        bJQueryUI: true,
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
        bJQueryUI: true,
        bPaginate: false,
				bFilter: false
		});

    // Add a tabletool to export to pdf, excel and csv
    $('#standard_analyze').dataTable({
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
        bJQueryUI: true,
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
