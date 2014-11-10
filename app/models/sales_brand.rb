class SalesBrand < ActiveRecord::Base
  
  scope :between_date_sales, lambda { |from_m, to_m, from_y, to_y| where("bulan between ? and ? and tahun between ? and ?", from_m, to_m, from_y, to_y) if from_m.present? && to_m.present? }
	scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
	scope :search_by_type, lambda {|type| where("produk in (?)", type) if type.present? }
	scope :search_by_month_and_year, lambda { |month, year| where("bulan = ? and tahun = ?", month, year)}
	scope :brand, lambda {|brand| where("merk in (?)", brand) if brand.present?}
	scope :artikel, lambda {|artikel| where("artikel like ?", artikel) if artikel.present?}
	scope :customer, lambda {|customer| where("customer like ?", %(#{customer})) if customer.present? }
	scope :fabric, lambda {|fabric| where("kain like ?", fabric) unless fabric.nil?}
	scope :size_length, lambda {|brand_size| where("ukuran like ?", %(_______________#{brand_size}%)) if brand_size.present?}
	scope :customer_modern_all, lambda {|parameter| where("customer like ? or customer like ?", "ES%",'SOGO%') if parameter == 'all'}
	scope :customer_retail_all, lambda {|parameter| where("customer not like ? and customer not like ?", "ES%",'SOGO%') if parameter == 'all'}
	scope :customer_modern, lambda {|customer| where("customer like ?", %(#{customer}%)) if customer != 'all'}
	
  def self.customer_quick_monthly(month, year, branch, brand)
    select("sum(qty) as qty, sum(val) as val")
    .search_by_month_and_year(month, year).search_by_branch(branch).brand(brand)
	end
  
  def self.customer_monthly(month, year,branch, type, brand, article, kodebrg, fabric, size, customer, size_type, customer_modern,
      customer_all_retail)
		select("sum(qty) as sum_jumlah, sum(val) as sum_harganetto2")
    .search_by_month_and_year(month, year).search_by_branch(branch)
    .search_by_type(type).brand(brand).artikel(article)
    .fabric(fabric).size_length(size).customer(customer).customer_modern(customer_modern)
    .customer_modern_all(customer_modern).customer_retail_all(customer_all_retail)
	end
end