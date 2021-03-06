class ReportsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => :summary_of_sales

  def sales_cabang_per_toko_per_produk
    sales_cabang_per_brand
  end

  def sales_cabang_per_toko
    sales_cabang_per_brand
  end

  def sales_cabang_per_customer_per_brand_by_year
    sales_cabang_per_produk_per_brand_by_year
    params[:cabang].nil? ? 2 : params[:cabang]
    @customer = Customer.customer(params[:customer_scp]).search_by_branch(params[:cabang_scp]).customer_channel(params[:customer_channel]).customer_group(params[:customer_group])
  end

  def sales_cabang_per_produk_per_brand
    sales_cabang_per_brand
  end

  def sales_cabang_per_produk_per_brand_by_year
    if params[:year].present?
      @date = params[:year].to_date
      @years = []
      (-2..2).each do |m|
        @years << [@date.prev_year(m).strftime("%Y"), @date.prev_year(m)]
      end
    end
  end

  def sales_cabang_per_cabang_per_produk_by_year
    sales_cabang_per_produk_per_brand_by_year
  end

  def sales_cabang_per_brand
    if params[:month].present?
      @date = params[:month].to_date
      @months = []
      (-5..5).each do |m|
        @months << [@date.prev_month(m).strftime("%b %Y"), @date.prev_month(m)]
      end
    end
  end

  def search_by_salesman
    from_m = params[:from].to_date.month
    to_m = params[:to].to_date.month
    from_y = params[:from].to_date.year
    to_y = params[:to].to_date.year
    @search_by_salesman = SalesSalesman.select("*, sum(qty) as sum_jumlah, sum(val) as sum_val").between_date_sales(from_m, to_m, from_y, to_y)
    .brand(params[:brand]).search_by_branch(params[:branch]).search_by_type(params[:produk])
    .group("cabang_id, merk, produk, customer, sales")

    if params[:format] == "xls"
      @search_by_customer = LaporanCabang.between_date_sales(params[:from], params[:to])
      .brand(params[:brand]).search_by_type(params[:produk]).search_by_branch(params[:branch])
    end

    respond_to do |format|
      format.html
      format.xls
      format.xml
    end
  end

  def search_by_customer
    from_m = params[:from].to_date.month
    to_m = params[:to].to_date.month
    from_y = params[:from].to_date.year
    to_y = params[:to].to_date.year
    @search_by_customer = SalesCustomer.select("*, sum(qty) as sum_jumlah, sum(val) as sum_val").between_date_sales(from_m, to_m, from_y, to_y)
    .brand(params[:brand]).search_by_branch(params[:branch]).search_by_type(params[:produk])
    .group("cabang_id, merk, produk, customer")

    if params[:format] == "xls"
      @search_by_customer = LaporanCabang.between_date_sales(params[:from], params[:to])
      .brand(params[:brand]).search_by_type(params[:produk]).search_by_branch(params[:branch])
    end

    respond_to do |format|
      format.html
      format.xls
      format.xml
    end
  end

  def search_by_ukuran
    from_d = params[:from].to_date.day
    to_d = params[:to].to_date.day
    from_m = params[:from].to_date.month
    to_m = params[:to].to_date.month
    from_y = params[:from].to_date.year
    to_y = params[:to].to_date.year
    @artikel = Artikel.group("Produk")
    @kain = Kain.group("NamaKain")
    @search_by_ukuran = SalesSize.select("*, sum(qty) as sum_jumlah, sum(val) as sum_val").between_date_sales(from_m, to_m, from_y, to_y).between_day(from_d, to_d)
    .brand(params[:brand]).search_by_branch(params[:branch]).search_by_type(params[:produk]).lebar(params[:lebar])
    .artikel(params[:artikel]).fabric(params[:kain]).group("cabang_id, merk, produk, artikel, kain, ukuran")

    if params[:format] == "xls" || params[:format] == "csv"
      @search_by_ukuran = LaporanCabang.between_date_sales(params[:from], params[:to])
      .brand(params[:brand]).type(params[:produk]).search_by_branch(params[:branch])
      .search_by_namaarticle(params[:artikel]).namafabric(params[:kain])
      .size_st(params[:ukuran]).lebar(params[:lebar]).order(:tanggalsj)
    end

    respond_to do |format|
      format.html
      format.xls
      format.xml
      format.csv do
        @search_by_ukuran.each do |aa|
          send_data aa.class.to_csv
        end
      end
    end
  end

  def search_by_kain
    from_m = params[:from].to_date.month
    to_m = params[:to].to_date.month
    from_y = params[:from].to_date.year
    to_y = params[:to].to_date.year
    @artikel = Artikel.group("Produk")
    @kain = Kain.group("NamaKain")
    @search_by_kain = SalesFabric.select("*, sum(qty) as sum_jumlah, sum(val) as sum_val").between_date_sales(from_m, to_m, from_y, to_y)
    .brand(params[:brand]).search_by_branch(params[:branch]).search_by_type(params[:produk])
    .artikel(params[:artikel]).fabric(params[:kain]).group("cabang_id, merk, produk, artikel, kain")

    if params[:format] == "xls"
      @search_by_kain = LaporanCabang.between_date_sales(params[:from], params[:to])
      .brand(params[:brand]).search_by_type(params[:produk]).search_by_branch(params[:branch])
      .search_by_type(params[:produk]).search_by_namaarticle(params[:artikel]).namafabric(params[:kain])
    end

    respond_to do |format|
      format.html
      format.xls
      format.xml
    end
  end

  def search_by_artikel
    from_m = params[:from].to_date.month
    to_m = params[:to].to_date.month
    from_y = params[:from].to_date.year
    to_y = params[:to].to_date.year
    @artikel = Artikel.group("Produk")
    @search_by_artikel = SalesArticle.select("*, sum(qty) as sum_jumlah, sum(val) as sum_val").between_date_sales(from_m, to_m, from_y, to_y)
    .brand(params[:brand]).search_by_branch(params[:branch]).search_by_type(params[:produk])
    .artikel(params[:artikel]).group("cabang_id, merk, produk, artikel")

    if params[:format] == "xls"
      @search_by_artikel = LaporanCabang.between_date_sales(params[:from], params[:to])
      .brand(params[:brand]).search_by_type(params[:produk]).search_by_branch(params[:branch])
      .search_by_type(params[:produk]).search_by_namaarticle(params[:artikel])
    end

    respond_to do |format|
      format.html
      format.xls
      format.xml
    end
  end

  def search_by_type
    from_m = params[:from].to_date.month
    to_m = params[:to].to_date.month
    from_y = params[:from].to_date.year
    to_y = params[:to].to_date.year
    @search_by_type = SalesProduct.select("*, sum(qty) as sum_jumlah, sum(val) as sum_val").between_date_sales(from_m, to_m, from_y, to_y)
    .brand(params[:brand]).search_by_branch(params[:branch]).search_by_type(params[:produk]).group("cabang_id, merk, produk")

    if params[:format] == "xls"
      @search_by_type = LaporanCabang.between_date_sales(params[:from], params[:to]).brand(params[:brand]).search_by_type(params[:produk]).search_by_branch(params[:branch])
    end

    respond_to do |format|
      format.html
      format.xls
      format.xml
    end
  end

  def search_by_brand
    from_m = params[:from].to_date.month
    to_m = params[:to].to_date.month
    from_y = params[:from].to_date.year
    to_y = params[:to].to_date.year
    @search_by_brand = SalesBrand.select("*, sum(qty) as sum_jumlah, sum(val) as sum_val")
    .between_date_sales(from_m, to_m, from_y, to_y).brand(params[:brand]).search_by_branch(params[:branch])
    .group("cabang_id, merk")

    if params[:format] == "xls"
      @search_by_brand = LaporanCabang.between_date_sales(params[:from], params[:to]).brand(params[:brand]).search_by_branch(params[:branch])
    end

    respond_to do |format|
      format.html
      format.xls
      format.xml
    end
  end

  def search_main
    if params[:from].present? && params[:to].present?
      redirect_to reports_search_by_brand_path(from: params[:from], to: params[:to], branch: params[:branch], brand: params[:brand]) if params[:sales] == 'merk'
      redirect_to reports_search_by_type_path(from: params[:from], to: params[:to], branch: params[:branch], brand: params[:brand]) if params[:sales] == 'tipe'
      redirect_to reports_search_by_artikel_path(from: params[:from], to: params[:to], branch: params[:branch], brand: params[:brand]) if params[:sales] == 'artikel'
      redirect_to reports_search_by_kain_path(from: params[:from], to: params[:to], branch: params[:branch], brand: params[:brand]) if params[:sales] == 'kain'
      redirect_to reports_search_by_ukuran_path(from: params[:from], to: params[:to], branch: params[:branch], brand: params[:brand]) if params[:sales] == 'ukuran'
      redirect_to reports_search_by_customer_path(from: params[:from], to: params[:to], branch: params[:branch], brand: params[:brand]) if params[:sales] == 'customer'
      redirect_to reports_search_by_salesman_path(from: params[:from], to: params[:to], branch: params[:branch], brand: params[:brand]) if params[:sales] == 'salesman'
    end
  end

  def summary_of_sales
		@cabang_get_id = Cabang.get_id
    @cabang_7 = Cabang.get_id_to_7
    @cabang_24 = Cabang.get_id_to_22
    @grand_total_lady = SalesProduct.summary_of_sales("LADY", "", "")
    @grand_total_elite = SalesProduct.summary_of_sales("ELITE", "", "")
    @grand_total_royal = SalesProduct.summary_of_sales("Royal", "", "")
    @grand_total_ser = SalesProduct.summary_of_sales("Serenity", "", "")
  end

  def quick_view_monthly_result
    compare_last_month
  end

  def quick_view_monthly_process
    branch = current_user.branch == nil ? nil : current_user.branch
    redirect_to reports_quick_view_monthly_result_path(:brand_scb => params[:quick_view_brand], :group_by => 'cabang_id',
      :month => Date.today, :branch => branch, :channel => params[:channel] ) if params[:type] == 'scb'
    redirect_to reports_quick_view_monthly_result_path(:brand_scm => params[:quick_view_brand], :group_by => 'cabang_id',
      :month => Date.today, :branch => branch, :channel => params[:channel] ) if params[:type] == 'scm'
    redirect_to laporan_cabang_weekly_report_path(periode_week: 1.week.ago, brand_week: params[:quick_view_brand]) if params[:type] == 'week'
  end

  def quick_view_monthly
    
    respond_to do |format|
      format.html
      format.mobile
    end
  end

  def quick_view_report
    redirect_to laporan_cabang_weekly_report_path(:periode_week => 1.week.ago) if params[:quick_view] == 'weekly'
    redirect_to reports_quick_view_monthly_path if params[:quick_view] == 'monthly'
  end

  def quick_view
  end

	def compare_last_month
		unless params[:from].nil? && params[:to].nil?
      if (params[:from].to_date..params[:to].to_date).to_a.group_by(&:month).count <= 6
        @month_devided = (params[:from].to_date..params[:to].to_date).to_a.group_by { |t| t.beginning_of_month }
        @all_month_xls = (params[:from].to_date..params[:to].to_date).to_a.group_by { |t| t.beginning_of_month }
      else
        @all_month_xls = (params[:from].to_date..params[:to].to_date).to_a.group_by { |t| t.beginning_of_month }
        @rsult_month = params[:from].to_date + 5.months
        @month_devided = (params[:from].to_date..@rsult_month).to_a.group_by { |t| t.beginning_of_month }
        @over_month = ((@rsult_month + 1.month)..params[:to].to_date).to_a.group_by { |t| t.beginning_of_month }
      end
      @month = ((params[:to].to_date.month - params[:from].to_date.month + 1) * 2)
      @sum_month = (params[:to].to_date.month - params[:from].to_date.month + 1)
      @customerstore = LaporanCabang.select("sum(jumlah) as sum_jumlah, customer, sum(harganetto2) as sum_harga, kota, kodebrg, kodeartikel,
     cabang_id, kodekain, kota, jenisbrgdisc, namaartikel, namakain, panjang, lebar, tipcust")
      .between_date_sales(params[:from], params[:to]).search_by_branch(params[:branch])
      .search_by_type(params[:type]).brand(params[:brand]).kode_barang_like(params[:article]).fabric(params[:fabric])
      .size_length(params[:size]).size_length(params[:panjang]).customer(params[:customer])
      .brand_size(params[:size_type]).customer_group(params[:channel]).not_equal_with_nosj.group(params[:group_by])
		end
	end
end
