class ReportsController < ApplicationController

	def compare_current_year
		compare_last_month
	end

	def compare_last_year
		compare_last_month
	end

	def compare_last_month
		unless params[:from].nil? && params[:to].nil?
			@customerstore = LaporanCabang.select("sum(jumlah) as sum_jumlah, customer, sum(harganetto2) as sum_harga, kota, kodebrg, kodeartikel,
				cabang_id, kodekain")
				.between_date_sales(params[:from], params[:to]).search_by_branch(params[:branch])
				.search_by_type(params[:type]).brand(params[:brand]).kode_barang_like(params[:article]).fabric(params[:fabric])
				.size_length(params[:size]).customer_analyze(params[:customer]).brand_size(params[:size_type]).group(params[:group_by])
		end
	end

	def compare_type
		redirect_to reports_second_filter_path if params[:compare].present?
		session[:compare_type] = params[:compare]
	end

	def through
		session[:size] = nil if session[:size] == 'all'
		session[:customer] = nil if session[:customer] == 'all'
		session[:size_standard] = nil if session[:size_standard] == 'all'
		redirect_to reports_detail_path(
			:from => session[:from],
			:to => session[:to],
			:branch => session[:cabang_id],
			:brand => session[:merk_id],
			:type => session[:type_id],
			:article => session[:article_id],
			:fabric => session[:fabric_id],
			:customer => session[:customer],
			:size => session[:size_standard],
			:size_type => session[:size]) if session[:type_report] == 'detail'
		redirect_to reports_standard_path(
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
			:group_by => session[:group_by]) if session[:type_report] == 'compare' && session[:compare_type] == 'last_month'
		redirect_to reports_compare_last_year_path(
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
			:group_by => session[:group_by]) if session[:type_report] == 'compare' && session[:compare_type] == 'last_year'
		redirect_to reports_compare_current_year_path(
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
	end

	def customer_modern
		unless params[:customer_modern].nil?
			session[:customer] = params[:customer_modern]
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
			session[:customer] = params[:customer_retail]
			session[:customer] = nil if session[:customer] == 'all'
			redirect_to reports_through_path
		end
		
	end

	def size_standard
		session[:size_standard] = params[:size_standard] if params[:size_standard].present?
		unless params[:size_standard].nil?
			redirect_to reports_customer_modern_path if session[:customer].present? && session[:customer] == 'modern'
			redirect_to reports_customer_retail_path if session[:customer].present? && session[:customer] == 'retail'
		end
		redirect_to reports_through_path if session[:size_standard] == 'all'
	end

	def size_special
		session[:size_standard] = params[:panjang] if params[:panjang].present?
		unless params[:panjang].nil?
			redirect_to reports_customer_modern_path if session[:customer].present? && session[:customer] == 'modern'
			redirect_to reports_customer_retail_path if session[:customer].present? && session[:customer] == 'retail'
			redirect_to reports_through_path if session[:customer].present? && session[:customer] == 'all'
		end
	end

	def second_filter
		@branch = Cabang.get_id
		@brand = Merk.merk_all
		@type = Product.all
		@article = Artikel.group(:Produk)
		@fabric = Kain.all
		session[:from] = params[:from] if params[:from].present?
		session[:to] = params[:to] if params[:to].present?
		session[:cabang_id] = params[:cabang_id] if params[:cabang_id].present?
		session[:merk_id] = params[:merk_id] if params[:merk_id].present?
		session[:type_id] = params[:type_id] if params[:type_id].present?
		session[:article_id] = params[:article_id] if params[:article_id].present?
		session[:fabric_id] = params[:fabric_id] if params[:fabric_id].present?
		session[:customer] = params[:customer] if params[:customer].present?
		session[:size] = params[:size] if params[:size].present?
		session[:group_by] = params[:group] if params[:group].present?
		session[:year] = params[:grad_year] if params[:grad_year].present?
		redirect_to reports_through_path if params[:size] == 'all' && params[:customer] == 'all' 
		redirect_to reports_size_standard_path if params[:size] == 'S'
		redirect_to reports_size_special_path if params[:size] == 'T'
		if params[:size] == 'all'
			redirect_to reports_customer_retail_path if params[:customer] == 'retail'
			redirect_to reports_customer_modern_path if params[:customer] == 'modern'
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
				.size_length(params[:size]).customer_analyze(params[:customer]).brand_size(params[:size_type])
		end 
	end	

	def standard
		unless params[:from].nil? && params[:to].nil? 
			@laporancabang = LaporanCabang.select("sum(jumlah) as sum_jumlah, customer, kodebrg, namaartikel, tanggalsj, 
				sum(harganetto2) as sum_harga, cabang_id, salesman, namakain, panjang, lebar")
				.between_date_sales(params[:from], params[:to]).search_by_branch(params[:branch])
				.search_by_type(params[:type]).brand(params[:brand]).kode_barang_like(params[:article]).fabric(params[:fabric])
				.size_length(params[:size]).customer_analyze(params[:customer]).brand_size(params[:size_type]).group(params[:group_by])
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

	def update_reports_type
		@type = Merk.where(:IdMerk => params[:merk_id]).first.product.map{|a| [a.Namaroduk, a.KodeProduk]}.insert(0, "")
	end

	def update_reports_kain
		@fabric = Kain.order("NamaKain ASC").get_kain_name(params[:artikel_id]).map{|a| [a.NamaKain, a.KodeKain]}.insert(0, "")
	end

	def update_reports_article
		@article = Artikel.order("Produk ASC").get_name(params[:type_id]).map{|a| [a.Produk, a.KodeCollection]}.insert(0, "")
	end

end
