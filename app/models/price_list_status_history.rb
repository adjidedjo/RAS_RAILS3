class PriceListStatusHistory < ActiveRecord::Base
  has_paper_trail
  belongs_to :price_list, inverse_of: :price_list_status_histories
end