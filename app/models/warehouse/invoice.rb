class Warehouse::Invoice < ActiveRecord::Base
  establish_connection "warehouse"
  self.table_name = "F03B11_INVOICES"
  
end
