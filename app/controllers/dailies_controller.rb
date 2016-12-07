class DailiesController < ApplicationController
  def index
    brand = params[:brand].present? ? params[:brand] : ['ELITE', 'LADY', 'ROYAL', 'SERENITY'].map { |a| "\"#{a}\"" }.join(',')
    cabang = params[:branch].present? ? params[:branch] : 1
    month = params[:month].present? ? params[:month] : Date.today.month
    year = params[:year].present? ? params[:year] : Date.today.year
    item = ['KM', 'DV', 'HB', 'SA', 'SB', 'ST'].map { |a| "\"#{a}\"" }.join(',')
    @cabang =  LaporanCabang.find_by_sql("SELECT SUM(jumlah) AS jumlah, cabang_id, tanggalsj 
    FROM tblaporancabang WHERE MONTH(tanggalsj) = #{month} AND 
    YEAR(tanggalsj) = #{year} AND jenisbrgdisc IN ('#{brand}') 
    AND cabang_id = #{cabang} AND kodejenis IN (#{item}) AND bonus NOT LIKE 'BONUS' GROUP BY tanggalsj")
    
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Penjualan Brand #{params[:brand]}")
      f.xAxis(:categories => @cabang.map {|i| [i.tanggalsj.strftime('%d %B %Y')]})
      f.yAxis(:title => {
                text: 'Quantities'
              })
      f.series(:name => 'Quantity',
               :data => @cabang.map { |i| [Cabang.find(i.cabang_id).Cabang,
                                      i.jumlah] })
    
      f.chart({:defaultSeriesType => 'column'})
    end
  end

end