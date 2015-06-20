class Channel < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "pos"
  set_table_name "channels"

  has_many :stores, dependent: :destroy
  has_many :sales, dependent: :destroy
  has_many :showrooms, dependent: :destroy
  has_many :channel_customers, dependent: :destroy
end
