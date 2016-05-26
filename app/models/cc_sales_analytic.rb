class CcSalesAnalytic < ActiveRecord::Base
  self.abstract_class = true
  set_table_name "channel_customers"
end
