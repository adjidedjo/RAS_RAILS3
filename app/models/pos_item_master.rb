class PosItemMaster < ActiveRecord::Base
  establish_connection "pos"
  set_table_name "items"
end
