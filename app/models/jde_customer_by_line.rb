class JdeCustomerByLine < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f03012"
  #ai

  def self.get_group_customer(address_number, co)
   grup = where(aian8: address_number, aico: co)
   grup.empty? ? "" : grup.first.aicpgp
  end
end