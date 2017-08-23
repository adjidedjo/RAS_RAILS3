class JdeSalesman < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f40344" #sa
  
  def self.find_salesman(customer_id, brand)
    commision_table = find_by_sql("SELECT saslsm FROM proddta.f40344 WHERE saan8 like '%#{customer_id}%' 
    AND sait44 like '#{brand}%' AND saexdj > '#{date_to_julian(Date.today.to_date)}'")
    salesman_name = commision_table.present? ? JdeCustomerMaster.find_salesman_name(commision_table.first.saslsm.to_i) : '-'
    return salesman_name
  end
  
  def self.find_salesman_id(customer_id, brand)
    commision_table = find_by_sql("SELECT saslsm FROM proddta.f40344 WHERE saan8 like '%#{customer_id}%' 
    AND sait44 like '#{brand}%' AND saexdj > '#{date_to_julian(Date.today.to_date)}'")
    salesman_id = commision_table.present? ? commision_table.first.saslsm.to_i : '-'
    return salesman_id
  end

  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end
  
  def self.customer_brands
    commision_table = find_by_sql("SELECT saan8, sait44 FROM proddta.f40344 WHERE
    saexdj > '#{date_to_julian(Date.today.to_date)}'")
    commision_table.each do |ct|
      cb = CustomerBrand.where(address_number: ct.saan8.to_i, brand: convert_brand(ct.sait44.strip))
      CustomerBrand.create!(address_number: ct.saan8.to_i, brand: convert_brand(ct.sait44.strip)) if cb.empty?
    end
  end
  
  def self.upgrated_customer_brands
    CustomerBrand.where("id >= 2020").each do |cb|
      a = LaporanCabang.where(fiscal_year: '2017', kode_customer: cb.address_number, jenisbrgdisc: cb.brand).last
      cb.update_attributes!(branch: a.area_id, customer: a.customer) unless a.nil?
    end
  end
  
  def self.convert_brand(brand)
    if brand == 'S'
      'SERENITY'
    elsif brand == 'E'
      'ELITE'
    elsif brand == 'L'
      'LADY'
    elsif brand == 'R'
      'ROYAL'
    else
      'NOBRAND'
    end
  end
end