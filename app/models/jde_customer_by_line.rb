class JdeCustomerByLine < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f03012"
  #ai

  def self.get_group_customer(address_number, co)
    grup = where(aian8: address_number, aico: co)
    if grup.empty?
      '-'
    elsif grup.first.aisic.strip == 'DEA' || grup.first.aisic.strip == 'RET'
      'RETAIL'
    elsif grup.first.aisic.strip == 'SHO'
      'SHOWROOM'
    elsif grup.first.aisic.strip == 'MOD'
      'MODERN'
    elsif grup.first.aisic.strip == 'DIR'
      'DIRECT'
    else
      '-'
    end
  end
end
