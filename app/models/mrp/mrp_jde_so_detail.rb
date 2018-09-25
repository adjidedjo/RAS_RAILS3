class Mrp::JdeSoDetail < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4211" #sd
  
  def self.get_list_of_item(so_num, type_so)
    find_by_sql("SELECT MAX(sddsc1) AS sddsc1, 
    MAX(sddsc2) AS sddsc2, SUM(sduorg) AS sduorg FROM PRODDTA.F4211 
    WHERE sddoco = '#{so_num}' AND sddcto = '#{type_so}' GROUP BY sditm")
  end

  def self.outstanding_so(item_number, first_week, branch_plan)
    select("sum(sduorg) as sduorg").where("sditm = ? and sdnxtr < ? and sdlttr < ? and sddcto like ? and sdtrdj = ? and sdmcu like ?",
      item_number, "999", "580", "SO", date_to_julian(first_week), "%#{branch_plan}%")
  end

  def self.delivered_so(item_number, first_week, last_week)
    select("sum(sdsoqs) as sdsoqs").where("sditm = ? and sdnxtr = ? and sdlttr = ? and sddcto like ? and sdaddj = ?",
      item_number, "999", "580", "SO", date_to_julian(first_week))
  end

  #import hold orders
  def self.import_hold_orders
    hold = find_by_sql("SELECT MAX(ho.hoan8) AS hohoan8, ho.hodoco, MAX(ho.hohcod) AS hohcod,
    MAX(cust.abalph) AS shipto, MAX(cust1.abalph) AS salesman, MAX(ho.hotrdj) AS order_date,
    MAX(ho.homcu) AS homcu, MAX(so.sdsrp1) AS sdsrp1
    FROM PRODDTA.F4209 ho
    JOIN PRODDTA.F4211 so ON ho.hodoco = so.sddoco
    JOIN PRODDTA.F0101 cust ON ho.hoshan = cust.aban8
    JOIN PRODDTA.F40344 sls ON so.sdshan = sls.saan8
    JOIN PRODDTA.F0101 cust1 ON cust1.aban8 = sls.saslsm
    WHERE ho.hordc = ' ' 
    AND sls.saexdj > '#{date_to_julian(Date.today.to_date)}' AND REGEXP_LIKE(so.sddcto,'SO|ZO')
    AND so.sdnxtr LIKE '%#{525}%' AND cust.absic LIKE '%RET%' GROUP BY ho.hodoco, ho.hohcod, ho.homcu, so.sdsrp1")
    hold.each do |ou|
      HoldOrder.create(order_no: ou.hodoco.to_i, customer: ou.shipto.strip, 
      promised_delivery: julian_to_date(ou.order_date), branch: ou.homcu.strip, 
      brand: ou.sdsrp1.strip, hdcd: ou.hohcod.strip, 
      salesman: ou.salesman.strip)
    end
  end

  #import oustanding shipment
  def self.import_outstanding_shipments
    OutstandingShipment.delete_all
    outstanding = find_by_sql("SELECT MAX(so.sdopdj) AS sdopdj, so.sddoco, so.sdan8, MAX(so.sdshan), MAX(so.sddrqj), 
    MAX(cust.abalph) AS abalph, MAX(so.sdshan), MAX(cust1.abalph) AS salesman, SUM(so.sduorg) AS jumlah,
    MAX(so.sdsrp1) AS sdsrp1, MAX(so.sdmcu) AS sdmcu
    FROM PRODDTA.F4211 so
    JOIN PRODDTA.F0101 cust ON so.sdshan = cust.aban8
    JOIN PRODDTA.F40344 sls ON so.sdshan = sls.saan8
    JOIN PRODDTA.F0101 cust1 ON cust1.aban8 = sls.saslsm
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    WHERE cust.absic LIKE '%RET%' AND itm.imseg4 NOT LIKE '%#{'K'}%' 
    AND sls.saexdj > '#{date_to_julian(Date.today.to_date)}' AND sddcto LIKE '%#{'SO'}%' AND 
    so.sdnxtr LIKE '%#{560}%' AND itm.imstkt NOT LIKE '%K%' 
    AND REGEXP_LIKE(so.sdsrp2,'KM|HB|DV|SA|SB|KB') GROUP BY so.sddoco, so.sdan8, so.sdsrp1, so.sdmcu")
    outstanding.each do |ou|
      OutstandingShipment.create(order_no: ou.sddoco.to_i, customer: ou.abalph.strip, 
      promised_delivery: julian_to_date(ou.sdopdj), branch: ou.sdmcu.strip, 
      brand: ou.sdsrp1.strip, exceeds: (Date.today - julian_to_date(ou.sdopdj)).to_i, 
      salesman: ou.salesman.strip)
    end
  end

  #import oustanding order
  def self.import_outstanding_orders
    outstanding = find_by_sql("SELECT MAX(so.sdopdj) AS sdopdj, so.sddoco, so.sdan8, MAX(so.sdshan), MAX(so.sddrqj), 
    MAX(cust.abalph) AS abalph, MAX(so.sdshan), MAX(cust1.abalph) AS salesman, SUM(so.sduorg) AS jumlah,
    so.sdsrp1, MAX(so.sdmcu) AS sdmcu, MAX(so.sddrqj) AS sddrqj, MAX(so.sdtrdj) AS sdtrdj,
    MAX(so.sddsc1) AS sddsc1, MAX(so.sddsc2) AS sddsc2, MAX(so.sduorg) AS sduorg, MAX(so.sdlitm) AS sdlitm
    FROM PRODDTA.F4211 so
    JOIN PRODDTA.F0101 cust ON so.sdshan = cust.aban8
    JOIN PRODDTA.F40344 sls ON so.sdshan = sls.saan8
    JOIN PRODDTA.F0101 cust1 ON cust1.aban8 = sls.saslsm
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    WHERE cust.absic LIKE '%RET%' AND itm.imseg4 NOT LIKE '%K%' 
    AND sls.saexdj > '#{date_to_julian(Date.today.to_date)}' AND REGEXP_LIKE(sddcto,'SO|ZO') AND 
    so.sdnxtr LIKE '%#{525}%'
    AND REGEXP_LIKE(so.sdsrp2,'KM|HB|DV|SA|SB|KB|ST') GROUP BY so.sddoco, so.sdan8, so.sdsrp1, so.sdmcu")
    Mrp::MrpOutstandingOrder.delete_all
    outstanding.each do |ou|
      Mrp::MrpOutstandingOrder.create(order_no: ou.sddoco.to_i, customer: ou.abalph.strip, 
      requested_date: julian_to_date(ou.sddrqj), branch: ou.sdmcu.strip, 
      brand: ou.sdsrp1.strip, salesman: ou.salesman.strip, order_date: julian_to_date(ou.sdtrdj), 
      area: find_area(jde_cabang(ou.sdmcu.strip)), item_number: ou.sdlitm.strip, 
      description: (ou.sddsc1.strip+ ' '+ou.sddsc2.strip), quantity: ou.sduorg.to_i/10000)
    end
  end

  private
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
    if bu == "11001" || bu == "11001D" || bu == "11001C" || bu == "18001" #pusat
      "01"
    elsif bu == "11101" || bu == "11102" || bu == "11101C" || bu == "11101D" || bu == "11101S" || bu == "18101" || bu == "18101C" || bu == "18101D" || bu == "18102" || bu == "18101S" || bu == "18101K" #lampung
      "13" 
    elsif bu == "18011" || bu == "18011C" || bu == "18011D" || bu == "18012" || bu == "18011S" || bu == "18011K" #jabar
      "02"
    elsif bu == "18021" || bu == "18021C" || bu == "18021D" || bu == "18022" || bu == "18021S" || bu == "18021K" #cirebon
      "09"
    elsif bu == "12001" || bu == "12002" || bu == "12001C" || bu == "12001D" #bestari mulia
      "50"
    elsif bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "12061S" || bu == "18061" || bu == "18061C" || bu == "18061D" || bu == "18061S" #surabaya
      "07"
    elsif bu == "18151" || bu == "18151C" || bu == "18151D" || bu == "18152" || bu == "18151S" || bu == "18151K" || bu == "11151" #cikupa
      "23"
    elsif bu == "11030" ||  bu == "18031" || bu == "18031C" || bu == "18031D" || bu == "18032" || bu == "18031S" || bu == "18031K" #narogong
      "03"
    elsif bu == "12111" || bu == "12112" || bu == "12111C" || bu == "12111D" || bu == "12111S" || bu == "18111" || bu == "18111C" || bu == "18111D" || bu == "18112" || bu == "18111S" || bu == "18111K" || bu == "18112C" || bu == "18112D" || bu == "18112K" #makasar
      "19"
    elsif bu == "12071" || bu == "12072" || bu == "12071C" || bu == "12071D" || bu == "12071S" || bu == "18071" || bu == "18071C" || bu == "18071D" || bu == "18072" || bu == "18071S" || bu == "18071K" || bu == "18072C" || bu == "18071D" || bu == "18071K" #bali
      "04"
    elsif bu == "12131" || bu == "12132" || bu == "12131C" || bu == "12131D" || bu == "12131S" || bu == "18131" || bu == "18131C" || bu == "18131D" || bu == "18132" || bu == "18131S" || bu == "18131K" || bu == "18132C" || bu == "18132D" || bu == "18132K" #jember
      "22" 
    elsif bu == "11091" || bu == "11092" || bu == "11091C" || bu == "11091D" || bu == "11091S" || bu == "18091" || bu == "18091C" || bu == "18091D" || bu == "18092" || bu == "18091S" || bu == "18091K" || bu == "18092C" || bu == "18092D" || bu == "18092K" #palembang
      "11"
    elsif bu == "11041" || bu == "11042" || bu == "11041C" || bu == "11041D" || bu == "11041S" || bu == "18041" || bu == "18041C" || bu == "18041D" || bu == "18042" || bu == "18042S" || bu == "18042K" || bu == "18042C" || bu == "18042D" || bu == "18042K" #yogyakarta
      "10"
    elsif bu == "11051" || bu == "11052" || bu == "11051C" || bu == "11051D" || bu == "11051S" || bu == "18051" || bu == "18051C" || bu == "18051D" || bu == "18052" || bu == "18051S" || bu == "18051K" || bu == "18052C" || bu == "18052D" || bu == "18052K" #semarang
      "08"
    elsif bu == "11081" || bu == "11082" || bu == "11081C" || bu == "11081D" || bu == "11081S" || bu == "18081" || bu == "18081C" || bu == "18081D" || bu == "18082" || bu == "18081S" || bu == "18081K" || bu == "18082C" || bu == "18082D" || bu == "18082K" #medan
      "05"
    elsif bu == "11121" || bu == "11122" || bu == "11121C" || bu == "11121D" || bu == "11121S" || bu == "18121" || bu == "18121C" || bu == "18121D" || bu == "18122" || bu == "18121S" || bu == "18121K" || bu == "18122C" || bu == "18122D" || bu == "18122K" #pekanbaru
      "20"
    elsif bu.include?('180120') || bu.include?("180110") #tasikmalaya
      "2"
    elsif bu.include?('1515') #new cikupa
      "23"
    elsif bu == "12171" || bu == "12172" || bu == "12171C" || bu == "12171D" || bu == "12171S" || bu == "18171" || bu == "18172" || bu == "18171C" || bu == "18171D" || bu == "18171S" || bu == "18172D" || bu == "18172" || bu == "18172K" #manado
      "26"
    end
  end
end
