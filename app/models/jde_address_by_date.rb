class JdeAddressByDate < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.f0116"
  #al

  def self.get_city(address_number)
    city = where(alan8: address_number)
    city.first.alcty1.nil? ? '-' : city.first.alcty1.strip
  end
end
