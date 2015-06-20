class PaymentWithDebitCard < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "pos"
  set_table_name "payment_with_debit_cards"

  belongs_to :sale, inverse_of: :payment_with_debit_card

  validates :no_kartu_debit, presence: true, if: :paid_with_debit?
  validates :nama_kartu, presence: true, if: :paid_with_debit?
  validates :atas_nama, presence: true, if: :paid_with_debit?

  def paid_with_debit?
    self.sale.tipe_pembayaran.split(";").include?("Debit Card")
  end
end
