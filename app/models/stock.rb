class Stock < ActiveRecord::Base
  set_table_name "tbstockcabang"
  belongs_to :cabang
  belongs_to :barang
	scope :control_stock, lambda {|date| where(:tanggal => date)}
	scope :check_branch, lambda {|cabang| where(:cabang_id => cabang)}

  scope :check_invoices, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
  scope :query_by_date, lambda {|from, to| where(:tanggalsj => from..to)}
  scope :query_by_single_date, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
# scope for monthly/monthly
	scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
	scope :search_by_type, lambda {|type| where("kodebrg like ?", %(#{type}%)) if type.present? }
	scope :search_by_article, lambda { |article| where("kodebrg like ?", %(__#{article}%)) if article.present?}
	scope :search_by_month_and_year, lambda { |month, year| where("MONTH(tanggalsj) = ? and YEAR(tanggalsj) = ?", month, year)}
	scope :not_equal_with_nosj, where("nosj not like ? and nosj not like ? and nosj not like ?", %(#{'SJB'}%), %(#{'SJY'}%), %(#{'SJV'}%))
	scope :brand, lambda {|brand| where("kodebrg like ?", %(__#{brand}%)) if brand.present?}
	scope :brand_size, lambda {|brand_size| where("kodebrg like ?", %(___________#{brand_size}%)) if brand_size.present?}
	scope :between_date_sales, lambda { |from, to| where("tanggalsj between ? and ?", from, to) if from.present? && to.present? }
	scope :artikel, lambda {|artikel| where("kodebrg like ?", %(__#{artikel}%)) if artikel.present?}
	scope :customer, lambda {|customer| where("customer like ?", %(#{customer})) if customer.present? }
	scope :kode_barang, lambda {|kode_barang| where("kodebrg like ?", kode_barang) if kode_barang.present?}
	scope :kode_barang_like, lambda {|kode_barang| where("kodebrg like ?", %(%#{kode_barang}%)) if kode_barang.present?}
	scope :fabric, lambda {|fabric| where("kodebrg like ?", %(______#{fabric}%)) unless fabric.nil?}
	scope :size_length, lambda {|brand_size| where("kodebrg like ?", %(___________#{brand_size}%)) if brand_size.present? && brand_size != 'all'}
	scope :sum_jumlah, lambda {sum("jumlah")}
	scope :sum_amount, lambda {sum("harganetto2")}

	def self.check_stock(tanggal, branch, brand, type, article, fabric, size)
		select("kodebrg, cabang_id, namabrg, freestock, bufferstock, realstock, realstockservice, realstockdowngrade")
			.control_stock(tanggal).search_by_branch(branch).brand(brand).search_by_type(type).search_by_article(article).fabric(fabric)
	end

	def self.find_barang_id(barang_id, cabang)
		find(:all, :select => "tanggal, cabang_id, kodebrg, freestock, bufferstock, realstock, realstockservice, realstockdowngrade",
			:conditions => ["kodebrg = ? and cabang_id = ?", barang_id, cabang])
	end

  def self.get_stock_in_branch(date, stock, cabang)
    check_stock(date).find_barang_id(stock, cabang)
  end

  def self.get_size_qty(kodebrg, cabang, date, size)
  	find(:all, :select => "kodebrg, freestock, bufferstock, realstock, realstockservice, realstockdowngrade",
  		:conditions => ["kodebrg like ? and kodebrg not like ? and cabang_id = ? and tanggal = ?", %(#{kodebrg + size}%), %(%#{'T'}%),
  		cabang, date])
  end
end
