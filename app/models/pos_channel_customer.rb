class PosChannelCustomer < ActiveRecord::Base
  establish_connection "pos"
  set_table_name "channel_customers"
end