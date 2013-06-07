class Kain < ActiveRecord::Base
  set_table_name "tbbjkodekain"
  has_many :product
  scope :kain_name, lambda {|kain, collection| where("KodeKain like ? and KodeCollection like ?", kain, collection) unless kain.nil? }
end
