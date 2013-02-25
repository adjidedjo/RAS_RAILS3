class Stock < ActiveRecord::Base
  set_table_name "tbstockcabang"
  belongs_to :cabang
  scope :check_stock, lambda {|date| where(:tanggal => date)}
  scope :find_kodebrg, lambda {|kodebrg| where(:kodebrg => kodebrg)}
  scope :find_cabang_id, lambda {|cabang_id| where(:cabang_id => cabang_id)}
  
  def self.get_stock_in_branch(date, cabang, stock)
    check_stock(date).find_cabang_id(cabang).find_kodebrg(stock.kodebrg)
  end
end
