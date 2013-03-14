class Kain < ActiveRecord::Base
  set_table_name "tbbjkodekain"
  has_many :product
  scope :kain_name, lambda {|kain| where(:KodeKain => kain)}
end
