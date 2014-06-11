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

  def self.merk_all(current_user)
    if current_user.user_brand == "Admin"
      Merk.all
    elsif current_user.user_brand == "Elite"
      Merk.where("Merk in (?)", ["Non Serenity","Serenity"])
    else
      Merk.where("Merk like ?", current_user.user_brand)
    end
    #current_user.user_brand == "Admin" ? Merk.all : Merk.where("Merk like ?", current_user.user_brand)
  end
end
