class SalesProduct < ActiveRecord::Base
	scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
	scope :search_by_type, lambda {|type| where("kode_produk in (?)", type) if type.present? }
	scope :search_by_month_and_year, lambda { |month, year| where("MONTH(tanggalsj) = ? and YEAR(tanggalsj) = ?", month, year)}
	scope :brand, lambda {|brand| where("merk in (?)", brand) if brand.present?}
	scope :artikel, lambda {|artikel| where("kodebrg like ?", %(__#{artikel}%)) if artikel.present?}
	scope :customer, lambda {|customer| where("customer like ?", %(#{customer})) if customer.present? }
	scope :kode_barang, lambda {|kode_barang| where("kodebrg like ?", kode_barang) if kode_barang.present?}
	scope :fabric, lambda {|fabric| where("kodekain like ?", fabric) if fabric.present?}
	scope :size_length, lambda {|brand_size| where("kodebrg like ?", %(_______________#{brand_size}%)) if brand_size.present?}
	scope :customer_modern_all, lambda {|parameter| where("customer like ? or customer like ?", "ES%",'SOGO%') if parameter == 'all'}
	scope :customer_retail_all, lambda {|parameter| where("customer not like ? and customer not like ?", "ES%",'SOGO%') if parameter == 'all'}
	scope :customer_modern, lambda {|customer| where("customer like ?", %(#{customer}%)) if customer != 'all'}
	scope :between_date_sales, lambda { |from_m, to_m, from_y, to_y| where("bulan between ? and ? and tahun between ? and ?", from_m, to_m, from_y, to_y) if from_m.present? && to_m.present? }
	scope :brand_size, lambda {|brand_size| where("lebar = ?", brand_size) if brand_size.present?}

  def self.customer_monthly(month, year,branch, type, brand, article, kodebrg, fabric, size, customer, size_type, customer_modern,
      customer_all_retail)
		select("sum(qty) as sum_jumlah, sum(val) as sum_harganetto2")
    .search_by_month_and_year(month, year).search_by_branch(branch)
    .search_by_type(type).brand(brand).artikel(article).kode_barang(kodebrg)
    .fabric(fabric).size_length(size).customer(customer).customer_modern(customer_modern)
    .customer_modern_all(customer_modern).brand_size(size_type).customer_retail_all(customer_all_retail)
	end

  def self.sales_cabang_per_merk_per_produk(merk, product, cabang, date)
    select("sum(qty) as qty, sum(val) as val").where("bulan = ? and tahun = ?", date.month, date.year).search_by_branch(cabang).search_by_type(product).brand(merk)
  end

  def self.sales_cabang_per_merk_per_produk_by_year(merk, product, cabang, date)
    select("sum(qty) as qty, sum(val) as val").where("tahun = ?", date.year).search_by_branch(cabang).search_by_type(product).brand(merk)
  end
end