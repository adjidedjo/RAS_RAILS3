class Stock < ActiveRecord::Base
  set_table_name "TbStockCabang"
  scope :query_by_date, lambda {|from, to| where(:tanggalfaktur => from..to)}
  
end
