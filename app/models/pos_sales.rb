class PosAutoIntransit < ActiveRecord::Base
  establish_connection "pos"
  set_table_name "sales"
  
end