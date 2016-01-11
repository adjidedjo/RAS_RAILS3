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

  def currency(a)
    ActionController::Base.helpers.number_to_currency(a,  :precision => 0, :unit => "", :delimiter => ".")
  end

  def date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end

  def depositbg
    @result = []
    @deposit = []
    brands= params[:brand_depositbg]
    branch = params[:branch_depositbg]
    if brands && branch
      @branch = Cabang.find(branch).Cabang
      @dealer = "101265"
      months = (params[:from].to_date..params[:to].to_date).map{|a| [a.month, a.year]}.uniq
      brands.each do |br|
        # Deposit DO
        deposit = JdeEnterDraft.where("ryrref like ? and ryan8 like ? and rydgj between ? and ?", "DO #{br.upcase}%", @dealer, date_to_julian(params[:from].to_date), date_to_julian(params[:to].to_date))
        deposit.each do |dp|
          @deposit << {
            bulan: "DEPOSIT BG ID PAYMENT"+" "+dp.rypyid.to_i.to_s,
            bank: dp.ryexr,
            giro: dp.rycknu,
            tanggal: "-",
            penjualan: "-",
            pembayaran: currency(dp.ryckam.to_i)
          }
        end
        @result = @deposit
        months.each do |mo|
          faktur = "FK"+br+"-"+branch+"-"+mo.last.to_s[2,3]+(sprintf '%02d', mo.first.to_s)
          # Penjualan
          @result << {
            bulan: "REALISASI PENJUALAN"+" "+Date::MONTHNAMES[mo.first].upcase+" "+mo.last.to_s,
            bank: "-",
            giro: "-",
            tanggal: "-",
            penjualan: currency(JdeInvoiceProcessing.where("rpan8 like ? and rprmr1 like ?", @dealer,"#{faktur}%").sum(:rpag).to_i),
            pembayaran: "-"
          }
        end
      end
    end
  end

  def depositbg_process
  end
end
