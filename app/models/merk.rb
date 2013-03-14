class Merk < ActiveRecord::Base
  set_table_name "tbbjmerk"
  has_many :merk_products
  has_many :product, :through => :merk_products
  has_many :brand
  scope :merk_name, lambda {|merk| where(:merk_id => merk)}
  
  def self.get_merk_name(merk_id)
    merk_name(merk_id).map{|merk| merk.Merk}.join(", ")
  end
end
