class SalesCustomer < ActiveRecord::Base
	scope :between_date_sales, lambda { |from_m, to_m, from_y, to_y| where("bulan between ? and ? and tahun between ? and ?", from_m, to_m, from_y, to_y) if from_m.present? && to_m.present? }
	scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
	scope :search_by_type, lambda {|type| where("kode_produk in (?)", type) if type.present? }
	scope :search_by_month_and_year, lambda { |month, year| where("bulan = ? and tahun = ?", month, year)}
	scope :brand, lambda {|brand| where("merk in (?)", brand) if brand.present?}
	scope :artikel, lambda {|artikel| where("artikel like ?", artikel) if artikel.present?}
	scope :customer, lambda {|customer| where("customer in (?)", customer) if customer.present? }
	scope :fabric, lambda {|fabric| where("kain like ?", fabric) unless fabric.nil?}
	scope :size_length, lambda {|brand_size| where("ukuran like ?", %(_______________#{brand_size}%)) if brand_size.present?}
	scope :customer_modern_all, lambda {|parameter| where("customer like ? or customer like ?", "ES%",'SOGO%') if parameter == 'all'}
	scope :customer_retail_all, lambda {|parameter| where("customer not like ? and customer not like ?", "ES%",'SOGO%') if parameter == 'all'}
	scope :customer_modern, lambda {|customer| where("customer like ?", %(#{customer}%)) if customer != 'all'}
	scope :customer_channel, lambda {|channel| where("tipe in (?)", channel) if channel.present?}
	scope :customer_group, lambda {|group| where("tipe in (?)", group) if group.present?}

  def self.customer_monthly(month, year,branch, type, brand, article, kodebrg, fabric, size, customer, size_type, customer_modern,
      customer_all_retail)
		select("sum(qty) as sum_jumlah, sum(val) as sum_harganetto2")
    .search_by_month_and_year(month, year).search_by_branch(branch)
    .search_by_type(type).brand(brand).artikel(article)
    .fabric(fabric).size_length(size).customer(customer).customer_modern(customer_modern)
    .customer_modern_all(customer_modern).customer_retail_all(customer_all_retail)
	end

  def self.sales_cabang_per_toko(merk, customer, cabang, date)
    select("*, sum(qty) as sum_qty, sum(val) as sum_val")
    .where("bulan = ? and tahun = ?", date.month, date.year)
    .search_by_branch(cabang).customer(customer).brand(merk)
  end

  def self.find_toko(cabang, date)
    select("*")
    .where("bulan = ? and tahun = ?", date.month, date.year)
    .search_by_branch(cabang).group("customer")
  end

  def self.sales_cabang_per_toko_per_produk(merk, produk, cabang, date, customer, channel, group)
    select("sum(qty) as qty, sum(val) as val")
    .where("bulan = ? and tahun = ?", date.month, date.year)
    .search_by_branch(cabang).search_by_type(produk).brand(merk).customer(customer)
    .customer_channel(channel).customer_group(group)
  end

  def self.get_name_customer(date)
    select("customer").where("bulan = ? and tahun = ?", date.month, date.year).group("customer")
  end

  def self.get_name_group_customer(date)
    select("group_customer").where("bulan = ? and tahun = ?", date.month, date.year).group("group_customer")
  end
end