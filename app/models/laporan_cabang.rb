class LaporanCabang < ActiveRecord::Base
  set_table_name "tblaporancabang"
  belongs_to :cabang
  scope :query_by_date, lambda {|from, to| where(:tanggalsj => from..to)}
  scope :by_category_items, lambda {|category, date, cabang_id| where(:jenisbrgdisc => category,
      :tanggalfaktur => date, :cabang_id => cabang_id)}
  scope :query_by_year, lambda {|year| where("tanggalfaktur >= ? and tanggalfaktur <= ?",
      "#{year}-01-01", "#{year}-12-31")}
  scope :query_by_branch, lambda {|id_cabang| where(:cabang_id => id_cabang).order("tanggalsj desc")}
  scope :check_invoices, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
  scope :by_jenisbrg, lambda {|jenis| where(:jenisbrgdisc => jenis).order("tanggalsj desc")}
  scope :query_by_single_date, lambda {|date| where(:tanggalsj => date).order("tanggalsj desc")}
  scope :remove_cab, where("customer not like ?","#{'CAB'}%")

  def self.sum_of_brand(cabang, merk, from, to)
    find(:all, :conditions => ["cabang_id = ? and jenisbrgdisc = ? and customer not like ? and tanggalsj between ? and ?",
        cabang, merk, 'cab%', from.to_date, to.to_date],
      :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2")
  end

	def self.sum_of_category(cabang, cat, from, to)
    find(:all, :conditions => ["cabang_id = ? and kodebrg like ? and customer not like ? and tanggalsj between ? and ?",
        cabang, "%#{cat}%", 'cab%', from.to_date, to.to_date],
      :select => "sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2")
  end

  def self.jenisbrgdisc_by_user(from, to, user)
    unless user.merk.nil?
      get_record(from, to).find(:jenisbrgdisc => user.merk.Merk)
    else
      get_record(from, to)
    end
  end
  
	def self.get_record(from, to, user)
    unless user.merk.nil?
      find(:all, :conditions => ["jenisbrgdisc = ? and customer not like ? and tanggalsj between ? and ?",
          "Classic", 'cab%', from.to_date, to.to_date],
        :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg")
    else
      find(:all, :conditions => ["customer not like ? and tanggalsj between ? and ?", 'cab%',
          from.to_date, to.to_date],
        :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg")
    end
  end

  def self.query_by_year_and_cabang_id(year, cabang_id)
    sum(:jumlah, :conditions => ["tanggalfaktur >= ? and tanggalfaktur <= ? and cabang_id = ?",
        "#{year}-01-01", "#{year}-12-31", cabang_id])
  end
  
  def self.monthly_sum_last_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc = ?",
        get_last_month_on_last_year(date), 1.year.ago(date), jenis ]).to_i
  end
  
  def self.monthly_sum_current_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc = ?",
        get_last_month_on_current_year(date), date, jenis ]).to_i
  end
  
  def self.yearly_sum_last_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc = ?",
        get_beginning_of_year_on_last_year(date), 1.year.ago(date), jenis ]).to_i
  end
  
  def self.yearly_sum_current_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc = ?",
        get_beginning_of_year_on_current_year(date), date, jenis ]).to_i
  end

  #calculation serenity and non serenity

  def self.calculation_serenity_and_non_serenity(date, date_helper)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["tanggalsj between ? and ? and jenisbrgdisc in (?)",
        date, date_helper,["Serenity", "Non Serenity"]])[0].sum_harga.to_i
  end
  
  def self.monthly_sum_last_year_multiple_jenis(date)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["tanggalsj between ? and ? and jenisbrgdisc in (?)",
        get_last_month_on_last_year(date), 1.year.ago(date),
        ["Serenity", "Non Serenity"]])[0].sum_harga.to_i
  end
  
  def self.monthly_sum_current_year_multiple_jenis(date)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["tanggalsj between ? and ? and jenisbrgdisc in (?)",
        get_last_month_on_current_year(date), date,
        ["Serenity", "Non Serenity"]])[0].sum_harga.to_i
  end
  
  def self.yearly_sum_last_year_multiple_jenis(date)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["tanggalsj between ? and ? and jenisbrgdisc in (?)",
        get_beginning_of_year_on_last_year(date), 1.year.ago(date),
        ["Serenity", "Non Serenity"]])[0].sum_harga.to_i
  end
  
  def self.yearly_sum_current_year_multiple_jenis(date)
    find(:all, :select => "sum(harganetto2) as sum_harga",
      :conditions => ["tanggalsj between ? and ? and jenisbrgdisc in (?)",
        get_beginning_of_year_on_current_year(date), date,
        ["Serenity", "Non Serenity"]])[0].sum_harga.to_i
  end
  
  def self.weekly_sum_last_year(from, to, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc = ?",
        from, to, jenis ], :order => "id").to_i
  end
  
  # year and month
  def self.get_last_month_on_last_year(date)
    1.year.ago(date.to_date.beginning_of_month).to_date
  end
  
  def self.get_last_month_on_current_year(date)
    date.to_date.beginning_of_month.to_date
  end
  
  def self.get_beginning_of_year_on_last_year(date)
    1.year.ago(date.to_date.beginning_of_year).to_date
  end
  
  def self.get_beginning_of_year_on_current_year(date)
    date.to_date.beginning_of_year.to_date
  end
  
  # week
  def self.last_week_on_last_year(date)
    1.year.ago(1.weeks.ago(date.to_date - 6.days)).to_date
  end
  
  def self.week_on_last_year(date)
    1.year.ago(date.to_date).to_date
  end
  
  def self.last_week_on_current_year(date)
    1.weeks.ago(date.to_date - 6.days).to_date
  end
  
  def self.week_on_current_year(date)
    (date - 6.days).to_date
  end
  
  def self.get_percentage(last_month, current_month)
    (current_month.to_f - last_month.to_f) / last_month.to_f * 100.0
  end
  
  #calculate week for classic brand
  def self.weekly_sum_last_week_on_last_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc = ?",
        last_week_on_last_year(date), 1.year.ago(1.weeks.ago(date.to_date)).to_date, jenis ]).to_i
  end
  
  def self.weekly_sum_last_week_on_current_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc = ?",
        last_week_on_current_year(date), 1.weeks.ago(date.to_date).to_date, jenis ]).to_i
  end
  
  def self.weekly_sum_week_on_last_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc = ?",
        week_on_last_year(date), 1.year.ago(date.to_date).to_date, jenis ]).to_i
  end
  
  def self.weekly_sum_week_on_current_year(date, jenis)
    sum(:harganetto2, :conditions => ["tanggalsj between ? and ? and jenisbrgdisc = ?",
        week_on_current_year(date), date.to_date, jenis ]).to_i
  end
 
end
