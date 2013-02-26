class Ukuran < ActiveRecord::Base
  set_table_name "tbbjkodeukuran"
  has_many :product
  scope :get_ukuran, :conditions => ['id != 8 AND id != 16 AND id != 24']
end
