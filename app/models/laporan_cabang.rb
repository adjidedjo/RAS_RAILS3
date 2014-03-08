class LaporanCabang < ActiveRecord::Base
  set_table_name "tblaporancabang"
  attr_accessible *column_names

  belongs_to :cabang
	belongs_to :brand

  scope :check_invoices, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
  scope :query_by_date, lambda {|from, to| where(:tanggalsj => from..to)}
  scope :query_by_single_date, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
# scope for monthly/monthly
	scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
	scope :search_by_type, lambda {|type| where("kodejenis in (?)", type) if type.present? }
	scope :search_by_article, lambda { |article| where("kodeartikel like ?", %(#{article})) if article.present?}
	scope :search_by_month_and_year, lambda { |month, year| where("MONTH(tanggalsj) = ? and YEAR(tanggalsj) = ?", month, year)}
	scope :not_equal_with_nosj, where("nosj not like ? and nosj not like ? and nosj not like ?", %(#{'SJB'}%), %(#{'SJY'}%), %(#{'SJV'}%))
	scope :brand, lambda {|brand| where("jenisbrgdisc in (?)", brand) if brand.present?}
	scope :brand_size, lambda {|brand_size| where("kodebrg like ?", %(___________#{brand_size}%)) if brand_size.present?}
	scope :between_date_sales, lambda { |from, to| where("tanggalsj between ? and ?", from, to) if from.present? && to.present? }
	scope :artikel, lambda {|artikel| where("kodebrg like ?", %(__#{artikel}%)) if artikel.present?}
	scope :customer, lambda {|customer| where("customer like ?", %(#{customer})) if customer.present? }
	scope :kode_barang, lambda {|kode_barang| where("kodebrg like ?", kode_barang) if kode_barang.present?}
	scope :kode_barang_like, lambda {|kode_barang| where("kodebrg like ?", %(%#{kode_barang}%)) if kode_barang.present?}
	scope :fabric, lambda {|fabric| where("kodekain like ?", fabric) unless fabric.nil?}
	#scope :without_acessoris, lambda {|kodejenis| where("kodejenis not like ?", %(#{kodejenis}%)) if kodejenis.present?}
	scope :customer_analyze, lambda {|customer| where("kodebrg like ?", %(___________#{customer}%)) if customer.present?}
	scope :size_length, lambda {|brand_size| where("kodebrg like ?", %(_______________#{brand_size}%)) if brand_size.present?}
	scope :customer_modern_all, lambda {|parameter| where("customer like ? or customer like ? or customer like ?", "ES%", 'SHOWROOM%', 
		'SOGO%') if parameter == 'all'}
	scope :customer_retail_all, lambda {|parameter| where("customer not like ? and customer not like ? and customer not like ?", "ES%", 'SHOWROOM%', 
		'SOGO%') if parameter == 'all'}
	scope :customer_modern, lambda {|customer| where("customer like ?", %(#{customer}%)) if customer != 'all'}
	scope :sum_jumlah, lambda {sum("jumlah")}
	scope :sum_amount, lambda {sum("harganetto2")}
 scope :kodejenis, where("kodejenis in ('km','sa','sb')")

	def self.total_on_merk_monthly(merk, month, year, cabang)
  select("sum(jumlah) as sum_jumlah").search_by_month_and_year(month, year).not_equal_with_nosj.brand(merk).search_by_branch(cabang).kodejenis
	end

	def self.standard(from, to, branch, type, brand, article, fabric, size, customer, size_type, customer_modern, group, customer_all_retail)
		select("sum(jumlah) as sum_jumlah, customer, kodebrg, namaartikel, tanggalsj, 
					sum(harganetto2) as sum_harga, cabang_id, salesman, namakain, panjang, lebar, jumlah, id, jenisbrgdisc")
			.between_date_sales(from, to).search_by_branch(branch)
			.search_by_type(type).brand(brand).kode_barang_like(article)
			.fabric(fabric).size_length(size).customer(customer).customer_modern(customer_modern).customer_modern_all(customer_modern)
			.brand_size(size_type).not_equal_with_nosj.customer_retail_all(customer_all_retail).group(group)
	end

	def self.analysis_customer_last_year(from, to, branch, type, brand, article, fabric, size, customer, size_type, customer_modern,
		customer_all_retail)
		select("sum(jumlah) as sum_jumlah, customer, sum(harganetto2) as sum_harganetto2")
			.between_date_sales(from, to).search_by_branch(branch)
			.search_by_type(type).brand(brand).kode_barang_like(article)
			.fabric(fabric).size_length(size).customer(customer).customer_modern(customer_modern).customer_modern_all(customer_modern)
			.brand_size(size_type).not_equal_with_nosj.customer_retail_all(customer_all_retail)
	end

	def self.customer_monthly(month, year,branch, type, brand, article, kodebrg, fabric, size, customer, size_type, customer_modern,
		customer_all_retail)
		select("sum(jumlah) as sum_jumlah, customer, kota, sum(harganetto2) as sum_harganetto2")
			.search_by_month_and_year(month, year).search_by_branch(branch)
			.search_by_type(type).brand(brand).artikel(article).kode_barang(kodebrg)
			.fabric(fabric).size_length(size).customer(customer).customer_modern(customer_modern)
			.customer_modern_all(customer_modern).brand_size(size_type).customer_retail_all(customer_all_retail).not_equal_with_nosj
	end

	def self.customer_by_store(from, to, customer, cabang, merk, customer_all_retail)
		select("sum(jumlah) as sum_jumlah").between_date_sales(from, to).customer(customer)
			.search_by_branch(cabang).brand(merk).not_equal_with_nosj.customer_retail_all(customer_all_retail)
	end

	def self.monthly_report(month, branch, type, kode_brand, year, product_type, customer_all_retail)
		select("sum(jumlah) as sum_jumlah").search_by_month_and_year(month, year)
			.search_by_branch(branch)
			.search_by_type(type).search_by_article(kode_brand).not_equal_with_nosj.customer_retail_all(customer_all_retail)
	end

	def self.total_on_merk(merk, from, to)
		find(:all, :select => "sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and kodebrg like ? and nosj not like ? and nosj not like ? and kodejenis not like ?",
			from, to, %(__#{merk}%), %(#{'SJB'}%), %(#{'SJY'}%), %(#{merk}%)])
	end

	def self.total_on(month, merk, year)
   where("YEAR(tanggalsj) = ? and MONTH(tanggalsj) = ? and kodebrg like ? and kodejenis not like ?
		and nosj not like ? and nosj not like ?", year, month, %(__#{merk}%), %(#{merk}%), %(#{'SJB'}%), %(#{'SJY'}%)).sum(:jumlah)
  end

# monthly_comparison by brand

	def self.category_type_comparison(kodebrg, product, from, to)
  	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and kodebrg like ? and nosj not like ? and nosj not like ?",
			from, to, %(%#{product + kodebrg}%), %(#{'SJB'}%), %(#{'SJY'}%)])
	end

	def self.category_size_comparison(kodebrg, size, from, to)
		if size == 'Tanggung'
    	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and kodebrg like ? and kodebrg like ? and nosj not like ? and nosj not like ?",
				from, to, %(%#{kodebrg}%), %(%#{'T'}%),  %(#{'SJB'}%), %(#{'SJY'}%)])
		else
    	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and kodebrg like ? and kodebrg like ? and nosj not like ? and nosj not like ?",
				from, to, %(%#{kodebrg}%), %(%#{size}%), %(#{'SJB'}%), %(#{'SJY'}%)])
		end
	end

	def self.category_customer_comparison(kodebrg, customer, from, to)
		if customer == 'RETAIL'
    	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and kodebrg like ? and customer not like ? and
				customer not like ? and customer not like ? and nosj not like ? and nosj not like ?",
				from, to, %(%#{kodebrg}%), %(%#{'SHOWROOM'}%), %(%#{'SOGO'}%), %(%#{'ES'}%), %(#{'SJB'}%), %(#{'SJY'}%)])
		else
    	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and kodebrg like ? and customer like ? and nosj not like ? and nosj not like ?",
				from, to, %(%#{kodebrg}%), %(%#{customer}%), %(#{'SJB'}%), %(#{'SJY'}%)])
		end
	end

	def self.merk_category_comparison(category, from, to)
    find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and kodebrg like ? and nosj not like ? and nosj not like ?", 
			from, to, %(%#{category}%), %(#{'SJB'}%), %(#{'SJY'}%)])
	end

	def self.customer_comparison(customer, from, to)
		if customer == 'RETAIL'
	  	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and customer not like ? and
				customer not like ? and customer not like ? and nosj not like ? and nosj not like ?",
				from, to, %(%#{'SHOWROOM'}%), %(%#{'SOGO'}%), %(%#{'ES'}%), %(#{'SJB'}%), %(#{'SJY'}%)])
		else
	  	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and customer like ? and nosj not like ? and nosj not like ?", from, to, %(%#{customer}%), 
				%(#{'SJB'}%), %(#{'SJY'}%)])
		end
	end

	def self.type_comparison(product, from, to)
    find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and kodebrg like ? and nosj not like ? and nosj not like ?", 
			from, to, %(#{product}%), %(#{'SJB'}%), %(#{'SJY'}%)])
	end

	def self.category_comparison(category, from, to)
    find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and kodebrg like ? and nosj not like ? and nosj not like ?", 
			from, to, %(__#{category}%), %(#{'SJB'}%), %(#{'SJY'}%)])
	end

	def self.monthly_comparison_brand(from, to, user_brand)
		if user_brand == "A"
			select("sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah").where(["tanggalsj between ? and ? 
				and nosj not like ? and nosj not like ?",
				from, to, %(#{'SJB'}%), %(#{'SJY'}%)])
		else
			select("sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah").where(["tanggalsj between ? and ? and left(kodebrg, 3) like ?
				and nosj not like ? and nosj not like ?", from, to, %(__#{user_brand}), %(#{'SJB'}%), %(#{'SJY'}%)])
		end
	end

	def self.growth(last, current)
		(Float(current - last) / last * 100)
		rescue ZeroDivisionError
   		0
	end

	def self.sum_of_brand_type(merk_id, cabang, cat, from, to)
    find(:all, :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
			:conditions => ["cabang_id = ? and kodebrg like ? and nosj not like ? and nosj not like ? and tanggalsj between ? and ?",
        cabang, "#{cat + merk_id}%", %(#{'SJB'}%), %(#{'SJY'}%), from.to_date, to.to_date])
	end

# brand categories by customer2

	def self.get_value_categories_customer(merk_id, customer, from, to)
		find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["kodebrg like ? and customer like ? and nosj not like ? and nosj not like ? and tanggalsj between ? and ?",
			%(%#{merk_id}%), %(%#{customer}%), %(#{'SJB'}%), %(#{'SJY'}%), from, to])
	end

	def self.get_value_categories_customer_retail(merk_id, customer, retail, from, to)
		find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["kodebrg like ? and customer not like ? and customer not like ? and customer not like ?
			and nosj not like ? and nosj not like ? and tanggalsj between ? and ?",
			%(%#{merk_id}%), %(%#{'SOGO'}%), %(%#{'SHOWROOM'}%), %(%#{'ES'}%), %(#{'SJB'}%), %(#{'SJY'}%), from, to])
	end

# brand by merk

	def self.get_brand_size(artikel, merk_id, size, from, to)
		select("sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah").artikel(artikel).brand_size(size)
			.between_date_sales(from, to).not_equal_with_nosj
	end

# monthly by customer
	def self.get_value_customer(customer, from, to)
		find(:all,:select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["customer like ? and tanggalsj between ? and ? and nosj not like ? and nosj not like ?", %(%#{customer}%), from, to, 
			%(#{'SJB'}%), %(#{'SJY'}%)])
	end

	def self.get_value_customer_retail(customer, retail, from, to)
		find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["customer not like ? and customer not like ? and tanggalsj between ? and ? and nosj not like ? and nosj not like ?",
			%(#{customer}%), %(%#{customer}%), from, to, %(#{'SJB'}%), %(#{'SJY'}%)])
	end

# weekly sales report performance

	def self.comparison_week(week_1, week_2, week_3, week_4, week_5, week_last_month, get_week_number, date)
		if (date.beginning_of_month.cweek - get_week_number) == 4
			((week_1 - week_last_month.to_i) / week_last_month.to_i) * 100
		elsif ((date.beginning_of_month.cweek + 1) - get_week_number) == 4
			((week_2 - week_last_month.to_i) / week_last_month.to_i) * 100
		elsif ((date.beginning_of_month.cweek + 2) - get_week_number) == 4
 			((week_3 - week_last_month.to_i) / week_last_month.to_i) * 100
		elsif ((date.beginning_of_month.cweek + 3) - get_week_number) == 4
 			((week_4 - week_last_month.to_i) / week_last_month.to_i) * 100 == 4
		else
			((week_5 - week_last_month.to_i) / week_last_month.to_i) * 100
		end
		rescue ZeroDivisionError
   		0
	end

	def self.calculation_by_date(from, to)
		find(:all,:select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and nosj not like ? and nosj not like ?", from, to, %(#{'SJB'}%), %(#{'SJY'}%)])
	end

	def self.calculation_by_date_merk(merk_id, from, to)
		find(:all,:select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["kodebrg like ? and tanggalsj between ? and ? and nosj not like ? and nosj not like ?", %(%#{merk_id}%), 
			from, to, %(#{'SJB'}%), %(#{'SJY'}%)])
	end

	def self.get_customers_from_last_year(last_year_date, date_today)
		find(:all,:select => "customer, cabang_id", :conditions => ["tanggalsj between ? and ? and nosj not like ? and nosj not like ?",
			last_year_date, date_today, %(#{'SJB'}%), %(#{'SJY'}%)])
	end

	def self.weekly_sum_value(cat, from, to)
		find(:all, :select => "sum(jumlah) as sum_harganetto2",
			:conditions => ["jenisbrgdisc = ? and tanggalsj between ? and ? and nosj not like ? and nosj not like ?",
			cat, from.to_date, to.to_date, %(#{'SJB'}%), %(#{'SJY'}%)])
	end

	def self.weekly_total_sum_value(cat, from, to)
		find(:all, :select => "sum(jumlah) as sum_harganetto2",
			:conditions => ["jenisbrgdisc in (?) and tanggalsj between ? and ? and nosj not like ? and nosj not like ?",
			cat, from.to_date, to.to_date, %(#{'SJB'}%), %(#{'SJY'}%)])
	end
# ----------

  def self.sum_of_brand(cabang, merk, from, to)
		select("sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah").between_date_sales(from, to)
			.search_by_branch(cabang).brand(merk).not_equal_with_nosj.without_acessoris(merk)
  end

	def self.sum_by_value_merk(cabang, merk, from, to)
    find(:all, :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
			:conditions => ["cabang_id = ? and kodebrg like ? and nosj not like ? and nosj not like ? 
			and tanggalsj between ? and ? and kodejenis not like ?",
        cabang, %(__#{merk}%), %(#{'SJB'}%), %(#{'SJY'}%), from.to_date, to.to_date, %(#{merk}%)])
	end

	def self.sum_of_category(cabang, cat, from, to)
    find(:all, :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
		  :conditions => ["cabang_id = ? and kodebrg like ? and nosj not like ? and nosj not like ? 
			and tanggalsj between ? and ?",
		  cabang, %(__#{cat}%), %(#{'SJB'}%), %(#{'SJY'}%), from.to_date, to.to_date])
  end

# get detail report on index

	def self.get_record(merk_id, from, to, cabang, type_id)
		merk_id = "Non Serenity" if merk_id == "Elite"
    	find(:all, :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg", :conditions => ["cabang_id = ? and jenisbrgdisc like ? and nosj not like ? and nosj not like ? 
				and kodejenis like ? and tanggalsj between ? and ?", cabang, merk_id, %(#{'SJB'}%), %(#{'SJY'}%), type_id,
          from.to_date, to.to_date])	
  end
# brand by customer
	def self.detail_report_with_customer(merk_id, from, to, user, customer)
		detail_report_with_categories_customer(merk_id, from, to, user, customer) unless merk_id.nil?
		find(:all, :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg", :limit => 5000, :conditions => ["customer REGEXP ? and tanggalsj between ? and ?",
				%(^#{customer}), from.to_date, to.to_date])
	end

	def self.detail_report_with_2_customer(merk_id, from, to, user, customer, customer2)
		detail_report_with_categories_customer(merk_id, from, to, user, customer) unless merk_id.nil?
		find(:all, :conditions => ["customer not REGEXP ? and customer not REGEXP ? and customer not like ?
				and tanggalsj between ? and ?", %(^#{customer}), %(^#{customer2}), %(%SHOWROOM%), from.to_date, to.to_date],
        :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg", :limit => 5000)
	end
# brand categories by customer
	def self.detail_report_with_categories_customer(merk_id, from, to, user, customer)
		find(:all, :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg", :limit => 5000, :conditions => ["kodebrg like ? and customer REGEXP ? and tanggalsj between ? and ?",
				%(%#{merk_id}%),%(^#{customer}), from.to_date, to.to_date])
	end

	def self.detail_report_with_categories_2_customer(merk_id, from, to, user, customer)
		find(:all,:select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg", :limit => 5000, :conditions => ["kodebrg like ? and customer not REGEXP ? and customer not REGEXP ? and customer not like ?
				and tanggalsj between ? and ?", %(%#{merk_id}%),%(^#{customer}), %(^#{customer2}), %(#{'SHOWROOM'}%), from.to_date, to.to_date])
	end
# ---------------

  def self.query_by_year_and_cabang_id(year, cabang_id)
    sum(:jumlah, :conditions => ["tanggalfaktur >= ? and tanggalfaktur <= ? and cabang_id = ? and nosj not like ? and nosj not like ?",
        "#{year}-01-01", "#{year}-12-31", cabang_id, %(#{'SJB'}%), %(#{'SJY'}%)])
  end

  def self.monthly_sum_last_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc like ? and nosj not like ? and nosj not like ?",
        get_last_month_on_last_year(date), 1.year.ago(date), jenis, %(#{'SJB'}%), %(#{'SJY'}%)]).to_i
  end

  def self.monthly_sum_current_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc like ? and nosj not like ? and nosj not like ?",
        get_last_month_on_current_year(date), date, jenis, %(#{'SJB'}%), %(#{'SJY'}%)]).to_i
  end

  def self.yearly_sum_last_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc like ? and nosj not like ? and nosj not like ?",
        get_beginning_of_year_on_last_year(date), 1.year.ago(date), jenis, %(#{'SJB'}%), %(#{'SJY'}%)]).to_i
  end

  def self.yearly_sum_current_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc like ? and nosj not like ? and nosj not like ?",
        get_beginning_of_year_on_current_year(date), date, jenis, %(#{'SJB'}%), %(#{'SJY'}%)]).to_i
  end

  #calculation serenity and non serenity

  def self.calculation_serenity_and_non_serenity(date, date_helper)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["nosj not like ? and nosj not like ? and tanggalsj between ? and ? and jenisbrgdisc in (?)",
       %(#{'SJB'}%), %(#{'SJY'}%), date, date_helper,["Serenity", "Non Serenity"]])[0].sum_harga.to_i
  end

  def self.monthly_sum_last_year_multiple_jenis(date, jenis)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["nosj not like ? and nosj not like ? and tanggalsj between ? and ? and jenisbrgdisc in (?)",
        %(#{'SJB'}%), %(#{'SJY'}%), get_last_month_on_last_year(date), 1.year.ago(date),
        jenis])[0].sum_harga.to_i
  end

  def self.monthly_sum_current_year_multiple_jenis(date, jenis)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["nosj not like ? and nosj not like ? and tanggalsj between ? and ? and jenisbrgdisc in (?)",
        %(#{'SJB'}%), %(#{'SJY'}%), get_last_month_on_current_year(date), date,
        jenis])[0].sum_harga.to_i
  end

  def self.yearly_sum_last_year_multiple_jenis(date, jenis)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["nosj not like ? and nosj not like ? and tanggalsj between ? and ? and jenisbrgdisc in (?)",
        %(#{'SJB'}%), %(#{'SJY'}%), get_beginning_of_year_on_last_year(date), 1.year.ago(date),
        jenis])[0].sum_harga.to_i
  end

  def self.yearly_sum_current_year_multiple_jenis(date, jenis)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["nosj not like ? and nosj not like ? and tanggalsj between ? and ? and jenisbrgdisc in (?)",
        %(#{'SJB'}%), %(#{'SJY'}%), get_beginning_of_year_on_current_year(date), date,
        jenis])[0].sum_harga.to_i
  end

  def self.weekly_sum_last_year(from, to, jenis)
    sum(:harganetto2, :conditions => ["nosj not like ? and nosj not like ? and tanggalsj between ? and ? and jenisbrgdisc like ?",
        %(#{'SJB'}%), %(#{'SJY'}%), from, to, jenis ], :order => "id").to_i
  end

  # year and month
  def self.get_last_month_on_last_year(date)
    1.year.ago(date.to_date.beginning_of_month).to_date
  end

  def self.get_last_month_on_current_year(date)
    date.to_date.beginning_of_month.to_date
  end

  def self.get_beginning_of_year_on_last_year(date)
    1.year.ago(date.to_date.beginning_of_year).to_date
  end

  def self.get_beginning_of_year_on_current_year(date)
    date.to_date.beginning_of_year.to_date
  end

  # week
  def self.last_week_on_last_year(date)
    1.year.ago(1.weeks.ago(date.to_date - 6.days)).to_date
  end

  def self.week_on_last_year(date)
    1.year.ago(date.to_date).to_date
  end

  def self.last_week_on_current_year(date)
    1.weeks.ago(date.to_date - 6.days).to_date
  end

  def self.week_on_current_year(date)
    (date - 6.days).to_date
  end

  def self.get_percentage(last_month, current_month)
    (current_month.to_f - last_month.to_f) / last_month.to_f * 100.0
  end

  #calculate week for classic brand
  def self.weekly_sum_last_week_on_last_year(first_day, last_day, jenis)
    sum(:harganetto2, :conditions => ["nosj not like ? and nosj not like ? and tanggalsj between ? and ? and kodebrg like ?",
        %(#{'SJB'}%), %(#{'SJY'}%), first_day, last_day, %(__#{jenis}%) ]).to_i
  end

  def self.weekly_sum_last_week_on_current_year(first_day, last_day, jenis)
    sum(:harganetto2, :conditions => ["nosj not like ? and nosj not like ? and tanggalsj between ? and ? and kodebrg like ?",
        %(#{'SJB'}%), %(#{'SJY'}%), first_day, last_day, %(__#{jenis}%) ]).to_i
  end

  def self.weekly_sum_week_on_last_year(first_day, last_day, jenis)
    sum(:harganetto2, :conditions => ["nosj not like ? and nosj not like ? and tanggalsj between ? and ? and kodebrg like ?",
        %(#{'SJB'}%), %(#{'SJY'}%), first_day, last_day, %(__#{jenis}%) ]).to_i
  end

  def self.weekly_sum_week_on_current_year(first_day, last_day, jenis)
    sum(:harganetto2, :conditions => ["nosj not like ? and nosj not like ? and tanggalsj between ? and ? and kodebrg like ?",
        %(#{'SJB'}%), %(#{'SJY'}%), first_day, last_day, %(__#{jenis}%) ]).to_i
  end

end
