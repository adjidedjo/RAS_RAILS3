class Regional < ActiveRecord::Base
  has_many :cabang, :through => :regional_branches
  has_many :regional_branches

  validates :nama, :presence => true
  validates :brand_id, :presence => true
  validates :nama, :uniqueness => {:scope => [:nama, :brand_id]}

  before_destroy :set_regional_id
  
  def self.update_harga
    @harga = FuturePriceList.where("harga_starting_at = ?", Date.today)
    unless @harga.empty?
      @harga.each do |harga|
        PriceList.where(kode_barang: harga.kode_barang, regional_id: harga.regional_id).each do |list|
          list.update_attributes!(:prev_harga => list.harga)
          list.update_attributes!(:harga => harga.harga)
        end
      end
    end
  end

  def self.update_discount
    @discount = FuturePriceList.where("discount_starting_at = ?", Date.today)
    unless @discount.empty?
      @discount.each do |discount|
        PriceList.where(kode_barang: discount.kode_barang, regional_id: discount.regional_id).each do |list|
          list.update_attributes!(:prev_discount_1 => list.discount_1, :prev_discount_2 => list.discount_2,
            :prev_discount_3 => list.discount_3, :prev_discount_4 => list.discount_4)
          list.update_attributes!(:discount_1 => discount.discount_1, :discount_2 => discount.discount_2,
            :discount_3 => discount.discount_3, :discount_4 => discount.discount_4)
        end
      end
    end
  end

  def self.update_upgrade
    @upgrade = FuturePriceList.where("upgrade_starting_at = ?", Date.today)
    unless @upgrade.empty?
      @upgrade.each do |upgrade|
        PriceList.where(kode_barang: upgrade.kode_barang, regional_id: upgrade.regional_id).each do |list|
          list.update_attributes!(:prev_upgrade => list.upgrade)
          list.update_attributes!(:upgrade => upgrade.upgrade)
        end
      end
    end
  end

  def self.update_cashback
    @cashback = FuturePriceList.where("cashback_starting_at = ?", Date.today)
    unless @cashback.empty?
      @cashback.each do |cashback|
        PriceList.where(kode_barang: cashback.kode_barang, regional_id: cashback.regional_id).each do |list|
          list.update_attributes!(:prev_cashback => list.cashback)
          list.update_attributes!(:cashback => cashback.cashback)
        end
      end
    end
  end

  def self.update_special_price
    @special_price = FuturePriceList.where("special_price_starting_at = ?", Date.today)
    unless @special_price.empty?
      @special_price.each do |price|
        PriceList.where(kode_barang: price.kode_barang, regional_id: price.regional_id).each do |list|
          list.update_attributes!(:prev_special_price => list.special_price)
          list.update_attributes!(:special_price => price.special_price)
        end
      end
    end
  end

  private
  def set_regional_id
    Cabang.where("regional_id = ?", self.id).each do |cabang|
      cabang.update_attributes(:regional_id => nil)
    end
  end
end