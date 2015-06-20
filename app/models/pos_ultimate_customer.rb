class PosUltimateCustomer < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "pos"
  set_table_name "pos_ultimate_customers"

  has_many :sales
end
