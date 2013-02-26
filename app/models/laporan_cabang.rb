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
  
  def self.query_by_year_and_cabang_id(year, cabang_id)
    sum(:jumlah, :conditions => ["tanggalfaktur >= ? and tanggalfaktur <= ? and cabang_id = ?", "#{year}-01-01", "#{year}-12-31", cabang_id])
  end
end