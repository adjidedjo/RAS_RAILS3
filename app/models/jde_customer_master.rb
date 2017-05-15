class JdeCustomerMaster < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f0101"
  def self.get_group_customer(address_number)
    grup = where(aban8: address_number)
    if grup.empty?
      '-'
    elsif grup.first.absic.strip == 'DEA' || grup.first.absic.strip == 'RET'
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

  def self.find_salesman_name(salesman_id)
    find_by_sql("SELECT abalph FROM proddta.f0101 WHERE aban8 like '%#{salesman_id}%'").first.abalph.strip
  end

  def self.customer_import
    customer = find_by_sql("
      SELECT AI.aidaoj, AI.aian8, AB.abalph, AB.absic, AL.alcty1 FROM PRODDTA.F03012 AI
      LEFT JOIN (
        SELECT aban8, abalph, absic FROM PRODDTA.F0101
      ) AB ON AI.aian8 = AB.aban8
      LEFT JOIN
      (
        SELECT aladd1, alcty1, alan8 FROM PRODDTA.F0116
      ) AL ON AI.aian8 = AL.alan8
      WHERE AND AI.aico LIKE '%0000%' AND AI.aidaoj = '#{julian_to_date(Date.yesterday.to_date)}'
    ")
    customer.each do |nc|
      find_cus = Customer.where(addres_number: nc.aian8)
      if find_cus.nil?
        Customer.create!(address_number: nc.aian8, name: nc.abalph.strip, i_class: nc.absic.strip, 
          city: nc.alcty1.strip, opened_date: julian_to_date(nc.aidaoj))
      end
    end
  end
  
  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end

  def self.julian_to_date(jd_date)
    if jd_date.nil? || jd_date == 0
      0
    else
      Date.parse((jd_date+1900000).to_s, 'YYYYYDDD')
    end
  end
end
