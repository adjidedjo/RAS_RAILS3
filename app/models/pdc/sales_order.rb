class Pdc::SalesOrder < ActiveRecord::Base
  establish_connection "production_analysis"
  set_table_name "sales_orders"

end