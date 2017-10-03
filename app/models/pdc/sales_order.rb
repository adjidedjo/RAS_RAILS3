class Pdc::SalesOrder < ActiveRecord::Base
  establish_connection "production"
  set_table_name "sales_orders"

end