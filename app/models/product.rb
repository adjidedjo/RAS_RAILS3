class Product < ActiveRecord::Base
  set_table_name "tbbjkodeproduk"
  belongs_to :merk
  belongs_to :brand
  belongs_to :artikel
  belongs_to :ukuran
  belongs_to :kain
  scope :get_product, :conditions => ['id > 4 AND id != 24']
end
