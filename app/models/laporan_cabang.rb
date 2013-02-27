class LaporanCabang < ActiveRecord::Base
  set_table_name "tblaporancabang"
  set_primary_key "nofaktur"
  belongs_to :cabang
  scope :query_by_date, lambda {|from, to| where(:tanggalsj => from..to)}
  scope :by_category_items, lambda {|category, date, cabang_id| where(:jenisbrgdisc => category, :tanggalfaktur => date, :cabang_id => cabang_id)}
  scope :query_by_year, lambda {|year| where("tanggalfaktur >= ? and tanggalfaktur <= ?", "#{year}-01-01", "#{year}-12-31")}
  scope :query_by_branch, lambda {|id_cabang| where(:cabang_id => id_cabang)}
  scope :check_invoices, lambda {|date| where(:tanggalsj => date)}
  scope :query_classic, :conditions => ['jenisbrgdisc = ?', "Classic"]
  scope :query_by_single_date, lambda {|date| where(:tanggalsj => date)}
  
  def self.query_by_year_and_cabang_id(year, cabang_id)
    sum(:jumlah, :conditions => ["tanggalfaktur >= ? and tanggalfaktur <= ? and cabang_id = ?", "#{year}-01-01", "#{year}-12-31", cabang_id])
  end
  
  def self.summaries(date)
    sum(:harganetto2, :conditions => {:tanggalsj => date})
  end
  
  def self.monthly_sum_last_year(date)
    query_by_date(get_last_month_on_last_year(date), date).sum(:harganetto2).to_i
  end
  
  def self.monthly_sum_current_year(date)
    query_by_date(get_last_month_on_current_year(date), date).sum(:harganetto2).to_i
  end
  
  def self.yearly_sum_last_year(date)
    query_by_date(get_beginning_of_year_on_last_year(date), date).sum(:harganetto2).to_i
  end
  
  def self.yearly_sum_current_year(date)
    query_by_date(get_beginning_of_year_on_current_year(date), date).sum(:harganetto2).to_i
  end
  
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
 
end