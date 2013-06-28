class Merk < ActiveRecord::Base
  set_table_name "tbbjmerk"
  has_many :user
  has_many :brand_products
  has_many :product, :through => :brand_products
  has_many :brand
  scope :merk_name, lambda {|merk| where(:IdMerk => merk)}
  
  def self.get_merk_name(merk_id)
    merk_name(merk_id).map{|merk| merk.Merk}.join(", ")
  end

  def self.merk_all_name
    tabel = Merk.all
  end

  def self.merk_all
    Merk.all
  end
end
