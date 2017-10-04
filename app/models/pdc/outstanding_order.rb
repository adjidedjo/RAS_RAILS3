class Pdc::OutstandingOrder < ActiveRecord::Base
  establish_connection "production_analysis"
  set_table_name "outstanding_orders"

end