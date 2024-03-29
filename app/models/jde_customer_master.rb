class JdeCustomerMaster < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F0101"
  
  def self.get_customer(an8)
    self.find_by_sql("SELECT * FROM PRODDTA.F0101 WHERE ABAN8 LIKE '%#{an8}%'")
  end
  
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
    sales = find_by_sql("SELECT abalph FROM proddta.F0101 WHERE aban8 like '%#{salesman_id}%'")
    (sales.nil? || sales.empty?) ? '-' : sales.first.abalph.strip
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
      WHERE AI.aico LIKE '%0000%' AND AI.aidaoj BETWEEN '#{date_to_julian('2012-01-01'.to_date)}' AND '#{date_to_julian('2018-5-12'.to_date)}'
    ")
    customer.each do |nc|
      find_cus = Customer.where(address_number: nc.aian8)
      if find_cus.empty?
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
      SELECT AI.*, RP.* ,AB.*, AL.*, SD.*, MC.*
      FROM 
      (
       select aian8, max(aicusts) as aicusts, SUM(case when aico = '00000' then aiacl end) as credit_limit,
       SUM(aiaprc) AS open_order from PRODDTA.F03012 GROUP BY aian8
      ) AI
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
        SELECT SUM(rpaap) AS rpag, rpan8, MAX(rpmcu) AS rpmcu FROM PRODDTA.F03B11 WHERE rppst NOT LIKE '%P%'
        GROUP BY rpan8 ORDER BY rpmcu
      ) RP ON RP.rpan8 = AB.aban8
      LEFT JOIN
      (
        SELECT rpan8, MAX(rpmcu) AS mcu2, SUM(CASE WHEN rpdivj BETWEEN '#{date_to_julian(3.months.ago.beginning_of_month)}'
        AND '#{date_to_julian(3.months.ago.end_of_month)}' THEN rpag END) three,
        SUM(CASE WHEN rpdivj BETWEEN '#{date_to_julian(2.months.ago.beginning_of_month)}'
        AND '#{date_to_julian(2.months.ago.end_of_month)}' THEN rpag END) two,
        SUM(CASE WHEN rpdivj BETWEEN '#{date_to_julian(1.months.ago.beginning_of_month)}'
        AND '#{date_to_julian(1.months.ago.end_of_month)}' THEN rpag END) one
        FROM PRODDTA.F03B11 WHERE
        REGEXP_LIKE(rpdct,'RI|RX|RO|RM') GROUP BY rpan8
      ) SD ON SD.rpan8 = AB.aban8
      LEFT JOIN
      (
        SELECT MCMCU, MCRP04 AS kode_cabang FROM PRODDTA.F0006 GROUP BY MCMCU, MCRP04
      ) MC ON TRIM(MC.MCMCU) = TRIM(SD.MCU2)
      WHERE AB.absic LIKE '%RET%'
    ")
    customer.each do |nc|
      find_cus = CustomerLimit.where(address_number: nc.aian8)
      if find_cus.empty?
        CustomerLimit.create!(address_number: nc.aian8, name: nc.abalph.strip, i_class: nc.absic.strip, 
          city: nc.alcty1.nil? ? '-' : nc.alcty1.strip, 
          branch_id: (nc.kode_cabang.nil? ? 0 : area_by_jde(nc.kode_cabang.strip)), 
          area_id: (nc.kode_cabang.nil? ? 0 : area_by_jde(nc.kode_cabang.strip)), state: customer.first.aicusts, 
          credit_limit: nc.credit_limit.to_i, amount_due: nc.rpag, open_amount: nc.open_order,
          three_months_ago: nc.three, two_months_ago: nc.two, one_month_ago: nc.one)
       elsif find_cus.present?
         find_cus.first.update_attributes!(state: nc.aicusts, credit_limit: nc.credit_limit.to_i, 
         branch_id: (nc.kode_cabang.nil? ? 0 : area_by_jde(nc.kode_cabang.strip)), 
         area_id: (nc.kode_cabang.nil? ? 0 : area_by_jde(nc.kode_cabang.strip)), amount_due: nc.rpag,
         open_amount: nc.open_order, three_months_ago: nc.three, two_months_ago: nc.two, one_month_ago: nc.one)   
      end
    end
  end
  
  
  def self.checking_customer_limit_by_brand
    customer = find_by_sql("
      SELECT AI.aiacl, AI.aidaoj, AI.aian8, AB.abalph, AB.absic, AL.alcty1, AI.aicusts, AB.abmcu, 
      AB.absic, AI.aico, RP.rpag, AI.aiaprc, RP.rpmcu, SD.brand, AI.aiasn, SUM(SD.open_order) AS open_order 
      FROM PRODDTA.F03012 AI
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
        SELECT SUM(rpaap) AS rpag, rpan8, rpkco, MAX(rpmcu) AS rpmcu FROM PRODDTA.F03B11 WHERE rppst NOT LIKE '%P%'
        GROUP BY rpan8, rpkco ORDER BY rpmcu
      ) RP ON RP.rpkco = AI.aico AND RP.rpan8 = AB.aban8
      LEFT JOIN
      (
        SELECT rpan8, rpkco, substr(rprmr1, 1,3) as brand, sum(rpaap) as open_order
        FROM PRODDTA.F03B11 WHERE
        REGEXP_LIKE(rpdct,'RI|RX|RO|RM') and rprmr1 like 'F%' 
        AND rpdivj BETWEEN '#{date_to_julian(3.months.ago.beginning_of_month)}'
        AND '#{date_to_julian(Date.today.at_beginning_of_month)}' GROUP BY rpan8, rpkco, substr(rprmr1, 1,3)
      ) SD ON SD.rpkco = AI.aico AND SD.rpan8 = AB.aban8
      WHERE AI.aico > 0 AND AB.absic LIKE '%RET%' AND AI.aico != '0000' AND AI.aiasn != ' '
      GROUP BY AI.aiacl, AI.aidaoj, AI.aian8, AB.abalph, AB.absic, AL.alcty1, AI.aicusts, AB.abmcu, 
      AB.absic, AI.aico, RP.rpag, AI.aiaprc, RP.rpmcu, SD.brand, AI.aiasn
    ")
    customer.each do |nc|
      find_cus = CustomerBrandLimit.where(address_number: nc.aian8, co: nc.aico, brand: nc.brand)
      if find_cus.empty?
        CustomerBrandLimit.create!(address_number: nc.aian8, name: nc.abalph.strip, i_class: nc.absic.strip, 
          city: nc.alcty1.nil? ? '-' : nc.alcty1.strip, 
          branch_id: jde_cabang(customer.first.abmcu.strip), 
          area_id: assign_area(nc.aiasn), state: customer.first.aicusts, 
          credit_limit: nc.aiacl.to_i, co: nc.aico, amount_due: nc.rpag, open_amount: nc.open_order,
          brand: find_brand_based_on_fk(nc.brand))
       elsif find_cus.present?
         find_cus.first.update_attributes!(state: nc.aicusts, credit_limit: nc.aiacl.to_i, 
         area_id: assign_area(nc.aiasn).to_i, amount_due: nc.rpag,
         open_amount: nc.open_order)   
      end
    end
  end
  
  def self.sales_average
    find_by_sql("
      SELECT CS.address_number, CS.co, AR.rpag FROM customer_limits CS
      LEFT JOIN
      (
        SELECT rpan8, rpkco,
        SUM(CASE WHEN rppn = '#{3.month.ago.month}' THEN rpag END) three,
        SUM(CASE WHEN rppn = '#{2.month.ago.month}' THEN rpag END) two,
        SUM(CASE WHEN rppn = '#{1.month.ago.month}' THEN rpag END) one, 
        
        
        
        FROM PRODDTA.F03B11 WHERE rppst NOT LIKE '%P%'
        GROUP BY rpan8, rpkco ORDER BY rpmcu
      )
    ")
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
  
  def self.find_brand_based_on_fk(brand)
    if brand == 'FKS'
      "SERENITY"
    elsif brand == 'FKC'
      "CLASSIC"
    elsif brand == 'FKE'
      "ELITE"
    elsif brand == 'FKL'
      "LADY"
    elsif brand == 'FKF'
      "FOAM"
    elsif brand == 'FKO'
      "TOTE"
    elsif brand == 'FKR'
      "ROYAL"
    else
      "-"
    end
  end
  
  def self.area_by_jde(cabang)
    if cabang == "01" || cabang == "16" || cabang == "18" || cabang == "19"
      2
    elsif cabang == "06" || cabang == "13" || cabang == "20" #JATIM
      7
    elsif cabang == "3"
      23
    elsif cabang == "02"
      9
    elsif cabang == "03"
      3
    elsif cabang == "04"
      10
    elsif cabang == "05"
      8
    elsif cabang == "07" #BALI
      4
    elsif cabang == "08" #MEDAN
      5
    elsif cabang == "09" #PALEMBANG
      11
    elsif cabang == "10" #LAMPUNG
      13
    elsif cabang == "11" #MAKASSAR
      19
    elsif cabang == "12" #PEKANBARU
      20
    elsif cabang == "15" #TANGERANG
      23
    elsif cabang == "17" #MANADO
      26
    elsif cabang == "21" #SAMARINDA
      55
    end
  end
  
  def self.find_area(cabang)
    if cabang == "02" || cabang == "25" || cabang == "52" || cabang == "53"
      2
    elsif cabang == "01"
      1
    elsif cabang == "03"
      23
    elsif cabang == "23"
      3
    elsif cabang == "07" || cabang == "22" || cabang == "54"
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
    elsif cabang == "26"
      26
    elsif cabang == "55"
      55
    end
  end
  
  def self.jde_cabang(bu)
    if bu == "11001" || bu == "11001D" || bu == "11001C" || bu == "18001" #pusat
      "01"
    elsif bu == "11101" || bu == "11102" || bu == "11101C" || bu == "11101D" || bu == "11101S" || bu == "18101" || bu == "18101C" || bu == "18101D" || bu == "18102" || bu == "18101S" || bu == "18101K" #lampung
      "13" 
    elsif bu == "11010" || bu == "18010" || bu == "18011" || bu == "18011C" || bu == "18011D" || bu == "18012" || bu == "18011S" || bu == "18011K" #jabar
      "02"
    elsif bu == "11020" || bu == "18020" || bu == "18021" || bu == "18021C" || bu == "18021D" || bu == "18022" || bu == "18021S" || bu == "18021K" #cirebon
      "09"
    elsif bu == "12001" || bu == "12002" || bu == "12001C" || bu == "12001D" #bestari mulia
      "50"
    elsif bu == "12060" || bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "12061S" || bu == "18061" || bu == "18061C" || bu == "18061D" || bu == "18061S" || bu == "18061" || bu == "18061C" || bu == "18061D" || bu == "18061S"#surabaya
      "07"
    elsif bu == "11050" || bu == "18150" || bu == "18151" || bu == "18151C" || bu == "18151D" || bu == "18152" || bu == "18151S" || bu == "18151K" || bu == "11151" #cikupa
      "23"
    elsif bu == "11030" || bu == "11031" ||  bu == "18031" || bu == "18031C" || bu == "18031D" || bu == "18032" || bu == "18031S" || bu == "18031K" #narogong
      "03"
    elsif bu == "18110" || bu == "12110" || bu == "12111" || bu == "12112" || bu == "12111C" || bu == "12111D" || bu == "12111S" || bu == "18111" || bu == "18111C" || bu == "18111D" || bu == "18112" || bu == "18111S" || bu == "18111K" || bu == "18112C" || bu == "18112D" || bu == "18112K" #makasar
      "19"
    elsif bu == "18070" || bu == "12070" || bu == "12071" || bu == "12072" || bu == "12071C" || bu == "12071D" || bu == "12071S" || bu == "18071" || bu == "18071C" || bu == "18071D" || bu == "18072" || bu == "18071S" || bu == "18071K" || bu == "18072C" || bu == "18071D" || bu == "18071K" #bali
      "04"
    elsif bu == "18130" || bu == "12130" || bu == "12131" || bu == "12132" || bu == "12131C" || bu == "12131D" || bu == "12131S" || bu == "18131" || bu == "18131C" || bu == "18131D" || bu == "18132" || bu == "18131S" || bu == "18131K" || bu == "18132C" || bu == "18132D" || bu == "18132K" #jember
      "22" 
    elsif bu == "18090" || bu == "11090" || bu == "11091" || bu == "11092" || bu == "11091C" || bu == "11091D" || bu == "11091K" || bu == "11091S" || bu == "18091" || bu == "18091C" || bu == "18091D" || bu == "18092" || bu == "18091S" || bu == "18091K" || bu == "18092C" || bu == "18092D" || bu == "18092K" #palembang
      "11"
    elsif bu == "18040" || bu == "11040" || bu == "11041" || bu == "11042" || bu == "11041C" || bu == "11041D" || bu == "11041S" || bu == "18041" || bu == "18041C" || bu == "18041D" || bu == "18042" || bu == "18042S" || bu == "18042K" || bu == "18042C" || bu == "18042D" || bu == "18042K" #yogyakarta
      "10"
    elsif bu == "18050" || bu == "11050" || bu == "11051" || bu == "11052" || bu == "11051C" || bu == "11051D" || bu == "11051S" || bu == "18051" || bu == "18051C" || bu == "18051D" || bu == "18052" || bu == "18051S" || bu == "18051K" || bu == "18052C" || bu == "18052D" || bu == "18052K" #semarang
      "08"
    elsif bu == "11080" || bu == "11081" || bu == "11082" || bu == "11081C" || bu == "11081D" || bu == "11081S" || bu == "18081" || bu == "18081C" || bu == "18081D" || bu == "18082" || bu == "18081S" || bu == "18081K" || bu == "18082C" || bu == "18082D" || bu == "18082K" #medan
      "05"
    elsif bu == "11120" || bu == "11121" || bu == "11122" || bu == "11121C" || bu == "11121D" || bu == "11121S" || bu == "18121" || bu == "18121C" || bu == "18121D" || bu == "18122" || bu == "18121S" || bu == "18121K" || bu == "18122C" || bu == "18122D" || bu == "18122K" #pekanbaru
      "20"
    elsif bu == "1801101" || bu == "1801101C" || bu == "1801101D" || bu == "1801101S" || bu == "1801101K" || bu == "1801201" || bu == "1801201C" || bu == "1801201D" || bu == "1801201S" || bu == "1801201K" #tasikmalaya
      "25"
    elsif bu == "1801102" || bu == "1801102C" || bu == "1801102D" || bu == "1801102S" || bu == "1801102K" || bu == "1801202" || bu == "1801202C" || bu == "1801202D" || bu == "1801202S" || bu == "1801202K" #sukabumi
      "52"
    elsif bu == "1801103" || bu == "1801103C" || bu == "1801103D" || bu == "1801103S" || bu == "1801103K" || bu == "1801203" || bu == "1801203C" || bu == "1801203D" || bu == "1801203S" || bu == "1801203K" #sukabumi
      "53"
    elsif bu.include?('1515') #new cikupa
      "23"
    elsif bu == "12170" || bu == "12171" || bu == "12172" || bu == "12171C" || bu == "12171D" || bu == "12171S" || bu == "18171" || bu == "18172" || bu == "18171C" || bu == "18171D" || bu == "18171S" || bu == "18172D" || bu == "18172" || bu == "18172K" #manado
      "26"
    elsif bu == "1206104" || bu == "1206204" || bu == "1206104C" || bu == "1206104D" || bu == "1206104S" || bu == "1806104" || bu == "1806104" || bu == "1806104C" || bu == "1806104D" || bu == "1806104S" || bu == "1806204D" || bu == "1806204" || bu == "1806204K" #kediri
      "54"
    elsif bu == "18180" || bu == "18181" || bu == "18182" || bu == "18181C" || bu == "18181D" || bu == "18181S" || bu == "18182C" || bu == "18182D" || bu == "18182S" #samarinda
      "55"
    end
  end
    
  def self.assign_area(sc)
    if sc.include?('BAELITE') || sc.include?('BALADY') || sc.include?('BALISPEC')
      "4"
    elsif sc.include?('CRLADY') || sc.include?('CRBELITE')
      "9"
    elsif sc.include?('JBELITE') || sc.include?('JBLADY') || sc.include?('DISCGA')
      "2"
    elsif sc.include?('JBRELITE') || sc.include?('SBYELITE') || sc.include?('SBYLADY')
      "7"
    elsif sc.include?('JKTELITE') || sc.include?('JKTLA')
      "3"
    elsif sc.include?('JOGELITE') || sc.include?('JOGLADY')
      "10"
    elsif sc.include?('LPGELITE') || sc.include?('LPGLADY')
      "13"
    elsif sc.include?('MDNELITE') || sc.include?('MDNLADY')
      "5"
    elsif sc.include?('MKSELITE') || sc.include?('MKSLADY')
      "19"
    elsif sc.include?('MNDELITE')
      "26"
    elsif sc.include?('PKBELITE') || sc.include?('PKBLADY')  
      "20"
    elsif sc.include?('PLBELITE') || sc.include?('PLBLADY')
      "11"
    elsif sc.include?('SMGELITE') || sc.include?('SMGLADY')
      "8"
    elsif sc.include?('SMRELITE') || sc.include?('SMRLADY')
      "55"
    end 
  end
end
