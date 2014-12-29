class Customer < ActiveRecord::Base
  scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
  scope :customer, lambda {|customer| where("customer in (?)", customer) if customer.present? }

  def self.sales_cabang_per_toko(cabang, date)
    select("*")
    .where("bulan = ? and tahun = ?", date.month, date.year)
    .search_by_branch(cabang)
  end

  def self.sales_cabang(customer, cabang, date)
    select("*, sum(qty) as sum_qty, sum(val) as sum_val")
    .where("bulan = ? and tahun = ?", date.month, date.year)
    .customer(customer).search_by_branch(cabang)
  end
end