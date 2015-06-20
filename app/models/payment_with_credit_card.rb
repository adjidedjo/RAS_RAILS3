class PaymentWithCreditCard < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "pos"
  set_table_name "payment_with_credit_cards"

  belongs_to :sale, inverse_of: :payment_with_credit_cards

  before_create do
    get_nama_merchant = Merchant.find_by_no_merchant(no_merchant)
    self.nama_merchant = get_nama_merchant.nil? ? '' : get_nama_merchant.nama
    get_mid = Merchant.find_by_mid(tenor)
    self.tenor = get_mid.nil? ? '' : get_mid.tenor
    self.mid = get_mid.nil? ? '' : get_mid.mid
  end
end