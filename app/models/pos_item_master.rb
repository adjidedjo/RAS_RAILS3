class PosItemMaster < ActiveRecord::Base
  establish_connection "pos"
  set_table_name "item_masters"
end
