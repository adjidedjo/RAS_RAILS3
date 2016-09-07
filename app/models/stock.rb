class Stock < ActiveRecord::Base
  self.abstract_class = true
  #  establish_connection "sqlserver"
  set_table_name "tbstockcabang"
  belongs_to :cabang
  belongs_to :barang
  scope :control_stock, lambda {|date, jenis| where("tanggal = ? and kodebrg like ?", date, %(__#{jenis}%))}
  scope :check_branch, lambda {|cabang| where(:cabang_id => cabang)}

  scope :check_invoices, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
  scope :query_by_date, lambda {|from, to| where(:tanggalsj => from..to)}
  scope :query_by_single_date, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
  # scope for monthly/monthly
  scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
  scope :search_by_type, lambda {|type| where("kodebrg like ?", %(#{type}%)) if type.present? }
  scope :search_by_article, lambda { |article| where("kodebrg like ?", %(__#{article}%)) if article.present?}
  scope :search_by_month_and_year, lambda { |month, year| where("MONTH(tanggalsj) = ? and YEAR(tanggalsj) = ?", month, year)}
  scope :not_equal_with_nosj, where("nosj not like ? and nosj not like ? and nosj not like ?", %(#{'SJB'}%), %(#{'SJY'}%), %(#{'SJV'}%))
  scope :brand, lambda {|brand| where("kodebrg like ?", %(__#{brand}%)) if brand.present?}
  scope :brand_size, lambda {|brand_size| where("kodebrg like ?", %(___________#{brand_size}%)) if brand_size.present?}
  scope :between_date_sales, lambda { |from, to| where("tanggalsj between ? and ?", from, to) if from.present? && to.present? }
  scope :artikel, lambda {|artikel| where("kodebrg like ?", %(__#{artikel}%)) if artikel.present?}
  scope :customer, lambda {|customer| where("customer like ?", %(#{customer})) if customer.present? }
  scope :kode_barang, lambda {|kode_barang| where("kodebrg like ?", kode_barang) if kode_barang.present?}
  scope :kode_barang_like, lambda {|kode_barang| where("kodebrg like ?", %(%#{kode_barang}%)) if kode_barang.present?}
  scope :fabric, lambda {|fabric| where("kodebrg like ?", %(______#{fabric}%)) unless fabric.nil?}
  scope :size_length, lambda {|brand_size| where("kodebrg like ?", %(___________#{brand_size}%)) if brand_size.present? && brand_size != 'all'}
  scope :sum_jumlah, lambda {sum("jumlah")}
  scope :sum_amount, lambda {sum("harganetto2")}

  def self.check_stock_asongan(first_week, last_week, cabang)
    select("*").where("tanggal between ? and ? and cabang_id = ?", first_week, last_week, cabang)
  end

  def self.auto_stock_jde
    jde_branch_plan = ['11001', '11011', '11002', '11021', '11022']
    first_week_date = Date.today.beginning_of_week
    last_week_date = Date.today.end_of_week
    jde_branch_plan.each do |bp|
      stock = JdeItemAvailability.select("liitm as liitm, sum(lipqoh) as lipqoh, sum(lihcom) as lihcom").where("limcu like ? and lipqoh >= ?", "%#{bp}", 1).group("liitm")
      stock.each do |st|
        free = (st.lipqoh.to_i - st.lihcom.to_i).to_s
        real = (st.lipqoh.to_i + st.lihcom.to_i).to_i.to_s
        item_master = JdeItemMaster.where("imitm like ? and imtmpl like ?", st.liitm, "%BJ MATRASS%")
        if item_master.present?
          present_stock = Stock.find_by_kodebrg_and_tanggal_and_cabang_id(item_master.first.imaitm.strip, Date.today.strftime("%Y-%m-%d"), branch_plan(bp))
          if present_stock.nil?
            Stock.create(tanggal: Date.today.strftime("%Y-%m-%d"), cabang_id: branch_plan(bp), kodebrg: item_master.first.imaitm.strip, freestock: free[0, free.length-4],
              namabrg: ((item_master.first.imdsc1.strip)+" "+(item_master.first.imdsc2.strip)),
              outstandingSO: JdeSoDetail.outstanding_so(st.liitm, Date.today, (bp == '11002' ? '11012' : bp)).first.sduorg.to_s.gsub(/0/,""),
              realstock: real[0, real.length - 4])
          else
            present_stock.update_attributes!(freestock: free[0, free.length-4],
              outstandingSO: JdeSoDetail.outstanding_so(st.liitm, Date.today, (bp == '11002' ? '11012' : bp)).first.sduorg.to_s.gsub(/0/,""),
              realstock: real[0, real.length - 4])
          end
        end
      end
    end
  end

  def self.branch_plan(branch)
    if branch == '11011'
      2
    elsif branch == '11002'
      2
    elsif branch == '11021' || branch == '11022'
      9
    else
      1
    end
  end

  def self.check_stock(tanggal, branch, brand, type, article, fabric, size)
    select("*").control_stock(tanggal, brand).search_by_branch(branch).search_by_type(type)
    .search_by_article(article).fabric(fabric).size_length(size)
  end

  def self.find_barang_id(barang_id, cabang)
    find(:all, :select => "tanggal, cabang_id, kodebrg, freestock, bufferstock, realstock, realstockservice, realstockdowngrade",
      :conditions => ["kodebrg = ? and cabang_id = ?", barang_id, cabang])
  end

  def self.get_stock_in_branch(date, stock, cabang)
    check_stock(date).find_barang_id(stock, cabang)
  end

  def self.get_size_qty(kodebrg, cabang, date, size)
    find(:all, :select => "kodebrg, freestock, bufferstock, realstock, realstockservice, realstockdowngrade",
      :conditions => ["kodebrg like ? and kodebrg not like ? and cabang_id = ? and tanggal = ?", %(#{kodebrg + size}%), %(%#{'T'}%),
        cabang, date])
  end
end
