class JdeAddressByDate < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f0116"
  #al

  def self.get_city(address_number)
    where(alan8: address_number).first.alcty1.strip
  end
end
