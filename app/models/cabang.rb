class Cabang < ActiveRecord::Base
  set_table_name "tbidcabang"
  has_many :stock
  has_many :barang,  :through => :stock
  has_many :laporan_cabang
  
  def self.get_id
    find(2, 3, 4, 5, 7, 8, 9, 10, 11, 13, 19, 20, 22)
  end
  
end