class Artikel < ActiveRecord::Base
  set_table_name "tbbjkodeartikel"
  has_many :product
end
