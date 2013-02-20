class Stock < ActiveRecord::Base
  set_table_name "tbstockcabang"
  belongs_to :cabang
  scope :check_stock, lambda {|date| where(:tanggal => date)}
end
