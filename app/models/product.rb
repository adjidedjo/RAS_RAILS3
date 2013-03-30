class Product < ActiveRecord::Base
  set_table_name "tbbjkodeproduk"
  has_many :brand_products
  has_many :brand, :through => :brand_products
  has_many :artikel
  belongs_to :merk
  belongs_to :ukuran
  belongs_to :kain
  scope :get_product, :conditions => ['id > 4 AND id != 24']
	scope :product_name, lambda {|product| where(:KodeProduk => product)}
end
