class ItemStatus < ActiveRecord::Base
  has_many :price_list_status_histories
  has_many :price_lists, through: :price_list_status_histories
end