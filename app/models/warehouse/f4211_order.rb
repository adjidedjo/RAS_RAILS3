class Warehouse::F4211Order < ActiveRecord::Base
  establish_connection "warehouse"
  self.table_name = "F4211_ORDERS" #rp
  
  def self.import_orders_to_warehouse
    ActiveRecord::Base.establish_connection("warehouse").connection.execute("
      DELETE FROM warehouse.F4211_ORDERS WHERE DATE(created_at) = '#{2.days.ago.to_date}'
    ")
    outstanding = ActiveRecord::Base.establish_connection("jdeoracle").connection.execute("
    SELECT so.sddoco, so.sddrqj, so.sdnxtr, 
    so.sduorg AS jumlah, so.sdtrdj AS sdtrdj,
    so.sdsrp1 AS sdsrp1, so.sdmcu AS sdmcu, so.sditm, so.sdlitm AS sdlitm, 
    so.sddsc1 AS sddsc1, so.sddsc2 AS sddsc2, itm.imseg1 AS imseg1,
    cus.abalph AS abalph, so.sdshan, cus.abat1 AS abat1,
    so.sdtorg AS sdtorg, so.sdpsn, so.sdlttr, so.sddcto, so.sdlotn, so.sdvr01
    FROM PRODDTA.F4211 so
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    JOIN PRODDTA.F0101 cus ON so.sdshan = cus.aban8
    WHERE so.sdcomm NOT LIKE '%#{'K'}%'
    AND REGEXP_LIKE(so.sddcto,'SO|ZO|ST|SK') AND itm.imtmpl LIKE '%BJ MATRASS%' AND
    so.sdnxtr < '580'")
    while r = outstanding.fetch_hash
       self.create(order_no: r["SDDOCO"].to_i, 
        promised_delivery: julian_to_date(r["SDDRQJ"]), branch: r["SDMCU"].strip, 
        brand: r["SDSRP1"].strip, item_number: r["SDLITM"].strip, description: r["SDDSC1"].strip + ' ' + r["SDDSC2"].strip,
        order_date: julian_to_date(r["SDTRDJ"]), quantity: r["JUMLAH"]/10000, short_item: r["SDITM"].to_i, 
        segment1: r["IMSEG1"].strip, customer: r["ABALPH"].strip, ship_to: r["SDSHAN"].to_i, typ: r["ABAT1"].strip,
        last_status: r["SDLTTR"].to_i, branch_desc: jde_cabang(r["SDMCU"].strip), originator: r["SDTORG"],
        pick_number: r["SDPSN"].to_i, next_status: r["SDNXTR"].to_i, orty: r["SDDCTO"].strip, 
        serial: r["SDLOTN"].strip, customer_po: r["SDVR01"].strip)
    end
    Production.production_import_outstanding_orders #import data outstanding for production
    sales_mart_import_outstanding_orders_only_production
    sales_mart_import_outstanding_orders
  end
  
  def self.sales_mart_import_outstanding_orders_only_production
    ActiveRecord::Base.establish_connection("warehouse").connection.execute("
      DELETE FROM sales_mart.PRODUCTION_ORDERS WHERE DATE(created_at) = '#{2.days.ago.to_date}'
    ")
    outstanding = Warehouse::F4211Order.find_by_sql("
    SELECT * FROM warehouse.F4211_ORDERS
    WHERE branch REGEXP '11001$|11002$|12001$|12002$|18081$|18082$|11081$|
    11082$|11091$|11092$|11051$|11052$|18091$|18092$|18051$|18052$|11151$|11152$|1515$'
    AND DATE(created_at) = '#{Date.today}'")
    outstanding.each do |ou|
      ActiveRecord::Base.establish_connection("warehouse").connection.execute("INSERT INTO sales_mart.PRODUCTION_ORDERS (order_no, promised_delivery, branch, brand, item_number,
      description, order_date, quantity, short_item, segment1, customer, ship_to, typ, last_status,
      branch_desc, originator, exceeds, next_status, day_category, created_at) VALUES ('#{ou.order_no}', 
      '#{ou.promised_delivery}', '#{ou.branch}', '#{ou.brand}', '#{ou.item_number}', '#{ou.description}',
      '#{ou.order_date}', '#{ou.quantity}', '#{ou.short_item}', 
      '#{ou.segment1}', '#{ou.customer}', '#{ou.ship_to}', '#{ou.typ}',
      '#{ou.last_status}', '#{ou.branch_desc}', '#{ou.originator}',
      '#{(Date.today - ou.promised_delivery)}', '#{ou.next_status}', 
      '#{category_days((Date.today - ou.promised_delivery))}', '#{Date.today}')")
    end
  end
  
  def self.sales_mart_import_outstanding_orders
    ActiveRecord::Base.establish_connection("warehouse").connection.execute("
      DELETE FROM sales_mart.BRANCH_ORDERS WHERE DATE(created_at) = '#{2.days.ago.to_date}'
    ")
    outstanding = Warehouse::F4211Order.find_by_sql("
    SELECT * FROM warehouse.F4211_ORDERS
    WHERE typ = 'C' AND DATE(created_at) = '#{Date.yesterday}' AND order_no = '335404'")
    outstanding.each do |ou|
      ActiveRecord::Base.establish_connection("warehouse").connection.execute('INSERT INTO sales_mart.BRANCH_ORDERS (order_no, promised_delivery, branch, brand, item_number,
      description, order_date, quantity, short_item, segment1, customer, ship_to, typ, last_status,
      branch_desc, originator, exceeds, next_status, day_category, created_at) VALUES ("#{ou.order_no}", 
      "#{ou.promised_delivery}", "#{ou.branch}", "#{ou.brand}", "#{ou.item_number}", "#{ou.description}",
      "#{ou.order_date}", "#{ou.quantity}", "#{ou.short_item}", 
      "#{ou.segment1}", "#{ou.customer}", "#{ou.ship_to}", "#{ou.typ}",
      "#{ou.last_status}", "#{ou.branch_desc}", "#{ou.originator}",
      "#{(Date.today - ou.promised_delivery)}", "#{ou.next_status}", 
      "#{category_days((Date.today - ou.promised_delivery))}", "#{Date.today}")')
    end
  end

  private
  
  def self.category_days(day)
    if day < 3
      3
    elsif day >= 3 && day < 5
      5
    elsif day >= 5 && day < 8
      8
    elsif day >= 8 && day < 15
      15
    elsif day >= 15 && day < 30
      30
    elsif day >= 30 && day < 60
      60
    elsif day >= 60
      61
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
  
  def self.jde_cabang(bu)
    if bu == "11001" || bu == "11001D" || bu == "11001C" || bu == "18001" || bu == "11002" #pusat
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