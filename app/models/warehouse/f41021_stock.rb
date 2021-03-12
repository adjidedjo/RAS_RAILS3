class Warehouse::F41021Stock < ActiveRecord::Base
  establish_connection "warehouse"
  self.table_name = "F41021_STOCK" #rp
  
  def self.import_stock_warehouse
    stocks = ActiveRecord::Base.establish_connection("jdeoracle").connection.execute("
      SELECT LI.LIITM, LI.LIMCU, SUM(LI.LIPQOH) AS LIPQOH, MAX(LI.LIGLPT) AS LIGLPT, MAX(ART.DRDL01) AS ARTICLE, 
      MAX(IM.IMSEG5) AS PANJANG, MAX(IM.IMSEG6) AS LEBAR FROM PRODDTA.F41021 LI 
      LEFT JOIN PRODDTA.F0006 BP ON BP.MCMCU = LI.LIMCU
      LEFT JOIN PRODDTA.F4101 IM ON TRIM(IM.IMITM) = TRIM(LI.LIITM)
      LEFT JOIN PRODCTL.F0005 ART ON ART.DRKY LIKE '%'||TRIM(IM.IMSEG2) 
      WHERE LI.LIPQOH >= 10000 AND LI.LIPBIN = 'S' AND BP.MCRP08 = 'GDG' AND LI.LIGLPT NOT IN ('WIP') 
      AND LI.LIMCU NOT LIKE '11001X%' AND ART.DRSY = '55' AND ART.DRRT = 'AT'
      GROUP BY LI.LIITM, LI.LIMCU")
    while r = stocks.fetch_hash
      item_master = JdeItemMaster.get_item_number(r["LIITM"]).first
      fullnamabarang = item_master.imdsc1.strip + " " + item_master.imdsc2.strip
      self.create(short_item: r["LIITM"].to_i, item_number: item_master.imlitm.strip, brand: item_master.imprgr.strip,
        description: fullnamabarang, branch: r["LIMCU"].strip, onhand: r["LIPQOH"]/10000, 
        glcat: item_master.imsrp2, receipt_date: JdeInvoice.julian_to_date(r["LILRCJ"]), 
        branch_code: jde_cabang(r["LIMCU"].strip), article: r["ARTICLE"].strip, panjang: r["PANJANG"].strip, 
        lebar: r["LEBAR"].strip)
    end
    generate_stock_for_capacities
    JdeItemAvailability.historical_stock
  end
  
  def self.generate_stock_for_capacities
    stock = find_by_sql("SELECT glcat, branch, brand, branch_code, SUM(onhand) AS onhand FROM warehouse.F41021_STOCK 
    WHERE DATE(created_at) = '#{Date.today}' AND branch NOT LIKE '%D' 
    AND branch_code IS NOT NULL AND brand != '' GROUP BY brand, branch_code, glcat;")
    stock.each do |st|
      ActiveRecord::Base.establish_connection("warehouse").connection.execute("
        INSERT INTO sales_mart.BRANCH_CAPACITIES (product, brand, branch, branch_jde, quantity, created_at) VALUES
        ('#{st.glcat}', '#{st.brand}', '#{st.branch_code}', '#{st.branch}', '#{st.onhand}', '#{Time.now}')
      ")
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
    elsif bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "12061S" || bu == "18061" || bu == "18061C" || bu == "18061D" || bu == "18061S" || bu == "18061" || bu == "18061C" || bu == "18061D" || bu == "18061S" #surabaya
      "07"
    elsif bu == "18151" || bu == "18151C" || bu == "18151D" || bu == "18152" || bu == "18151S" || bu == "18151K" || bu == "11151" #cikupa
      "23"
    elsif bu == "11030" || bu == "11031" ||  bu == "18031" || bu == "18031C" || bu == "18031D" || bu == "18032" || bu == "18031S" || bu == "18031K" #narogong
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
    elsif bu == "1801101" || bu == "1801101C" || bu == "1801101D" || bu == "1801101S" || bu == "1801101K" || bu == "1801201" || bu == "1801201C" || bu == "1801201D" || bu == "1801201S" || bu == "1801201K" #tasikmalaya
      "25"
    elsif bu == "1801102" || bu == "1801102C" || bu == "1801102D" || bu == "1801102S" || bu == "1801102K" || bu == "1801202" || bu == "1801202C" || bu == "1801202D" || bu == "1801202S" || bu == "1801202K" #sukabumi
      "28"
    elsif bu == "1801103" || bu == "1801103C" || bu == "1801103D" || bu == "1801103S" || bu == "1801103K" || bu == "1801203" || bu == "1801203C" || bu == "1801203D" || bu == "1801203S" || bu == "1801203K" #sukabumi
      "53"
    elsif bu.include?('1515') #new cikupa
      "23"
    elsif bu == "12171" || bu == "12172" || bu == "12171C" || bu == "12171D" || bu == "12171S" || bu == "18171" || bu == "18172" || bu == "18171C" || bu == "18171D" || bu == "18171S" || bu == "18172D" || bu == "18172" || bu == "18172K" #manado
      "26"
    elsif bu == "1206104" || bu == "1206204" || bu == "1206104C" || bu == "1206104D" || bu == "1206104S" || bu == "1806104" || bu == "1806104" || bu == "1806104C" || bu == "1806104D" || bu == "1806104S" || bu == "1806204D" || bu == "1806204" || bu == "1806204K" #kediri
      "54"
    elsif bu == "18181" || bu == "18182" || bu == "18181C" || bu == "18181D" || bu == "18181S" || bu == "18182C" || bu == "18182D" || bu == "18182S" #samarinda
      "55"
    end
  end
end