class Customer < ActiveRecord::Base
  self.table_name = "jde_customers"
  
  scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
  scope :customer, lambda {|customer| where("nama_customer in (?)", customer) if customer.present? }
  scope :customer_channel, lambda {|channel| where("tipe_customer in (?)", channel) if channel.present?}
  scope :customer_group, lambda {|group| where("group_customer in (?)", group) if group.present?}
  
  def self.batch_customer_active
    ActiveRecord::Base.connection.execute("REPLACE INTO customer_active 
    (branch, kode_customer, customer, tipecust, tanggalsj, fiscal_month, fiscal_year, nofaktur, 
    brand, total, created_at, updated_at)
    SELECT area_id, kode_customer, customer, tipecust, COALESCE(MAX(tanggalsj), '0000-00-00'), 
    MONTH(tanggalsj), YEAR(tanggalsj), COALESCE(MAX(nofaktur)), jenisbrgdisc, SUM(harganetto2), 
    NOW(), NOW() FROM warehouse.F03B11_INVOICES WHERE tanggalsj BETWEEN  '#{'2019-10-04'.to_date}' AND '#{Date.yesterday.to_date}' 
    AND orty = 'RI' GROUP BY kode_customer, jenisbrgdisc;")
  end
  
  def self.batch_calculate_customer_active
    date_now = Date.today
    date = date_now.to_date.months_ago(3)
    ActiveRecord::Base.connection.execute("INSERT INTO 
    sales_mart.CUSTOMER_PROGRESSES (branch, brand, date_check, date_process, fday, fmonth, fyear, inactive, active, created_at)
    SELECT a.branch, a.brand, '#{date}', '#{date_now}', '#{date_now.day}', '#{date_now.month}', '#{date_now.year}',
        COUNT(CASE WHEN a.tanggal >= '#{date}' THEN id END) active,
        COUNT(CASE WHEN a.tanggal < '#{date}' THEN id END) inactive, NOW() FROM
      (
        SELECT id, kode_customer, MAX(tanggalsj) AS tanggal, brand, branch FROM dbmarketing.customer_active cus2 WHERE
        cus2.tipecust = 'RETAIL' GROUP BY kode_customer, brand ORDER BY cus2.tanggalsj DESC
      ) a WHERE brand != ' ' AND branch IS NOT NULL GROUP BY brand, branch;")
  end
  
  def self.notification_order
    order_jde = JdeSoHeader.get_order_today
    order_jde.each do |oje|
      find_by_sql("SELECT * FROM jde_customers WHERE address_number = '#{oje.shan8.to_i}'").each do |c|
        unless c.email.nil?
          JdeSoDetail.get_list_of_item(oje.shdoco, oje.shdcto)
          UserMailer.order(c.email, c.name, oje.oamlnm, oje.oaadd1, oje.oaadd2, oje.oacty1, 
          JdeSoHeader.julian_to_date(oje.shdrqj), JdeSoDetail.get_list_of_item(oje.shdoco, oje.shdcto), oje.shdoco,
          oje.alcty1, oje.aladd1).deliver
          c.update_attributes!(date_mailed: Date.today)
        end
      end
    end
  end

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