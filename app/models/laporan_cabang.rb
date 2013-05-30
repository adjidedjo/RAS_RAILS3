class LaporanCabang < ActiveRecord::Base
  set_table_name "tblaporancabang"
  belongs_to :cabang
	belongs_to :brand
  scope :query_by_date, lambda {|from, to| where(:tanggalsj => from..to)}
  scope :by_category_items, lambda {|category, date, cabang_id| where(:jenisbrgdisc => category,
      :tanggalfaktur => date, :cabang_id => cabang_id)}
  scope :query_by_year, lambda {|year| where("tanggalfaktur >= ? and tanggalfaktur <= ?",
      "#{year}-01-01", "#{year}-12-31")}
  scope :query_by_branch, lambda {|id_cabang| where(:cabang_id => id_cabang).order("tanggalsj desc")}
  scope :check_invoices, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
  scope :by_jenisbrg, lambda {|jenis| where(:jenisbrgdisc => jenis).order("tanggalsj desc")}
  scope :query_by_single_date, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
  scope :remove_cab, where("customer not like ?","#{'CAB'}%")

	def self.monthly_report(month, merk, year)
	 merk = "Non Serenity" if merk == 'Elite'
		find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["MONTH(tanggalsj) = ? and YEAR(tanggalsj) = ? and jenisbrgdisc like ? and customer not like ?",
			month, year, %(%#{merk}%), %(#{'cab'}%)])
	end


	def self.total_on_merk(merk, from, to)
		find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and jenisbrgdisc like ? and customer not like ?",
			from, to, %(%#{merk}%), %(#{'cab'}%)])
	end

	def self.total_on(date, merk, merk_name)
	 merk_name = "Non Serenity" if merk_name == 'Elite'
   where("MONTH(tanggalsj) = ? and kodebrg like ? and jenisbrgdisc like ?", date, %(__#{merk}%), merk_name).sum(:jumlah)
  end

# monthly_comparison by brand

	def self.category_type_comparison(kodebrg, product, from, to)
  	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and kodebrg like ? and customer not like ?",
			from, to, %(%#{product + kodebrg}%), %(#{'cab'}%)])
	end

	def self.category_size_comparison(kodebrg, size, from, to)
		if size == 'Tanggung'
    	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and kodebrg like ? and kodebrg like ? and customer not like ?",
				from, to, %(%#{kodebrg}%), %(%#{'T'}%), %(#{'cab'}%)])
		else
    	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and kodebrg like ? and kodebrg like ? and customer not like ?",
				from, to, %(%#{kodebrg}%), %(%#{size}%), %(#{'cab'}%)])
		end
	end

	def self.category_customer_comparison(kodebrg, customer, from, to)
		if customer == 'RETAIL'
    	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and kodebrg like ?  and customer not like ? and
				customer not like ? and customer not like ? and customer not like ?",
				from, to, %(%#{kodebrg}%), %(%#{'SHOWROOM'}%), %(%#{'SOGO'}%), %(%#{'ES'}%), %(#{'cab'}%)])
		else
    	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and kodebrg like ? and customer like ? and customer not like ?",
				from, to, %(%#{kodebrg}%), %(%#{customer}%), %(#{'cab'}%)])
		end
	end

	def self.merk_category_comparison(category, from, to)
    find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and kodebrg like ? and customer not like ?", from, to, %(%#{category}%), %(#{'cab'}%)])
	end

	def self.customer_comparison(customer, from, to)
		if customer == 'RETAIL'
	  	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and customer not like ? and
				customer not like ? and customer not like ? and customer not like ?",
				from, to, %(%#{'SHOWROOM'}%), %(%#{'SOGO'}%), %(%#{'ES'}%), %(#{'cab'}%)])
		else
	  	find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
				:conditions => ["tanggalsj between ? and ? and customer like ? and customer not like ?", from, to, %(%#{customer}%), %(#{'cab'}%)])
		end
	end

	def self.type_comparison(product, from, to)
    find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and kodebrg like ? and customer not like ?", from, to, %(#{product}%), %(#{'cab'}%)])
	end

	def self.category_comparison(category, from, to)
    find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["tanggalsj between ? and ? and kodebrg like ? and customer not like ?", from, to, %(%#{category}%), %(#{'cab'}%)])
	end

	def self.monthly_comparison_brand(from, to, user_brand)
		if user_brand == "A"
			select("sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah").where(["tanggalsj between ? and ? and customer not like ?",
				from, to, %(#{'cab'}%)])
		else
			select("sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah").where(["tanggalsj between ? and ? and left(kodebrg, 3) like ?
				and customer not like ?", from, to, %(__#{user_brand}), %(#{'cab'}%)])
		end
	end

	def self.growth(last, current)
		((current - last) / last) * 100
		rescue ZeroDivisionError
   		0
	end

	def self.sum_of_brand_type(merk_id, cabang, cat, from, to)
    find(:all, :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
			:conditions => ["cabang_id = ? and kodebrg like ? and customer not like ? and tanggalsj between ? and ?",
        cabang, "#{cat + merk_id}%", %(#{'cab'}%), from.to_date, to.to_date])
	end

# brand categories by customer2

	def self.get_value_categories_customer(merk_id, customer, from, to)
		find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["kodebrg like ? and customer like ? and customer not like ? and tanggalsj between ? and ?",
			%(%#{merk_id}%), %(%#{customer}%), %(#{'cab'}%), from, to])
	end

	def self.get_value_categories_customer_retail(merk_id, customer, retail, from, to)
		find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["kodebrg like ? and customer not like ? and customer not like ? and customer not like ? and
			customer not like ? and tanggalsj between ? and ?",
			%(%#{merk_id}%), %(%#{'SOGO'}%), %(%#{'SHOWROOM'}%), %(%#{'ES'}%), %(#{'cab'}%), from, to])
	end

# brand by merk

	def self.get_brand_size(merk_id, size, from, to)
    	find(:all, :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
				:conditions => ["kodebrg like ? and kodebrg like ? and customer not like ? and tanggalsj between ? and ?",
        %(%#{size}%), %(%#{merk_id}%), %(#{'cab'}%), from.to_date, to.to_date])
	end

# monthly by customer
	def self.get_value_customer(customer, from, to)
		find(:all,:select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
		:conditions => ["customer like ? and tanggalsj between ? and ? and customer not like ?", %(%#{customer}%), from, to, %(#{'cab'}%)])
	end

	def self.get_value_customer_retail(customer, retail, from, to)
		find(:all, :select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
		:conditions => ["customer not like ? and customer not like ? and tanggalsj between ? and ? and customer not like ?",
		%(#{customer}%), %(%#{customer}%), from, to, %(#{'cab'}%)])
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
			:conditions => ["tanggalsj between ? and ? and customer not like ?", from, to, %(#{'cab'}%)])
	end

	def self.calculation_by_date_merk(merk_id, from, to)
		find(:all,:select => "sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah",
			:conditions => ["kodebrg like ? and tanggalsj between ? and ? and customer not like ?", %(%#{merk_id}%), from, to, %(%#{'cab'}%)])
	end

	def self.get_customers_from_last_year(last_year_date, date_today)
		find(:all,:select => "customer, cabang_id", :conditions => ["tanggalsj between ? and ? and customer not like ?",
			last_year_date, date_today, %(#{'cab'}%)])
	end

	def self.weekly_sum_value(cat, from, to)
		find(:all, :select => "sum(harganetto2) as sum_harganetto2",
			:conditions => ["jenisbrgdisc = ? and tanggalsj between ? and ? and customer not like ?",
			cat, from.to_date, to.to_date, %(#{'cab'}%)])
	end

	def self.weekly_total_sum_value(cat, from, to)
		find(:all, :select => "sum(harganetto2) as sum_harganetto2",
			:conditions => ["jenisbrgdisc in (?) and tanggalsj between ? and ? and customer not like ?",
			cat, from.to_date, to.to_date, %(#{'cab'}%)])
	end
# ----------

  def self.sum_of_brand(cabang, merk, from, to)
  	merk = 'Non Serenity' if merk == 'Elite'
		  find(:all, :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
				:conditions => ["cabang_id = ? and jenisbrgdisc like ? and customer not like ? and tanggalsj between ? and ?",
				cabang, %(#{merk}%), %(#{'cab'}%), from.to_date, to.to_date])
  end

	def self.sum_by_value_merk(cabang, merk, from, to)
    find(:all, :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
			:conditions => ["cabang_id = ? and kodebrg like ? and customer not like ? and tanggalsj between ? and ?",
        cabang, %(__#{merk}%), %(#{'cab'}%), from.to_date, to.to_date])
	end

	def self.sum_of_category(cabang, cat, from, to)
    find(:all, :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
		  :conditions => ["cabang_id = ? and kodebrg like ? and customer not like ? and tanggalsj between ? and ?",
		  cabang, %(__#{cat}%), %(#{'cab'}%), from.to_date, to.to_date])
  end

# get detail report on index

	def self.get_record(merk_id, from, to, cabang, type_id)
		merk_id = "Non Serenity" if merk_id == "Elite"
    	find(:all, :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg", :conditions => ["cabang_id = ? and jenisbrgdisc like ? and customer not like ? 
				and kodejenis like ? and tanggalsj between ? and ?", cabang, merk_id, %(#{'cab'}%), type_id,
          from.to_date, to.to_date]) if merk_id.nil?

    	find(:all, :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg", :conditions => ["cabang_id = ? and customer not like ? 
				and kodejenis like ? and tanggalsj between ? and ?", cabang, %(#{'cab'}%), type_id,
          from.to_date, to.to_date]) unless merk_id.nil? unless merk_id.nil?			
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
    sum(:jumlah, :conditions => ["tanggalfaktur >= ? and tanggalfaktur <= ? and cabang_id = ? and customer not like ?",
        "#{year}-01-01", "#{year}-12-31", cabang_id, %(#{'cab'}%)])
  end

  def self.monthly_sum_last_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc like ? and customer not like ?",
        get_last_month_on_last_year(date), 1.year.ago(date), jenis, %(#{'cab'}%) ]).to_i
  end

  def self.monthly_sum_current_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc like ? and customer not like ?",
        get_last_month_on_current_year(date), date, jenis, %(#{'cab'}%) ]).to_i
  end

  def self.yearly_sum_last_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc like ? and customer not like ?",
        get_beginning_of_year_on_last_year(date), 1.year.ago(date), jenis, %(#{'cab'}%)]).to_i
  end

  def self.yearly_sum_current_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc like ? and customer not like ?",
        get_beginning_of_year_on_current_year(date), date, jenis, %(#{'cab'}%) ]).to_i
  end

  #calculation serenity and non serenity

  def self.calculation_serenity_and_non_serenity(date, date_helper)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => [" customer not like ? and tanggalsj between ? and ? and jenisbrgdisc in (?)",
        %(#{'cab'}%), date, date_helper,["Serenity", "Non Serenity"]])[0].sum_harga.to_i
  end

  def self.monthly_sum_last_year_multiple_jenis(date, jenis)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["customer not like ? and tanggalsj between ? and ? and jenisbrgdisc in (?)",
        %(#{'cab'}%), get_last_month_on_last_year(date), 1.year.ago(date),
        jenis])[0].sum_harga.to_i
  end

  def self.monthly_sum_current_year_multiple_jenis(date, jenis)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["customer not like ? and tanggalsj between ? and ? and jenisbrgdisc in (?)",
        %(#{'cab'}%), get_last_month_on_current_year(date), date,
        jenis])[0].sum_harga.to_i
  end

  def self.yearly_sum_last_year_multiple_jenis(date, jenis)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["customer not like ? and tanggalsj between ? and ? and jenisbrgdisc in (?)",
        %(#{'cab'}%), get_beginning_of_year_on_last_year(date), 1.year.ago(date),
        jenis])[0].sum_harga.to_i
  end

  def self.yearly_sum_current_year_multiple_jenis(date, jenis)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["customer not like ? and tanggalsj between ? and ? and jenisbrgdisc in (?)",
        %(#{'cab'}%), get_beginning_of_year_on_current_year(date), date,
        jenis])[0].sum_harga.to_i
  end

  def self.weekly_sum_last_year(from, to, jenis)
    sum(:harganetto2, :conditions => ["customer not like ? and tanggalsj between ? and ? and jenisbrgdisc like ?",
        %(#{'cab'}%), from, to, jenis ], :order => "id").to_i
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
    sum(:harganetto2, :conditions => ["customer not like ? and tanggalsj between ? and ? and jenisbrgdisc like ?",
        %(#{'cab'}%), first_day, last_day, jenis ]).to_i
  end

  def self.weekly_sum_last_week_on_current_year(first_day, last_day, jenis)
    sum(:harganetto2, :conditions => ["customer not like ? and tanggalsj between ? and ? and jenisbrgdisc like ?",
        %(#{'cab'}%), first_day, last_day, jenis ]).to_i
  end

  def self.weekly_sum_week_on_last_year(first_day, last_day, jenis)
    sum(:harganetto2, :conditions => ["customer not like ? and tanggalsj between ? and ? and jenisbrgdisc like ?",
        %(#{'cab'}%), first_day, last_day, jenis ]).to_i
  end

  def self.weekly_sum_week_on_current_year(first_day, last_day, jenis)
    sum(:harganetto2, :conditions => ["customer not like ? and tanggalsj between ? and ? and jenisbrgdisc like ?",
        %(#{'cab'}%), first_day, last_day, jenis ]).to_i
  end

end
