class Pdc::SalesOrder < ActiveRecord::Base
  establish_connection "production-analysis"
  set_table_name "sales_orders"

end