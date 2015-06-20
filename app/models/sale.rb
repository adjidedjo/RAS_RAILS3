class Sale < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "pos"
  set_table_name "sales"

  after_initialize :set_defaults
  has_many :sale_items, inverse_of: :sale, dependent: :destroy
  has_one :payment_with_debit_card, inverse_of: :sale, dependent: :destroy
  accepts_nested_attributes_for :payment_with_debit_card
  has_many :payment_with_credit_cards, inverse_of: :sale, dependent: :destroy
  accepts_nested_attributes_for :payment_with_credit_cards
  accepts_nested_attributes_for :sale_items, reject_if: proc { |a| a['kode_barang'].blank?}
  has_many :netto_sale_brands
  has_many :brands, through: :netto_sale_brands
  has_many :acquittances, dependent: :destroy
  belongs_to :branch
  belongs_to :salesman
  belongs_to :item
  belongs_to :store
  belongs_to :showroom
  belongs_to :channel
  belongs_to :supervisor_exhibition
  belongs_to :sales_promotion
  belongs_to :channel_customer
  belongs_to :pos_ultimate_customer
  belongs_to :bank_account

  has_paper_trail

  attr_accessor :nama, :email, :alamat, :kota, :no_telepon, :handphone, :handphone1

  validates :netto, :tanggal_kirim, :netto_elite, :netto_lady, :voucher, :jumlah_transfer, presence: true
  validates :nama, :email, :alamat, :kota, :no_telepon, presence: true, on: :create
  validates :sale_items, presence: true, on: :create
  validates :so_manual, length: { maximum: 200 }, on: :create
  #  validates :no_kartu_debit, presence: true, if: :paid_with_debit?
  #  validates :jumlah_transfer, numericality: true, if: :paid_with_transfer?

  validate :uniqueness_of_items

  def uniqueness_of_items
    hash = {}
    sale_items.each do |si|
      if hash[si.kode_barang]
        errors.add(:"si.kode_barang", "duplicate error")
        si.errors.add(:kode_barang, "has already been taken")
      end
      hash[si.kode_barang] = true
    end
  end

  before_update do
    puc = {
      email: email,
      nama: nama,
      no_telepon: no_telepon,
      handphone: handphone,
      handphone1: handphone1,
      alamat: alamat,
      kota: kota
    }
    if no_telepon.present?
      ultimate_customer = PosUltimateCustomer.where("no_telepon like ?", no_telepon)
      if ultimate_customer.empty?
        puc[:nama] = nama.titleize
        PosUltimateCustomer.create(puc)
      else
        ultimate_customer.first.update_attributes!(puc)
      end
      self.pos_ultimate_customer_id = ultimate_customer.first.id
    end
  end

  def self.set_exported_items(sale_item)
    sale_item.each do |a|
      get_sale = Sale.find(a)
      if get_sale.sale_items.where(exported: false).blank?
        get_sale.update_attributes!(all_items_exported: true)
      end
    end
  end

  def ultimate_customer_name
    ultimate_customer.try(:name)
  end

  def ultimate_customer_name=(name)
    self.ultimate_customer_id = PosUltimateCustomer.find_or_create_by_nama(name).id if name.present?
  end

  def set_defaults
    self.voucher = 0 if self.voucher.nil?
    self.netto = 0 if self.voucher.nil?
    self.pembayaran = 0 if self.voucher.nil?
  end

  before_create do
    #    get_no_sale = Sale.where(store_id: self.store_id).size
    #    get_no_sale.nil? ? (self.no_sale = 1) : (self.no_sale = get_no_sale + 1)
    #    no_sale = self.no_sale.to_s.rjust(4, '0')
    #    bulan = Date.today.strftime('%m')
    #    tahun = Date.today.strftime('%y')
    #    kode_customer = self.store.kode_customer
    #    kode_cabang = self.store.branch.id.to_s.rjust(2, '0')
    #
    # create ultimate customer
    puc = {
      email: email,
      no_telepon: no_telepon,
      handphone: handphone,
      handphone1: handphone1,
      alamat: alamat,
      kota: kota
    }
    ultimate_customer = PosUltimateCustomer.where("no_telepon like ?", no_telepon)
    if ultimate_customer.empty?
      puc[:nama] = nama.titleize
      PosUltimateCustomer.create(puc)
    else
      ultimate_customer.first.update_attributes!(puc)
    end
    self.pos_ultimate_customer_id = ultimate_customer.first.id
    # end create
    first_code = ChannelCustomer.find(channel_customer_id).channel.kode
    self.no_so = loop do
      random_token = first_code.upcase + Digest::SHA1.hexdigest([Time.now, rand].join)[0..8].upcase
      break random_token unless Sale.exists?(no_so: random_token.upcase)
    end
    self.voucher = voucher.nil? ? 0 : voucher
  end

  after_create do
    debit = self.payment_with_debit_card.jumlah.nil? ? 0 : self.payment_with_debit_card.jumlah
    credit = self.payment_with_credit_cards.nil? ? 0 : self.payment_with_credit_cards.sum(:jumlah)
    tunai = self.pembayaran
    transfer = self.jumlah_transfer.nil? ? 0 : self.jumlah_transfer
    total_bayar = debit + credit + tunai + transfer
    ket_lunas = total_bayar < (netto-self.voucher) ? 'um' : 'lunas'
    self.update_attributes!(cara_bayar: ket_lunas)
  end

  def paid_with_credit?
    tipe_pembayaran.split(";").include?("Credit Card")
  end

  def paid_with_debit?
    tipe_pembayaran.split(";").include?("Debit Card")
  end

  def paid_with_transfer?
    tipe_pembayaran.split(";").include?("Transfer")
  end
end