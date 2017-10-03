class Pdc::OutstandingOrder < ActiveRecord::Base
  establish_connection "production"
  set_table_name "outstanding_orders"

end