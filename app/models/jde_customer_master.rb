class JdeCustomerMaster < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f0101"
  def self.get_group_customer(address_number)
    grup = where(aban8: address_number)
    if grup.empty?
      '-'
    elsif grup.first.absic.strip == 'DEA' || grup.first.aisic.strip == 'RET'
      'RETAIL'
    elsif grup.first.absic.strip == 'SHO'
      'SHOWROOM'
    elsif grup.first.absic.strip == 'MOD'
      'MODERN'
    elsif grup.first.absic.strip == 'DIR'
      'DIRECT'
    else
      '-'
    end
  end
end
