class ProductArtikel < ActiveRecord::Base
  belongs_to :artikel
  belongs_to :product
end