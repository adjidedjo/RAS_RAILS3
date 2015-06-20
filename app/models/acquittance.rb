class Acquittance < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "pos"
  set_table_name "acquittances"

  has_one :acquittance_with_debit_card, dependent: :destroy
  accepts_nested_attributes_for :acquittance_with_debit_card
  has_many :acquittance_with_credit_cards, dependent: :destroy
  accepts_nested_attributes_for :acquittance_with_credit_cards
  belongs_to :bank_account
  belongs_to :sale
  belongs_to :channel_customer

  validates :transfer_amount, presence: true, numericality: true, if: :paid_with_transfer?
  validates :bank_account_id, presence: true, if: :paid_with_transfer?
  validates :cash_amount, numericality: true, if: :paid_with_cash?
  validates :method_of_payment, presence: true

  def paid_with_cash?
    method_of_payment.split(";").include?("Tunai")
  end

  def paid_with_transfer?
    method_of_payment.split(";").include?("Transfer")
  end

  before_create do
    self.exported_at = Time.now
    self.no_reference = loop do
      random_token = 'AQ' + Digest::SHA1.hexdigest([Time.now, rand].join)[0..8].upcase
      break random_token unless Acquittance.exists?(no_reference: random_token)
    end
    self.sale_id = Sale.where(no_so: no_so).first.id
  end

  after_create do
    self.exported = true
    total_pelunasan = self.cash_amount + self.transfer_amount
    debit_card = self.acquittance_with_debit_card.jumlah
    credit_card = self.acquittance_with_credit_cards.sum(:jumlah)
    sisa_pelunasan = self.sale.sisa.to_i - (total_pelunasan + debit_card + credit_card)
    c_bayar = sisa_pelunasan == 0 ? 'lunas' : 'um'
    self.sale.update_attributes!(sisa: sisa_pelunasan, cara_bayar: c_bayar)
  end
end
