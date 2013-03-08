class Brand < ActiveRecord::Base
  set_table_name "tbbjkodebrand"
  belongs_to :merk
  has_many :product
end