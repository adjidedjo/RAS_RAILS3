class AccountingController < ApplicationController
  def check_faktur
    faktur = LaporanCabang.select('nofaktur').search_by_month_and_year(9,2014).brand(params[:brand])
    .search_by_branch(2).no_return.not_equal_with_nofaktur.order("nofaktur ASC").group('nofaktur')
      
    slice = faktur.map(&:nofaktur)
    ceui = []
    slice.each do |iceu|
      ceui << iceu[12,5].to_i
    end
    @missing_faktur = (slice.first[12,5].to_i..slice.last[12,5].to_i).to_a - ceui
    @sales_report = SalesReport.new
  end

end
