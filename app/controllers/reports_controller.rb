class ReportsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => :summary_of_sales
  
  def chart
    @sales = TmpBrand.select('cabang_id, merk, qty, val, bulan, tahun').where('bulan = 8')
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def summary_of_sales
		@cabang_get_id = Cabang.get_id
    @cabang_7 = Cabang.get_id_to_7
    @cabang_24 = Cabang.get_id_to_22
    @grand_total_lady = LaporanCabang.summary_of_sales("L", "", "")
    @grand_total_elite = LaporanCabang.summary_of_sales("E", "", "")
    @grand_total_royal = LaporanCabang.summary_of_sales("R", "", "")
    @grand_total_ser = LaporanCabang.summary_of_sales("S", "", "")
  end
  
  def quick_view_monthly_result
    compare_last_month
  end
  
  def quick_view_monthly_process
    branch = current_user.branch == nil ? nil : current_user.branch
    redirect_to reports_quick_view_monthly_result_path(:brand => params[:quick_view_brand], :group_by => 'cabang_id',
      :from => 3.month.ago.to_date, :to => Date.today.to_date, :branch => branch )
  end
  
  def quick_view_monthly
  end
  
  def quick_view_report
    redirect_to laporan_cabang_weekly_report_path(:periode_week => 1.week.ago) if params[:quick_view] == 'weekly'
    redirect_to reports_quick_view_monthly_path if params[:quick_view] == 'monthly'
  end
  
  def quick_view
  end

	def group_last_month
		session[:compare_type] = params[:compare] if params[:compare].present?
		redirect_to reports_through_path(session[:group_by] = params[:group])
	end

	def group_compare
		session[:group_by] = params[:group] if params[:group].present?
		session[:compare_type] = params[:compare] if params[:compare].present?
		redirect_to reports_through_path if session[:group_by].present? || session[:compare_type].present?
	end

	def group
		redirect_to reports_through_path(session[:group_by] = params[:group])
	end

	def compare_current_year
    compare_last_month
    @article = SalesArticle.select("sum(qty) as sum_jumlah, sum(val) as sum_harganetto2, cabang_id, merk, produk, artikel")
    .between_date_sales(params[:from].to_date.month, params[:to].to_date.month).year(params[:from].to_date.year)
    .search_by_branch(params[:branch]).brand(params[:brand]).produk(params[:type]).artikel(params[:article]).group('cabang_id, merk, produk, artikel')
    @customer = LaporanCabang.select("*")
    .between_month_sales(params[:from].to_date.month, params[:to].to_date.month).year(params[:from].to_date.year)
    .search_by_branch(params[:branch]).brand(params[:brand]).not_equal_with_nosj.no_return.group("customer")
    @branch = LaporanCabang.select("*")
    .between_month_sales(params[:from].to_date.month, params[:to].to_date.month).year(params[:from].to_date.year)
    .search_by_branch(params[:branch]).brand(params[:brand]).not_equal_with_nosj.no_return.group("cabang_id")
	end

	def compare_last_year
		compare_last_month
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
     cabang_id, kodekain, kota, jenisbrgdisc, namaartikel, namakain, panjang, lebar")
      .between_date_sales(params[:from], params[:to]).search_by_branch(params[:branch])
      .search_by_type(params[:type]).brand(params[:brand]).kode_barang_like(params[:article]).fabric(params[:fabric])
      .size_length(params[:size]).size_length(params[:panjang]).customer(params[:customer])
      .brand_size(params[:size_type]).customer_modern(params[:customer_modern]).customer_modern_all(params[:customer_modern])
      .not_equal_with_nosj.group(params[:group_by]).customer_retail_all(params[:customer_all_retail])
		end
	end

	def compare_type
		redirect_to reports_second_filter_path if params[:compare].present?
		session[:compare_type] = params[:compare]
	end

	def through
		session[:size] = nil if session[:size] == 'all'
		session[:customer_channel] = nil if session[:customer_channel] == 'all'
		session[:size_standard] = nil if session[:size_standard] == 'all'
		redirect_to reports_detail_path(
			:from => session[:from],
			:to => session[:to],
			:branch => session[:cabang_id],
			:brand => session[:merk_id],
			:type => session[:type_id],
			:article => session[:article_id],
			:fabric => session[:fabric_id],
			:customer_channel => session[:customer_channel],
			:customer => session[:customer],
			:size => session[:size_standard],
			:customer_modern => session[:customer_modern],
			:customer_modern_all => session[:customer_modern],
			:customer_all_retail => session[:customer_all_retail],
			:size_type => session[:size]) if session[:type_report] == 'detail'
		redirect_to reports_standard_path(
			:from => session[:from],
			:to => session[:to],
			:branch => session[:cabang_id],
			:brand => session[:merk_id],
			:type => session[:type_id],
			:article => session[:article_id],
			:fabric => session[:fabric_id],
			:customer_channel => session[:customer_channel],
			:customer => session[:customer],
			:size => session[:size_standard],
			:size_type => session[:size],
			:customer_modern => session[:customer_modern],
			:customer_modern_all => session[:customer_modern],
			:customer_all_retail => session[:customer_all_retail],
			:group_by => session[:group_by]) if session[:type_report] == 'standard'
		redirect_to reports_compare_last_month_path(
			:from => session[:from],
			:to => session[:to],
			:branch => session[:cabang_id],
			:brand => session[:merk_id],
			:type => session[:type_id],
			:article => session[:article_id],
			:fabric => session[:fabric_id],
			:customer => session[:customer],
			:size => session[:size_standard],
			:size_type => session[:size],
			:customer_modern => session[:customer_modern],
			:customer_modern_all => session[:customer_modern],
			:customer_all_retail => session[:customer_all_retail],
			:group_by => session[:group_by]) if session[:type_report] == 'compare' && session[:compare_type] == 'last_month'
		redirect_to reports_compare_last_year_path(
			:from => session[:from],
			:to => session[:to],
			:branch => session[:cabang_id],
			:brand => session[:merk_id],
			:type => session[:type_id],
			:article => session[:article_id],
			:fabric => session[:fabric_id],
			:customer_channel => session[:customer_channel],
			:customer => session[:customer],
			:size => session[:size_standard],
			:size_type => session[:size],
			:customer_modern => session[:customer_modern],
			:customer_modern_all => session[:customer_modern],
			:customer_all_retail => session[:customer_all_retail],
			:group_by => session[:group_by]) if session[:type_report] == 'compare' && session[:compare_type] == 'last_year'
		redirect_to reports_compare_current_year_path(
			:from => session[:from],
			:to => session[:to],
			:branch => session[:cabang_id],
			:brand => session[:merk_id],
			:type => session[:type_id],
			:article => session[:article_id],
			:fabric => session[:fabric_id],
			:customer_channel => session[:customer_channel],
			:customer => session[:customer],
			:size => session[:size_standard],
			:size_type => session[:size],
			:customer_modern => session[:customer_modern],
			:customer_modern_all => session[:customer_modern],
			:customer_all_retail => session[:customer_all_retail],
			:group_by => session[:group_by]) if session[:type_report] == 'compare' && session[:compare_type] == 'year'
	end

	def clear_session
		session[:from] = nil
		session[:to] = nil
		session[:cabang_id] = nil
		session[:merk_id] = nil
		session[:type_id] = nil
		session[:article_id] = nil
		session[:fabric_id] = nil
		session[:customer] = nil
		session[:size] = nil
		session[:size_standard] = nil
		session[:group_by] = nil
		session[:customer_modern] = nil
		session[:customer_modern_all] = nil
		session[:customer_all_retail] = nil
	end

	def customer_modern
		unless params[:customer_modern].nil?
			session[:customer_modern] = params[:customer_modern]
			session[:fabric_id] = nil if session[:fabric_id] == 'Select Fabric'
			session[:article_id] = nil if session[:article_id] == 'Select Article'
			session[:size_standard] = nil if session[:size_standard] == 'all'
			redirect_to reports_through_path
		end
	end

	def customer_retail
		unless params[:customer_retail].nil?
			session[:fabric_id] = nil if session[:fabric_id] == 'Select Fabric'
			session[:article_id] = nil if session[:article_id] == 'Select Article'
			session[:size_standard] = nil if session[:size_standard] == 'all'
			session[:customer] = params[:customer_retail] if params[:customer_retail] != 'all'
			session[:customer_all_retail] = 'all' if params[:customer_retail] == 'all'
			redirect_to reports_through_path
		end
		
	end

	def size_standard
		unless params[:size_standard].nil?
			session[:size_standard] = params[:size_standard] if params[:size_standard].present?
			redirect_to reports_through_path if session[:customer_channel] == 'all' 
			redirect_to reports_customer_modern_path if session[:customer_channel].present? && session[:customer_channel] == 'modern'
			redirect_to reports_customer_retail_path if session[:customer_channel].present? && session[:customer_channel] == 'retail'
		end
	end

	def size_special
		unless params[:panjang].nil?
			session[:size_standard] = params[:panjang] if params[:panjang].present?
			redirect_to reports_customer_modern_path if session[:customer_channel].present? && session[:customer_channel] == 'modern'
			redirect_to reports_customer_retail_path if session[:customer_channel].present? && session[:customer_channel] == 'retail'
			redirect_to reports_through_path if session[:customer_channel].present? && session[:customer_channel] == 'all'
		end
	end

	def second_filter
		@branch = Cabang.branch_get_name(current_user)
		@brand = Merk.merk_all(current_user)
		@type = Product.all
		@article = Artikel.group(:Produk)
		@fabric = Kain.all
		session[:from] = params[:from] if params[:from].present?
		session[:to] = params[:to] if params[:to].present?
		session[:cabang_id] = params[:cabang_id] if params[:cabang_id].present?
		session[:merk_id] = params[:merk_id]
		session[:type_id] = params[:type_id] if params[:type_id].present?
		session[:article_id] = params[:article_id] if params[:article_id].present?
		session[:fabric_id] = params[:fabric_id] if params[:fabric_id].present?
		session[:customer_channel] = params[:customer_channel] if params[:customer_channel].present?
		session[:size] = params[:size] if params[:size].present?
		session[:group_by] = params[:group] if params[:group].present?
		session[:year] = params[:grad_year] if params[:grad_year].present?
		if params[:size] == 'all'
			redirect_to reports_customer_retail_path if params[:customer_channel] == 'retail'
			redirect_to reports_customer_modern_path if params[:customer_channel] == 'modern' 
			redirect_to reports_through_path if params[:customer_channel] == 'all'
		end
		if params[:size] == 'S'
			redirect_to reports_size_standard_path
		end
		if params[:size] == 'T'
			redirect_to reports_size_special_path
		end
		if params[:size] == 'P'
			redirect_to reports_size_standard_path
		end
	end

	def first_filter
		redirect_to reports_compare_type_path if params[:reports] == 'compare'
		redirect_to reports_second_filter_path if params[:reports].present? && params[:reports] != 'compare'
		session[:type_report] = params[:reports]
		clear_session
	end

	def detail
		unless params[:from].nil? && params[:to].nil? 
			@laporancabang = LaporanCabang.between_date_sales(params[:from], params[:to]).search_by_branch(params[:branch])
      .search_by_type(params[:type]).brand(params[:brand]).kode_barang_like(params[:article]).fabric(params[:fabric])
      .size_length(params[:size]).size_length(params[:panjang]).customer(params[:customer])
      .brand_size(params[:size_type]).customer_modern(params[:customer_modern])
      .not_equal_with_nosj.customer_modern_all(params[:customer_modern])
		end 
	end	

	def standard
		unless params[:from].nil? && params[:to].nil?
			@laporancabang = LaporanCabang.standard(params[:from], params[:to], params[:branch], 
				params[:type], params[:brand], params[:article], params[:fabric], 
				params[:size], params[:customer], params[:size_type], 
				params[:customer_modern], params[:group_by], params[:customer_all_retail])
		end
	end

	def type
		redirect_to reports_filter_path unless params[:reports].nil?
  end
  
	def filter
		redirect_to reports_filter_detail_path(:reports => params[:reports], :from => params[:from], 
			:to => params[:to], :brand => params[:merk_id], :branch => params[:cabang_id], 
			:type => params[:type_id]) unless params[:from].nil? || params[:to].nil? || params[:reports].nil?
  end

	def filter_Detail
		@article = Artikel.get_artikel_by_brand(params[:brand], params[:type])
	end

	def index
		@branch = Cabang.get_id
		@brand = Merk.merk_all
		@type = Product.all
		@article = Artikel.group(:Produk)
		@fabric = Kain.all
		redirect_to reports_detail_path(:from => params[:from], :to => params[:to], :cabang_id => params[:cabang_id], 
			:type_id => params[:type_id], :merk_id => params[:merk_id], :article_id => params[:article_id],
			:fabric_id => params[:fabric_id], :size => params[:size]) if params[:reports] == "detail"
		redirect_to reports_pivot_path(:from => params[:from], :to => params[:to], :cabang_id => params[:cabang_id], 
			:type_id => params[:type_id], :merk_id => params[:merk_id], :article_id => params[:article_id],
			:fabric_id => params[:fabric_id], :size => params[:size]) if params[:reports] == "standard"
  end

  def update_chart
    @chart = params[:merk_id]
  end
  
	def update_reports_type
		@type = Merk.where("IdMerk in (?)", params[:merk_id]).first.product.map{|a| [a.Namaroduk, a.KodeProduk]}.insert(0, "")
	end

	def update_reports_kain
		@fabric = Kain.order("NamaKain ASC").get_kain_name(params[:artikel_id]).map{|a| [a.NamaKain, a.KodeKain]}.insert(0, "")
	end

	def update_reports_article
		@article = Artikel.order("Produk ASC").get_name(params[:type_id]).get_artikel_collection(params[:merk_id]).map{|a| [a.Produk, a.KodeCollection]}.insert(0, "")
	end

end
