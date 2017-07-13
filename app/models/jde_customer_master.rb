class JdeCustomerMaster < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f0101"
  def self.get_group_customer(address_number)
    grup = where(aban8: address_number)
    if grup.first.absic.strip == 'DEA' || grup.first.absic.strip == 'RET'
      'RETAIL'
    elsif grup.first.absic.strip == 'SHO'
      'SHOWROOM'
    elsif grup.first.absic.strip == 'MOD'
      'MODERN'
    elsif grup.first.absic.strip == 'DIR'
      'DIRECT'
    elsif grup.first.absic.strip == 'PRO'
      'PROJECT'
    else
      '-'
    end
  end

  def self.find_salesman_name(salesman_id)
    find_by_sql("SELECT abalph FROM proddta.f0101 WHERE aban8 like '%#{salesman_id}%'").first.abalph.strip
  end
  
  def self.customer_import
    customer = find_by_sql("
      SELECT AI.aidaoj, AI.aian8, AB.abalph, AB.absic, AL.alcty1, AI.aicusts, AB.abmcu FROM PRODDTA.F03012 AI
      LEFT JOIN (
        SELECT aban8, abalph, absic, abmcu FROM PRODDTA.F0101
      ) AB ON AI.aian8 = AB.aban8
      LEFT JOIN
      (
        SELECT aladd1, alcty1, alan8 FROM PRODDTA.F0116
      ) AL ON AI.aian8 = AL.alan8
      WHERE AI.aico LIKE '%0000%' AND AI.aidaoj = '#{date_to_julian(Date.yesterday)}'
    ")
    customer.each do |nc|
      find_cus = Customer.where(address_number: nc.aian8)
      if find_cus.nil?
        raise nc.abmcu.inspect
        Customer.create!(address_number: nc.aian8, name: nc.abalph.strip, i_class: nc.absic.strip, 
          city: nc.alcty1.strip, opened_date: julian_to_date(nc.aidaoj), 
          branch_id: jde_cabang(customer.first.abmcu.strip), area_id: find_area(jde_cabang(nc.abmcu.strip)), state: customer.first.aicusts)
       elsif find_cus.present?
         find_cus.first.update_attributes!(state: nc.aicusts, area_id: find_area(jde_cabang(nc.abmcu.strip)))   
      end
    end
  end
  
  def self.checking_customer_limit
    customer = find_by_sql("
      SELECT AI.aiacl, AI.aidaoj, AI.aian8, AB.abalph, AB.absic, AL.alcty1, AI.aicusts, AB.abmcu, 
      AB.absic, AI.aico, RP.rpag, AI.aiaprc, RP.rpmcu FROM PRODDTA.F03012 AI
      LEFT JOIN (
        SELECT aban8, abalph, absic, abmcu FROM PRODDTA.F0101
        GROUP BY aban8, abalph, absic, abmcu
      ) AB ON AI.aian8 = AB.aban8
      LEFT JOIN
      (
        SELECT aladd1, alcty1, alan8 FROM PRODDTA.F0116 GROUP BY aladd1, alcty1, alan8
      ) AL ON AI.aian8 = AL.alan8
      LEFT JOIN
      (
        SELECT SUM(rpag) AS rpag, rpan8, rpkco, MAX(rpmcu) AS rpmcu FROM PRODDTA.F03B11 WHERE REGEXP_LIKE(rpdct,'RI|RX|RO') 
        AND rpdivj >= '#{date_to_julian('15/03/2017'.to_date)}' AND rppst LIKE '%P%'
        GROUP BY rpan8, rpkco
      ) RP ON RP.rpkco = AI.aico AND RP.rpan8 = AB.aban8
      WHERE AI.aico > 0 AND AB.absic LIKE '%RET%' GROUP BY AI.aiacl, AI.aidaoj, AI.aian8, AB.abalph, AB.absic, AL.alcty1, AI.aicusts, AB.abmcu, 
      AB.absic, AI.aico, RP.rpag, AI.aiaprc, RP.rpmcu
    ")
    customer.each do |nc|
      find_cus = CustomerLimit.where(address_number: nc.aian8, co: nc.aico)
      if find_cus.empty?
        CustomerLimit.create!(address_number: nc.aian8, name: nc.abalph.strip, i_class: nc.absic.strip, 
          city: nc.alcty1.nil? ? '-' : nc.alcty1.strip, opened_date: julian_to_date(nc.aidaoj), 
          branch_id: jde_cabang(customer.first.abmcu.strip), 
          area_id: nc.rpmcu.nil? ? nc.rpmcu : find_area(jde_cabang(nc.rpmcu.strip)), state: customer.first.aicusts, 
          limit: nc.aiacl.to_i, co: nc.aico, amount_due: nc.rpag, open_amount: nc.aiaprc)
       elsif find_cus.present?
         find_cus.first.update_attributes!(state: nc.aicusts, limit: nc.aiacl.to_i, 
         area_id: find_area(jde_cabang(nc.rpmcu.strip)), amount_due: nc.rpag, open_amount: nc.aiaprc)   
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
  
  def self.find_area(cabang)
    if cabang == "02"
      2
    elsif cabang == "01"
      1
    elsif cabang == "03" || cabang == "23"
      3
    elsif cabang == "07" || cabang == "22"
      7
    elsif cabang == "09"
      9
    elsif cabang == "04"
      4
    elsif cabang == "05"
      5
    elsif cabang == "08"
      8
    elsif cabang == "10"
      10
    elsif cabang == "11"
      11
    elsif cabang == "13"
      13
    elsif cabang == "19"
      19
    elsif cabang == "20"
      20
    elsif cabang == "50"
      50
    end
  end

  def self.jde_cabang(bu)
    if bu == "11001"|| bu == "11001D" || bu == "11001C" #pusat
      "01"
    elsif bu == "11011" || bu == "11012" || bu == "11011C" || bu == "11011D" || bu == "11002" || bu == "13011D" || bu == "13011" || bu == "13011C" || bu == "11011S" || bu == "13011S" #jabar
      "02"
    elsif bu == "11021" || bu == "11022" || bu == "13021" || bu == "13021D" || bu == "13021C" || bu == "11021C" || bu == "11021D" || bu == "11021S" || bu == "13021S" #cirebon
      "09"
    elsif bu == "12001" || bu == "12002" || bu == "12001C" || bu == "12001D" #bestari mulia
      "50"
    elsif bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "13061"|| bu == "13001" || bu == "13061C" || bu == "13061D" || bu == "12061S" || bu == "13061S" #surabay
      "07"
    elsif bu == "11151" || bu == "11152" || bu == "13151" || bu == "13151C" || bu == "13151D" || bu == "11151C" || bu == "11151D" || bu == "11151S" || bu == "13151S" #cikupa
      "23"
    elsif bu == "11031" || bu == "11032" || bu == "11031C" || bu == "11031D" || bu == "13031C" || bu == "13031D" || bu == "13031" || bu == "11031S" || bu == "13031S" #narogong
      "03"
    elsif bu == "12111" || bu == "12112" || bu == "13111" || bu == "12111C" || bu == "12111D" || bu == "13111C" || bu == "13111D" || bu == "12111S" || bu == "13111S" #makasar
      "19"
    elsif bu == "12071" || bu == "12072" || bu == "13071" || bu == "12071C" || bu == "12071D" || bu == "13071C" || bu == "13071D" || bu == "12111S" || bu == "13071S" #bali
      "04"
    elsif bu == "12131" || bu == "12132" || bu == "13131" || bu == "12131C" || bu == "12131D" || bu == "13131C" || bu == "13131D" || bu == "12131S" || bu == "13131S" #jember
      "22"
    elsif bu == "11101" || bu == "11102" || bu == "13101" || bu == "11101C" || bu == "11101D" || bu == "13101C" || bu == "13101D" || bu == "11101S" || bu == "13101S" #lampung
      "13"  
    elsif bu == "11091" || bu == "11092" || bu == "13091" || bu == "11091C" || bu == "11091D" || bu == "13091C" || bu == "13091D" || bu == "11091S" || bu == "13091S" #palembang
      "11"
    elsif bu == "11041" || bu == "11042" || bu == "13041" || bu == "11041C" || bu == "11041D" || bu == "13041C" || bu == "13041D" || bu == "11041S" || bu == "13041S"#yogyakarta
      "10"
    elsif bu == "11051" || bu == "11052" || bu == "13051" || bu == "11051C" || bu == "11051D" || bu == "13051C" || bu == "13051D" || bu == "11051S" || bu == "13051S" #semarang
      "08"
    elsif bu == "11081" || bu == "11082" || bu == "13081" || bu == "11081C" || bu == "11081D" || bu == "13081C" || bu == "13081D" || bu == "11081S" || bu == "13081S" #medan
      "05"
    elsif bu == "11121" || bu == "11122" || bu == "13121" || bu == "11121C" || bu == "11121D" || bu == "13121C" || bu == "13121D" || bu == "11121S" || bu == "13121S" #pekanbaru
      "20"
    end
  end
end
