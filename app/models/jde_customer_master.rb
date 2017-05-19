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
        Customer.create!(address_number: nc.aian8, name: nc.abalph.strip, i_class: nc.absic.strip, 
          city: nc.alcty1.strip, opened_date: julian_to_date(nc.aidaoj), 
          branch_id: jde_cabang(customer.first.abmcu.strip), area_id: find_area(jde_cabang(customer.first.abmcu.strip)), state: customer.first.aicusts)
       elsif find_cus.present?
         find_cus.first.update_attributes!(state: nc.aicusts)   
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
    end
  end

  def self.jde_cabang(bu)
    if bu == "11001" #pusat
      "01"
    elsif bu == "11011" || bu == "11012" || bu == "11011C" || bu == "11011D" || bu == "11002" #jabar
      "02"
    elsif bu == "11021" || bu == "11022" || bu == "13021" || bu == "13021D" || bu == "13021C" || bu == "11021C" || bu == "11021D" #cirebon
      "09"
    elsif bu == "12001" || bu == "12002" #bestari mulia
      "50"
    elsif bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "13061"|| bu == "13001" || bu == "13061C" || bu == "13061D" #surabay
      "07"
    elsif bu == "11151" || bu == "11152" || bu == "13151" || bu == "13151C" || bu == "13151D" || bu == "11151C" || bu == "11151D" #cikupa
      "23"
    elsif bu == "11031" || bu == "11032" || bu == "11031C" || bu == "11031D" #narogong
      "03"
    elsif bu == "12111" || bu == "12112" || bu == "13111" || bu == "12111C" || bu == "12111D" || bu == "13111C" || bu == "13111D" #makasar
      "19"
    elsif bu == "12071" || bu == "12072" || bu == "13071" || bu == "12071C" || bu == "12071D" || bu == "13071C" || bu == "13071D" #bali
      "04"
    elsif bu == "12131" || bu == "12132" || bu == "13131" || bu == "12131C" || bu == "12131D" || bu == "13131C" || bu == "13131D" #jember
      "22"
    elsif bu == "11101" || bu == "11102" || bu == "13101" || bu == "11101C" || bu == "11101D" || bu == "13101C" || bu == "13101D" #lampung
      "13"  
    elsif bu == "11091" || bu == "11092" || bu == "13091" || bu == "11091C" || bu == "11091D" || bu == "13091C" || bu == "13091D" #palembang
      "11"
    elsif bu == "11041" || bu == "11042" || bu == "13041" || bu == "11041C" || bu == "11041D" || bu == "13041C" || bu == "13041D" #yogyakarta
      "10"
    elsif bu == "11051" || bu == "11052" || bu == "13051" || bu == "11051C" || bu == "11051D" || bu == "13051C" || bu == "13051D" #semarang
      "08"
    elsif bu == "11081" || bu == "11082" || bu == "13081" || bu == "11081C" || bu == "11081D" || bu == "13081C" || bu == "13081D" #medan
      "05"
    elsif bu == "11121" || bu == "11122" || bu == "13121" || bu == "11121C" || bu == "11121D" || bu == "13121C" || bu == "13121D" #pekanbaru
      "20"
    end
  end
end
