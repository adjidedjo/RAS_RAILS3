class SalesCustomerByBrandYear < ActiveRecord::Base
  scope :between_date_sales, lambda { |from_m, to_m, from_y, to_y| where("bulan between ? and ? and tahun between ? and ?", from_m, to_m, from_y, to_y) if from_m.present? && to_m.present? }
  scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
  scope :search_by_type, lambda {|type| where("produk in (?)", type) if type.present? }
  scope :search_by_month_and_year, lambda { |month, year| where("bulan = ? and tahun = ?", month, year)}
  scope :brand, lambda {|brand| where("merk in (?)", brand) if brand.present?}
  scope :artikel, lambda {|artikel| where("artikel like ?", artikel) if artikel.present?}
  scope :customer, lambda {|customer| where("customer in (?)", customer) if customer.present? }
  scope :fabric, lambda {|fabric| where("kain like ?", fabric) unless fabric.nil?}
  scope :size_length, lambda {|brand_size| where("ukuran like ?", %(_______________#{brand_size}%)) if brand_size.present?}
  scope :customer_modern_all, lambda {|parameter| where("customer like ? or customer like ?", "ES%",'SOGO%') if parameter == 'all'}
  scope :customer_retail_all, lambda {|parameter| where("customer not like ? and customer not like ?", "ES%",'SOGO%') if parameter == 'all'}
  scope :customer_modern, lambda {|customer| where("customer like ?", %(#{customer}%)) if customer != 'all'}
  scope :customer_channel, lambda {|channel| where("tipe_customer in (?)", channel) if channel.present?}
  scope :customer_group, lambda {|group| where("group_customer in (?)", group) if group.present?}

  def self.sales_cabang_per_customer_per_brand_by_year(merk, cabang, date, customer)
    select("sum(qty) as qty, sum(val) as val").where("tahun = ?", date.year)
    .search_by_branch(cabang).brand(merk).customer(customer)
  end

  def self.get_name_customer(date, cabang)
    select("customer").where("tahun = ?", date.year).group("customer").search_by_branch(cabang)
  end
end
