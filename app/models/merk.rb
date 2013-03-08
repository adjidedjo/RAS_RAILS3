class Merk < ActiveRecord::Base
  set_table_name "tbbjmerk"
  has_many :product
  has_many :brand
end
