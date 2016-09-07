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

  def self.sales_cabang_per_merk(merk, cabang, date)
    if merk == 'Non Serenity'
      merk = ['Non Serenity', 'ELITE']
    elsif merk == 'Lady Americana'
      merk = ['LADY', 'Lady Americana']
    elsif merk == 'Classic'
      merk = ['CLASSIC', 'Classic']
    elsif merk == 'Technogel'
      merk = ['TECHGEL', 'Technogel']
    else
      merk
    end
    select("sum(qty) as qty, sum(val) as val").where("bulan = ? and tahun = ? and merk is not null", date.month, date.year).search_by_branch(cabang).brand(merk)
  end

  def self.customer_quick_monthly(month, year, branch, brand)
    select("sum(qty) as qty, sum(val) as val").search_by_month_and_year(month, year).search_by_branch(branch).brand(brand)
  end

  def self.customer_monthly(month, year,branch, type, brand, article, kodebrg, fabric, size, customer, size_type, customer_modern,
      customer_all_retail)
		select("sum(qty) as sum_jumlah, sum(val) as sum_harganetto2")
    .search_by_month_and_year(month, year).search_by_branch(branch)
    .search_by_type(type).brand(brand).artikel(article)
    .fabric(fabric).size_length(size).customer(customer).customer_modern(customer_modern)
    .customer_modern_all(customer_modern).customer_retail_all(customer_all_retail)
  end

  def self.net_sales_update_cabang
    year = Date.today.year
    bulan = 1.month.ago.month
    Cabang.all.each do |cabang|
      Merk.all.each do |merk|
        faktur = cabang.jde_id+"-"+year.to_s[2,3]+(sprintf '%02d', bulan.to_s)
        merkA = merk.id == 5 ? "KB" : merk.IdMerk
        jde_net_sales = JdeInvoiceProcessing.where("rprmr1 like ? AND rpar06 like ?", "%#{faktur}%", "%#{merkA}%").sum(:rpag).to_i
        sb = SalesBrand.find_by_tahun_and_bulan_and_merk_and_cabang_id(year, bulan, merk.jde_brand, cabang.IdCabang)
        sb.update_attributes!(val: jde_net_sales) unless sb.nil?
      end
    end
  end

  def self.net_sales_update_customer
    year = Date.today.year
    bulan = 1.month.ago.month
    Cabang.all.each do |cabang|
      Merk.all.each do |merk|
        faktur = "FK"+merk.IdMerk+"-"+cabang.jde_id+"-"+year.to_s[2,3]+(sprintf '%02d', bulan.to_s)
        jde_net_sales = JdeInvoiceProcessing.select("rpvr01, sum(rpag) as rpag").where("rprmr1 like ?", "#{faktur}%").group("rpvr01")
        jde_net_sales.each do |jns|
          sb = SalesCustomerByBrand.find_by_tahun_and_bulan_and_merk_and_cabang_id_and_customer(year, bulan, merk.jde_brand, cabang.IdCabang, jns.rpvr01.strip)
          sb.update_attributes!(val: jns.rpag.to_i) unless sb.nil?
        end
      end
    end
  end
end