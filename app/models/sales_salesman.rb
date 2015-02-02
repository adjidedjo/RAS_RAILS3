class SalesSalesman < ActiveRecord::Base
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
  scope :salesman, lambda {|salesman| where("sales like ?", "#{salesman}")}

  def self.get_target_by_salesman(branch, date, merk, salesman)
    select("sum(qty) as sum_jumlah, sum(val) as sum_val").search_by_month_and_year(date.to_date.month, date.to_date.year)
    .brand(merk).search_by_branch(branch).salesman(salesman)
  end

  def self.get_target(branch, date, merk)
    select("sum(qty) as sum_jumlah, sum(val) as sum_val").search_by_month_and_year(date.to_date.month, date.to_date.year).brand(merk).search_by_branch(branch)
  end

  def self.growth_sales_target(last, current)
    (current.to_f / last.to_f) * 100
  rescue ZeroDivisionError
    0
  end
end
