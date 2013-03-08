class Barang < ActiveRecord::Base
  set_table_name "tbbjbarang"
  has_many :stock
  has_many :cabang, :through => :stock
end