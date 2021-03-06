class LaporanCabang < ActiveRecord::Base
  set_table_name "tblaporancabang"
  attr_accessible *column_names

  belongs_to :cabang
	belongs_to :brand

  scope :check_invoices, lambda {|date, jenis| where(:tanggalsj => date).where("jenisbrgdisc in (?)", jenis).order("tanggalsj desc")}
  scope :query_by_date, lambda {|from, to| where(:tanggalsj => from..to)}
  scope :query_by_single_date, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
  # scope for monthly/monthly
  scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
  scope :search_by_type, lambda {|type| where("kodejenis in (?)", type) if type.present? and type != "AC" }
  scope :type, lambda {|type| where("jenisbrg in (?)", type) if type.present? and type != "AC" }
  scope :search_by_article, lambda { |article| where("kodeartikel like ?", %(#{article})) if article.present?}
  scope :search_by_namaarticle, lambda { |article| where("namaartikel in (?)", article) if article.present?}
  scope :search_by_month_and_year, lambda { |month, year| where("MONTH(tanggalsj) = ? and YEAR(tanggalsj) = ?", month, year)}
  scope :search_by_date, lambda { |date| where("DAY(tanggalsj) = ?", date)}
  scope :search_by_year, lambda { |year| where("YEAR(tanggalsj) = ?", year)}
  scope :not_equal_with_nosj, where("nosj not like ? and nosj not like ? and nosj not like ? and ketppb not like ? and ketppb not like ?",  %(#{'SJB'}%), %(#{'SJY'}%), %(#{'SJP'}%), %(#{'RD'}%), %(#{'EXSJ'}%))
  scope :not_equal_with_nofaktur, where("nofaktur not like ? and nofaktur not like ? and nofaktur not like ? and nofaktur not like ? and nofaktur not like ?", %(#{'FKD'}%), %(#{'FKB'}%), %(#{'FKY'}%), %(#{'FKV'}%), %(#{'FKP'}%))
  scope :no_return, where("nofaktur not like ? and nofaktur not like ? ", %(#{'RTR'}%),%(#{'RET'}%))
  scope :no_pengajuan, where("ketppb not like ?", %(%#{'pengajuan'}%))
  scope :brand, lambda {|brand| where("jenisbrgdisc in (?)", brand) if brand.present?}
  scope :brand_size, lambda {|brand_size| where("lebar = ?", brand_size) if brand_size.present?}
  scope :between_date_sales, lambda { |from, to| where("tanggalsj between ? and ?", from, to) if from.present? && to.present? }
  scope :year, lambda { |year| where("year(tanggalsj) = ?", year) if year.present?}
  scope :artikel, lambda {|artikel| where("kodebrg like ?", %(__#{artikel}%)) if artikel.present?}
  scope :customer, lambda {|customer| where("customer like ?", %(#{customer})) if customer.present? }
  scope :kode_barang, lambda {|kode_barang| where("kodebrg like ?", kode_barang) if kode_barang.present?}
  scope :kode_barang_like, lambda {|kode_barang| where("kodebrg like ?", %(%#{kode_barang}%)) if kode_barang.present?}
  scope :fabric, lambda {|fabric| where("kodekain like ?", fabric) unless fabric.nil?}
  scope :namafabric, lambda {|fabric| where("namakain in (?)", fabric) unless fabric.nil?}
  scope :without_acessoris, where("kodejenis in ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')")
  scope :customer_analyze, lambda {|customer| where("kodebrg like ?", %(___________#{customer}%)) if customer.present?}
  scope :size_length, lambda {|brand_size| where("kodebrg like ?", %(_______________#{brand_size}%)) if brand_size.present?}
  scope :customer_modern_all, lambda {|parameter| where("customer like ? or customer like ?", "ES%",'SOGO%') if parameter == 'all'}
  scope :customer_retail_all, lambda {|parameter| where("customer not like ? and customer not like ?", "ES%",'SOGO%') if parameter == 'all'}
  scope :customer_modern, lambda {|customer| where("customer like ?", %(#{customer}%)) if customer != 'all'}
  scope :sum_jumlah, lambda {sum("jumlah")}
  scope :sum_amount, select("sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah")
  scope :main_category, where("kodejenis in ('km','sa','sb','st')")
  scope :withou_mm, where("customer not like ? and customer not like ?", "ES%",'SOGO%')
  scope :salesman, lambda {|salesman| where("salesman like ?", "#{salesman}%")}
  scope :between_month_sales, lambda { |from, to| where("month(tanggalsj) between ? and ?", from, to) if from.present? && to.present? }
  scope :namaartikel, lambda{|nama| where "namaartikel like ?", %(#{nama}%) }
  scope :jenisbrg, lambda{|nama| where "jenisbrg in (?)", nama }
  scope :month, lambda{|month| where "month(tanggalsj) = ?", month }
  scope :brand_on_kodebarang, lambda{|brand| where("kodebrg like ?", %(__#{brand}%))}
  scope :cabang, lambda {|branch| where("cabang_id = ?", branch) if branch.present? }
  scope :size_st, lambda {|size| where("kodebrg like ?", %(___________#{size}%)) if size.present?}
  scope :channel, lambda {|channel| where("tipecust like ?", channel) if channel.present?}
  scope :lebar, lambda {|lebar| where("lebar in (?)", lebar) if lebar.present?}
  scope :brand_on_kodebrg, lambda{|brand| where("kodebrg like ?", %(__#{brand}%))}
  scope :without_empty_brand, where("jenisbrgdisc not like ?", '')
  scope :without_bonus, where("bonus like ?", '-')
  scope :accessoris_bonus, where("kodejenis not like ? and bonus like ?", 'AC', 'BONUS')
  scope :nosj_to_check, where("nosj not like ? and nosj not like ? and nosj not like ? and ketppb not like ?",%(#{'SJY'}%), %(#{'SJB'}%), %(#{'SJP'}%), %(#{'RD'}%))

  
  def self.update_salesman
    a = find_by_sql("SELECT kode_customer, jenisbrgdisc, cabang_id, tanggalsj 
    FROM tblaporancabang WHERE MONTH(tanggalsj) = 2 AND YEAR(tanggalsj) = 2017 
    AND cabang_id = 2 AND jenisbrgdisc = 'ELITE'")
    a.each do |b|
      sales = JdeSalesman.find_salesman(b.kode_customer, 'E')
      b.update_attributes!(:salesman => sales.to_s)
    end
  end

  def self.combine_group(merk)
    if merk == 'Non Serenity' || merk == 'Accessoris Elite'
      merk = 'ELITE'
    elsif merk == 'Lady Americana' || merk == 'Accessoris Lady'
      merk = 'Lady Americana'
    elsif merk == 'Classic'
      merk = 'CLASSIC'
    elsif merk == 'Technogel' || merk == 'Accessoris Technogel'
      merk = 'TECHGEL'
    end

    return merk
  end

  def self.grand_total_cabang(cabang)
    select("sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah").search_by_branch(cabang).search_by_month_and_year(Date.today.month, Date.today.year).not_equal_with_nosj
  end

  #  background_job
  def self.sales_customer_by_cities(bulan, tahun)
    select("cabang_id, namaartikel, namakain, kodebrg, panjang, lebar, kodejenis, kodeartikel, kota, tipecust, groupcust, plankinggroup,
customer, salesman, jenisbrgdisc, jenisbrg, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2").without_acessoris.without_bonus
    .search_by_month_and_year(bulan, tahun).not_equal_with_nosj.group(:cabang_id, :jenisbrgdisc, :kodejenis, :kota).each do |lapcab|
      sales_brand = SalesCustomerByCity.find_by_bulan_and_tahun_and_cabang_id_and_merk_and_produk_and_city(bulan, tahun, lapcab.cabang_id, lapcab.jenisbrgdisc, lapcab.jenisbrg, lapcab.kota)
      if sales_brand.nil?
        SalesCustomerByCity.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => lapcab.jenisbrgdisc, :produk => lapcab.jenisbrg,
          :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2,
          :kode_produk => lapcab.kodejenis, :kode_artikel => lapcab.kodeartikel,
          :type => lapcab.tipecust, :group => lapcab.groupcust, :city => lapcab.kota)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      end
    end
  end

  def self.update_customer(month, year)
    Customer.all.each do |cust|
      LaporanCabang.where('cabang_id = ? and customer like ? and month(tanggalsj) = ? and year(tanggalsj) = ?', cust.cabang_id, cust.nama_customer, month, year).each do |custlap|
        custlap.update_attributes(:tipecust => cust.tipe_customer, :groupcust => cust.group_customer,
          :kota => cust.kota, :plankinggroup => cust.flankin_customer)
      end
    end
  end

  def self.sales_by_size(bulan, tahun)
    select("cabang_id, namaartikel, namakain, kodebrg,panjang, lebar, kodejenis, kodeartikel,
customer, salesman, jenisbrgdisc, jenisbrg, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2, namabrand")
    .search_by_month_and_year(bulan, tahun).without_acessoris.without_bonus
    .not_equal_with_nosj.group(:cabang_id, :jenisbrgdisc, :kodejenis, :kodeartikel, :lebar).each do |lapcab|
      sales_brand = SalesSize.find_by_bulan_and_tahun_and_cabang_id_and_merk_and_kode_produk_and_kode_artikel_and_lebar(
        bulan, tahun, lapcab.cabang_id, lapcab.jenisbrgdisc, lapcab.kodejenis, lapcab.kodeartikel, lapcab.lebar)
      if sales_brand.nil?
        SalesSize.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => combine_group(lapcab.jenisbrgdisc), :produk => lapcab.jenisbrg,
          :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2, :series => lapcab.namabrand,
          :kode_produk => lapcab.kodejenis, :kode_artikel => lapcab.kodeartikel)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      end
    end
  end

  def self.sales_by_salesmen(bulan, tahun)
    select("cabang_id, namaartikel, namakain, kodebrg,panjang, lebar, kodejenis, kodeartikel,
customer, salesman, jenisbrgdisc, jenisbrg, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2").without_acessoris.without_bonus
    .search_by_month_and_year(bulan, tahun).not_equal_with_nosj.group(:cabang_id, :jenisbrgdisc, :kodejenis, :customer, :salesman).each do |lapcab|
      sales_brand = SalesSalesman.find_by_bulan_and_tahun_and_cabang_id_and_merk_and_kode_produk_and_sales_and_customer(bulan, tahun, lapcab.cabang_id, lapcab.jenisbrgdisc, lapcab.kodejenis, lapcab.salesman, lapcab.customer)
      if sales_brand.nil?
        SalesSalesman.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => combine_group(lapcab.jenisbrgdisc), :produk => lapcab.jenisbrg,
          :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2,
          :kode_produk => lapcab.kodejenis)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      end
    end
  end

  def self.sales_by_customer(bulan, tahun)
    select("cabang_id, namaartikel, namakain, kodebrg, panjang, lebar, kodejenis, kodeartikel, kota, tipecust, groupcust, plankinggroup,
customer, salesman, jenisbrgdisc, jenisbrg, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2").search_by_month_and_year(bulan, tahun).without_acessoris.without_bonus
    .not_equal_with_nosj.group(:cabang_id, :jenisbrgdisc, :kodejenis, :customer).each do |lapcab|
      sales_brand = SalesCustomer.find_by_bulan_and_tahun_and_cabang_id_and_merk_and_artikel_and_produk_and_customer(bulan, tahun, lapcab.cabang_id, lapcab.jenisbrgdisc, lapcab.namaartikel, lapcab.jenisbrg, lapcab.customer)
      if (lapcab.jenisbrg.include? ('Elite')) || (lapcab.jenisbrg.include? ('LA'))
        jenis = 'AC'
      else
        jenis = lapcab.kodejenis
      end
      if sales_brand.nil?
        SalesCustomer.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => combine_group(lapcab.jenisbrgdisc), :produk => lapcab.jenisbrg,
          :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2,
          :kode_produk => jenis, :kode_artikel => lapcab.kodeartikel,
          :city => lapcab.kota, :group_customer => lapcab.groupcust, :tipe => lapcab.tipecust, :plankinggroup => lapcab.plankinggroup)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      end
    end
  end

  def self.sales_by_customer_by_brand(bulan, tahun)
    select("*, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2").search_by_month_and_year(bulan, tahun).without_acessoris.without_bonus
    .not_equal_with_nosj.without_empty_brand.group(:cabang_id, :jenisbrgdisc, :customer).each do |lapcab|
      sales_brand = SalesCustomerByBrand.find_by_bulan_and_tahun_and_cabang_id_and_merk_and_customer(bulan, tahun, lapcab.cabang_id, lapcab.jenisbrgdisc, lapcab.customer)
      if sales_brand.nil?
        SalesCustomerByBrand.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar, :kode_customer => lapcab.kode_customer,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => combine_group(lapcab.jenisbrgdisc), :produk => lapcab.jenisbrg,
          :kode_produk => lapcab.kodejenis, :kode_artikel => lapcab.kodeartikel, :series => lapcab.namabrand,
          :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2,
          :city => lapcab.kota, :group_customer => lapcab.groupcust, :tipe_customer => lapcab.tipecust, :plankinggroup => lapcab.plankinggroup)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      end
    end
  end

  def self.sales_by_customer_by_brand_yearly(tahun)
    select("cabang_id, namaartikel, namakain, kodebrg,panjang, lebar, kodejenis, kodeartikel, kode_customer, namabrand, kota, groupcust, tipecust, plankinggroup,
customer, salesman, jenisbrgdisc, jenisbrg, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2")
    .without_acessoris.without_bonus.search_by_year(tahun).not_equal_with_nosj.without_empty_brand.group(:cabang_id, :jenisbrgdisc, :customer).each do |lapcab|
      sales_brand = SalesCustomerByBrandYear.find_by_tahun_and_cabang_id_and_merk_and_customer(tahun, lapcab.cabang_id, lapcab.jenisbrgdisc, lapcab.customer)
      if sales_brand.nil?
        SalesCustomerByBrandYear.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar, :kode_customer => lapcab.kode_customer,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => combine_group(lapcab.jenisbrgdisc), :produk => lapcab.jenisbrg,
          :kode_produk => lapcab.kodejenis, :kode_artikel => lapcab.kodeartikel, :series => lapcab.namabrand,
          :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2,
          :city => lapcab.kota, :group_customer => lapcab.groupcust, :tipe_customer => lapcab.tipecust, :plankinggroup => lapcab.plankinggroup)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      end
    end
  end

  def self.sales_by_fabric(bulan, tahun)
    select("cabang_id, namaartikel, namakain, kodebrg,panjang, lebar, kodejenis, kodeartikel,
customer, salesman, jenisbrgdisc, jenisbrg, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2")
    .without_acessoris.without_bonus.search_by_month_and_year(bulan, tahun).not_equal_with_nosj.group(:cabang_id, :jenisbrgdisc, :kodejenis, :kodeartikel, :namakain).each do |lapcab|
      sales_brand = SalesFabric.find_by_bulan_and_tahun_and_cabang_id_and_merk_and_kode_produk_and_kode_artikel_and_kain(bulan, tahun, lapcab.cabang_id, lapcab.jenisbrgdisc, lapcab.kodejenis, lapcab.kodeartikel, lapcab.namakain)
      if sales_brand.nil?
        SalesFabric.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => combine_group(lapcab.jenisbrgdisc), :produk => lapcab.jenisbrg,
          :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2,
          :kode_produk => lapcab.kodejenis, :kode_artikel => lapcab.kodeartikel)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      end
    end
  end

  def self.sales_by_article(bulan, tahun)
    select("cabang_id, namaartikel, namakain, kodebrg,panjang, lebar, kodejenis, kodeartikel,
customer, salesman, jenisbrgdisc, jenisbrg, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2")
    .without_acessoris.without_bonus.search_by_month_and_year(bulan, tahun).not_equal_with_nosj.group(:cabang_id, :jenisbrgdisc, :kodejenis, :kodeartikel).each do |lapcab|
      sales_brand = SalesArticle.find_by_bulan_and_tahun_and_cabang_id_and_merk_and_produk_and_artikel(bulan, tahun, lapcab.cabang_id, lapcab.jenisbrgdisc, lapcab.jenisbrg, lapcab.namaartikel)
      if sales_brand.nil?
        SalesArticle.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => combine_group(lapcab.jenisbrgdisc), :produk => lapcab.jenisbrg,
          :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2,
          :kode_produk => lapcab.kodejenis, :kode_artikel => lapcab.kodeartikel)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      end
    end
  end

  def self.sales_by_product(bulan, tahun)
    select("cabang_id, namaartikel, namakain, kodebrg, panjang, lebar, kodejenis, kodeartikel,
customer, salesman, jenisbrgdisc, jenisbrg, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2").without_bonus
    .search_by_month_and_year(bulan, tahun).not_equal_with_nosj.group(:cabang_id, :jenisbrgdisc, :kodeartikel, :kodejenis).each do |lapcab|
      sales_brand = SalesProduct.find_by_bulan_and_tahun_and_cabang_id_and_merk_and_kode_produk_and_kode_artikel(bulan, tahun, lapcab.cabang_id, lapcab.jenisbrgdisc, lapcab.kodejenis, lapcab.kodeartikel)
      if (lapcab.jenisbrg.include? ('Elite')) || (lapcab.jenisbrg.include? ('LA'))
        jenis = 'AC'
      else
        jenis = lapcab.kodejenis
      end
      if sales_brand.nil?
        SalesProduct.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => combine_group(lapcab.jenisbrgdisc), :produk => lapcab.jenisbrg,
          :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2,
          :kode_produk => jenis, :kode_artikel => lapcab.kodeartikel)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
      end
    end
  end

  def self.sales_by_brand_by_branch(bulan, tahun, branch)
    ActiveRecord::Base.transaction do
      select("cabang_id, namaartikel, namakain, kodebrg,panjang, lebar,
  customer, salesman, jenisbrgdisc, jenisbrg, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2").without_acessoris.without_bonus
      .search_by_month_and_year(bulan, tahun).search_by_branch(branch).not_equal_with_nosj.group(:cabang_id, :jenisbrgdisc).each do |lapcab|
        sales_brand = SalesBrand.find_by_bulan_and_tahun_and_cabang_id_and_merk(bulan, tahun, lapcab.cabang_id, lapcab.jenisbrgdisc)
        if sales_brand.nil?
          SalesBrand.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
            :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar,
            :customer => lapcab.customer, :sales => lapcab.salesman, :merk => lapcab.jenisbrgdisc, :produk => lapcab.jenisbrg,
            :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
        else
          sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2)
        end
      end
    end
  end

  def self.sales_by_brand(bulan, tahun)
    select("cabang_id, namaartikel, namakain, kodebrg, panjang, lebar,
customer, salesman, jenisbrgdisc, jenisbrg, tipecust, SUM(jumlah) as sum_jumlah, SUM(harganetto2) as sum_harganetto2").without_acessoris.without_bonus
    .search_by_month_and_year(bulan, tahun).not_equal_with_nosj.group(:cabang_id, :jenisbrgdisc, :tipecust).each do |lapcab|
      sales_brand = SalesBrand.find_by_bulan_and_tahun_and_cabang_id_and_merk_and_group_customer(bulan, tahun, lapcab.cabang_id, lapcab.jenisbrgdisc, lapcab.tipecust)
      if sales_brand.nil?
        SalesBrand.create(:cabang_id => lapcab.cabang_id, :artikel => lapcab.namaartikel, :kain => lapcab.namakain,
          :ukuran => lapcab.kodebrg[11,1], :panjang => lapcab.panjang, :lebar => lapcab.lebar,
          :customer => lapcab.customer, :sales => lapcab.salesman, :merk => combine_group(lapcab.jenisbrgdisc), :produk => lapcab.jenisbrg,
          :bulan => bulan, :tahun => tahun, :qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2, :group_customer => lapcab.tipecust)
      else
        sales_brand.update_attributes(:qty => lapcab.sum_jumlah, :val => lapcab.sum_harganetto2, :group_customer => lapcab.tipecust)
      end
    end
  end

  def self.create_new_artikel_from_report(bulan, tahun)
    LaporanCabang.where("month(tanggalsj) = ? and year(tanggalsj) = ?", bulan, tahun).each do |lap|
      unless lap.kodeartikel.nil?
        if Artikel.where("KodeCollection = ?", lap.kodeartikel).empty?
          Artikel.create(:KodeBrand => lap.kodeartikel[0,2],:KodeCollection => lap.kodeartikel,
            :Produk => lap.namaartikel, :KodeProduk => lap.kodebrg[0,2], :Aktif => 1)
        end
        if Kain.where("KodeKain = ?", lap.kodekain).empty? && (lap.namakain.present? || !lap.namakain.blank?)
          Kain.create(:KodeKain => lap.kodekain,:NamaKain => lap.namakain,
            :KodeCollection => lap.kodeartikel, :Aktif => 1)
        end
      end
    end
  end
  # end background_job

  def self.summary_of_sales(brand, jenis, cabang)
    select("sum(harganetto2) as sum_harganetto2, sum(jumlah) as sum_jumlah").brand(brand).search_by_branch(cabang).search_by_type(jenis).search_by_month_and_year(Date.today.month, Date.today.year).not_equal_with_nosj
  end

  def self.compare_price_list
    select("*").where("date(tanggal_upload) = ? and kodebrg not like ?",
      Date.yesterday, %(___________#{'T'}%)).no_pengajuan.nosj_to_check
  end

  def self.get_target_by_salesman(branch, date, merk, salesman)
    select("sum(jumlah) as sum_jumlah").search_by_month_and_year(date.to_date.month, date.to_date.year)
    .brand(merk).search_by_branch(branch).not_equal_with_nosj.customer_retail_all('all').salesman(salesman)
  end

  def self.get_target(branch, date, merk)
    select("sum(jumlah) as sum_jumlah").search_by_month_and_year(date.to_date.month, date.to_date.year).brand(merk).search_by_branch(branch).not_equal_with_nosj.customer_retail_all('all')
  end

  def self.standard(from, to, branch, type, brand, article, fabric, size, customer, size_type, customer_modern, group, customer_all_retail)
    select("sum(jumlah) as sum_jumlah, customer, kodebrg, namaartikel, tanggalsj,
					sum(harganetto2) as sum_harga, cabang_id, salesman, namakain, panjang, lebar, jumlah, id, jenisbrgdisc")
    .between_date_sales(from, to).search_by_branch(branch)
    .search_by_type(type).brand(brand).kode_barang_like(article)
    .fabric(fabric).size_length(size).customer(customer).customer_modern(customer_modern).customer_modern_all(customer_modern)
    .brand_size(size_type).not_equal_with_nosj.customer_retail_all(customer_all_retail).group(group)
  end

  def self.customer_quick_monthly(month, year, branch, brand)
    select("sum(jumlah) as sum_jumlah, customer, kota, sum(harganetto2) as sum_harganetto2")
    .search_by_month_and_year(month, year).search_by_branch(branch).not_equal_with_nosj.brand(brand).withou_mm
  end

  def self.monthly_report(month, branch, type, kode_brand, year, product_type, customer_all_retail)
    select("sum(jumlah) as sum_jumlah").search_by_month_and_year(month, year)
    .search_by_branch(branch)
    .search_by_type(type).search_by_article(kode_brand).not_equal_with_nosj.customer_retail_all(customer_all_retail)
  end

  def self.total_on_merk(merk, from, to)
    find(:all, :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
      :conditions => ["tanggalsj between ? and ? and kodebrg like ? and nosj not like ? and nosj not like ? and kodejenis not like ? and nosj not like ? and nosj not like ?",
        from, to, %(__#{merk}%), %(#{'SJB'}%), %(#{'SJY'}%), %(#{merk}%), %(#{'SJV'}%), %(#{'SJP'}%)])
  end

  def self.total_on(month, merk, year)
    where("YEAR(tanggalsj) = ? and MONTH(tanggalsj) = ? and kodebrg like ? and kodejenis not like ?
		and nosj not like ? and nosj not like ? and nosj not like ? and nosj not like ?", year, month, %(__#{merk}%), %(#{merk}%), %(#{'SJB'}%), %(#{'SJY'}%), %(#{'SJV'}%), %(#{'SJP'}%)).sum(:jumlah)
  end

  def self.growth(last, current)
    (Float(current - last) / last * 100)
  rescue ZeroDivisionError
    0
  end

  def self.growth_sales_target(last, current)
    (current.to_f / last.to_f) * 100
  rescue ZeroDivisionError
    0
  end

  def self.sum_of_brand_type(merk_id, cabang, cat, from, to)
    find(:all, :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
      :conditions => ["cabang_id = ? and kodebrg like ? and nosj not like ? and nosj not like ? and tanggalsj between ? and ? and nosj not like ? and nosj not like ?",
        cabang, "#{cat + merk_id}%", %(#{'SJB'}%), %(#{'SJY'}%), from.to_date, to.to_date, %(#{'SJV'}%), %(#{'SJP'}%)])
  end

  def self.weekly_sum_value(cat, from, to, channel)
    ch = channel == "DIRECT" ? "SHOWROOM" : channel
    select("sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2")
    .brand(cat).query_by_date(from.to_date, to.to_date).not_equal_with_nosj
    .without_acessoris.without_bonus.channel(ch)
  end

  def self.get_percentage(last_month, current_month)
    (current_month.to_f - last_month.to_f) / last_month.to_f * 100.0
  end
end
