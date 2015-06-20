class SalesPromotion < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "pos"
  set_table_name "sales_promotions"

  has_one :user, dependent: :destroy
  has_one :sale, dependent: :destroy
  belongs_to :store
  belongs_to :showroom
  belongs_to :channel_customer

  before_create do
    self.nama = nama.downcase
    if nama.present?
      regexp = '*12345'
      self.regex = regexp
      if email.empty?
        self.email = nama.downcase.gsub(' ','')+'@ras.co.id'
      end
    end
  end
end