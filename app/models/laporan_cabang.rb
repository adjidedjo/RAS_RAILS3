class LaporanCabang < ActiveRecord::Base
  set_table_name "tblaporancabang"
  set_primary_key "nofaktur"
  belongs_to :cabang
  scope :query_by_date, lambda {|from, to| where(:tanggalsj => from..to)}
  scope :by_category_items, lambda {|category, date, idcabang| where(:jenisbrgdisc => category, :tanggalfaktur => date, :idcabang => idcabang)}
  scope :query_by_year, lambda {|year| where("tanggalfaktur >= ? and tanggalfaktur <= ?", "#{year}-01-01", "#{year}-12-31")}
  scope :query_by_branch, lambda {|id_cabang| where(:idcabang => id_cabang)}
  
  def self.query_by_year_and_idcabang(year, idcabang)
    sum(:jumlah, :conditions => ["tanggalfaktur >= ? and tanggalfaktur <= ? and idcabang = ?", "#{year}-01-01", "#{year}-12-31", idcabang])
  end
end