class Regional < ActiveRecord::Base
  has_many :cabang, :through => :regional_branches
  has_many :regional_branches
  
  validates :nama, :presence => true
  validates :brand_id, :presence => true
  validates :nama, :uniqueness => {:scope => [:nama, :brand_id]}
  
  before_destroy :set_regional_id
  
  def self.update_harga
    @harga = FuturePriceList.where("harga_starting_at = ?", Date.today)
    
    @harga.each do |harga|
      PriceList.where(produk: harga.produk, regional_id: harga.regional_id, jenis: harga.jenis, lebar: harga.lebar).each do |list|
        list.update_attributes!(:harga => harga.harga)
      end
    end
  end
  
  def self.update_discount
    @discount = FuturePriceList.where("discount_starting_at = ?", Date.today)
    
    @discount.each do |discount|
      PriceList.where(produk: discount.produk, regional_id: discount.regional_id, jenis: discount.jenis, lebar: discount.lebar).each do |list|
        list.update_attributes!(:discount_1 => discount.discount_1, :discount_2 => discount.discount_2, 
        :discount_3 => discount.discount_3, :discount_4 => discount.discount_4)
      end
    end
  end
  
  def self.update_upgrade
    @upgrade = FuturePriceList.where("upgrade_starting_at = ?", Date.today)
    
    @upgrade.each do |upgrade|
      PriceList.where(produk: upgrade.produk, regional_id: upgrade.regional_id, jenis: upgrade.jenis, lebar: upgrade.lebar).each do |list|
        list.update_attributes!(:upgrade => upgrade.upgrade)
      end
    end
  end
  
  def self.update_cashback
    @cashback = FuturePriceList.where("cashback_starting_at = ?", Date.today)
    
    @cashback.each do |cashback|
      PriceList.where(produk: cashback.produk, regional_id: cashback.regional_id, jenis: cashback.jenis, lebar: cashback.lebar).each do |list|
        list.update_attributes!(:cashback => cashback.cashback)
      end
    end
  end
  
  def self.update_special_price
    @special_price = FuturePriceList.where("special_price_starting_at = ?", Date.today)
    
    @special_price.each do |price|
      PriceList.where(produk: price.produk, regional_id: price.regional_id, jenis: price.jenis, lebar: price.lebar).each do |list|
        list.update_attributes!(:special_price => price.special_price)
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