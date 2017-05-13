class Customer < ActiveRecord::Base
  self.table_name = "jde_customers"
  
  scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
  scope :customer, lambda {|customer| where("nama_customer in (?)", customer) if customer.present? }
  scope :customer_channel, lambda {|channel| where("tipe_customer in (?)", channel) if channel.present?}
  scope :customer_group, lambda {|group| where("group_customer in (?)", group) if group.present?}

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

  def self.cabang_customer(customer, cabang)
    where("bulan = ? and tahun = ?", date.month, date.year)
    .customer(customer).search_by_branch(cabang)
  end
end