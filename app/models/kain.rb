class Kain < ActiveRecord::Base
  set_table_name "tbbjkodekain"
  has_many :product
end
