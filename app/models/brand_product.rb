class BrandProduct < ActiveRecord::Base
  belongs_to :merk
  belongs_to :product
end
