class Brand < ActiveRecord::Base
  set_table_name "tbbjkodebrand"
  belongs_to :merk
  has_many :laporan_cabang
  # #has_many :brand_products #has_many :product, :through => :brand_products
  scope :brand_name, lambda {|brand| where(:KodeBrand => brand)}
  scope :brand_id, lambda {|brand| where(["KodeBrand like ?", %(#{brand}%)])}

  def self.get_brand_name(brand_id)
    brand_name(brand_id).map{|namabrand| namabrand.NamaBrand}.join(",")
  end
end