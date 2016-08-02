class BcpChannelCustomer < ActiveRecord::Base
  establish_connection "bcp"
  set_table_name "channel_customers"
end
