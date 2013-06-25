class Kain < ActiveRecord::Base
  set_table_name "tbbjkodekain"
  has_many :product
  scope :kain_name, lambda {|kain, collection| where("KodeKain like ? and KodeCollection like ?", kain, collection) unless kain.nil? }
  scope :get_kain_name, lambda {|collection| where("KodeCollection like ?", collection) unless collection.nil? }
  scope :kain_name_from_code, lambda {|collection| where("KodeKain like ?", collection) unless collection.nil? }
end
