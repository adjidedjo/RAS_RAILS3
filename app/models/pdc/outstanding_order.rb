class Pdc::OutstandingOrder < ActiveRecord::Base
  establish_connection "production-analysis"
  set_table_name "outstanding_orders"

end