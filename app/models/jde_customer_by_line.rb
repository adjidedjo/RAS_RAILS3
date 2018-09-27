class JdeCustomerByLine < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F0116"
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
    elsif grup.first.aisic.strip == 'PRO'
      'PROJECT'
    else
      '-'
    end
  end
end
