class JdeItemAvailability < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f41021" #sd
  # attr_accessible :lilotn, :lilrcj
  # self.primary_key = 'lilotn'
  
  def self.checking_stock_asong(short_item, branch_plant)
    us = self.find_by_sql("SELECT TRIM(IA.lilotn) AS lilotn 
    FROM PRODDTA.F41021 IA WHERE
    NOT REGEXP_LIKE(liglpt, 'WIP|MAT') AND lihcom < '10000' AND lipqoh >= '10000'
    AND limcu LIKE '%#{branch_plant}%' AND liitm = '#{short_item}'")
  end
  
  #import buffer daily
  def self.import_buffer_daily
    ibranch = find_by_sql("SELECT ibitm, MAX(iblitm) AS iblitm, ibmcu,
      MAX(ibsafe) AS ibsafe FROM PRODDTA.F4102 WHERE ibsafe > 0 GROUP BY ibitm, ibmcu 
    ")
    ibranch.each do |ib|
      get_ib = ItemBranch.where("short_item = ? AND area = ?", ib.ibitm, jde_cabang(ib.ibmcu.strip))
      if get_ib.present?
        get_ib.first.update_attributes!(quantity: ib.ibsafe.to_i/10000)
      else
        ItemBranch.create!(item_number: ib.iblitm, short_item: ib.ibitm, area: jde_cabang(ib.ibmcu.strip), 
        branch: ib.ibmcu.strip, quantity: ib.ibsafe.to_i/10000)
      end
    end
  end
  
  #import stock hourly
  def self.import_stock_hourly
    us = self.find_by_sql("SELECT IA.liitm AS liitm, 
    IA.limcu AS limcu, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom 
    FROM PRODDTA.F41021 IA WHERE  
    NOT REGEXP_LIKE(liglpt, 'WIP|MAT')
     AND lipbin = 'S' AND liupmj = '#{date_to_julian(Date.today)}' AND litday >=
    '#{2.minutes.ago.change(sec: 0).strftime('%k%M%S')}'
    GROUP BY IA.liitm, IA.limcu")
    us.each do |fus|
      stock = self.find_by_sql("SELECT IA.liitm AS liitm, 
      IA.limcu AS limcu, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom 
      FROM PRODDTA.F41021 IA WHERE liitm = '#{fus.liitm}' AND 
      limcu LIKE '#{fus.limcu}' AND lipbin = 'S' GROUP BY IA.liitm, IA.limcu")
      stock.each do |st|
        cek_stock = Stock.where(short_item: st.liitm.to_i, branch: st.limcu.strip)
        st.update_attributes!(onhand: 0, available: 0) if stock.empty?
        if cek_stock.present?
          cek_stock.first.update_attributes!(onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000)
        elsif cek_stock.empty?
          item_master = self.find_by_sql("SELECT MAX(imitm) AS imitm, MAX(imseg2) AS imseg2, 
          MAX(imdsc1) AS imdsc1,
          MAX(imdsc2) AS imdsc2, MAX(imlitm) AS imlitm, MAX(imsrp1) AS imsrp1,
          MAX(imseg1) AS imseg1, MAX(imseg2) AS imseg2, MAX(imseg6) AS imseg6 FROM PRODDTA.F4101 im 
          WHERE imitm LIKE '#{st.liitm.to_i}' AND imtmpl LIKE '%BJ MATRASS%'")
          unless item_master.nil?
            status = /\A\d+\z/ === st.limcu.strip.last ? 'N' : st.limcu.strip.last
            description = item_master.first.imdsc1.nil? ? ' ' : (item_master.first.imdsc1.strip+' '+item_master.first.imdsc2.strip)
            Stock.create(branch: st.limcu.strip, brand: item_master.first.imsrp1, description: description,
              item_number: item_master.first.imlitm, onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000, 
              status: status, product: item_master.first.imseg1, short_item: item_master.first.imitm.to_i, 
              area_id: jde_cabang(st.limcu.strip), article: item_master.first.imseg2, size: item_master.first.imseg6)
          end
        end
      end
    end
  end
  
  def self.checking_stock_weekly
    stock_cek = Stock.find_by_sql("SELECT * FROM stocks WHERE DATE(updated_at) BETWEEN '#{7.days.ago.to_date}'
    AND '#{Date.today}'")
    stock_cek.each do |sc|
      stock = self.find_by_sql("SELECT IA.liitm AS liitm, 
      IA.limcu AS limcu, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom 
      FROM PRODDTA.F41021 IA WHERE liitm = '#{sc.short_item}' AND 
      limcu LIKE '%#{sc.branch}' AND lipbin = 'S' GROUP BY IA.liitm, IA.limcu")
      stock.each do |st|
        cek_stock = Stock.where(short_item: st.liitm.to_i, branch: st.limcu.strip)
        st.update_attributes!(onhand: 0, available: 0) if stock.empty?
        if cek_stock.present?
          cek_stock.first.update_attributes!(onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000)
        end
      end
    end
  end
  
  def self.checking_stock_daily
    stock_cek = Stock.find_by_sql("SELECT * FROM stocks WHERE DATE(updated_at) BETWEEN '#{Date.yesterday}'
    AND '#{Date.today}'")
    stock_cek.each do |sc|
      stock = self.find_by_sql("SELECT IA.liitm AS liitm, 
      IA.limcu AS limcu, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom 
      FROM PRODDTA.F41021 IA WHERE liitm = '#{sc.short_item}' AND 
      limcu LIKE '%#{sc.branch}' AND lipbin = 'S' GROUP BY IA.liitm, IA.limcu")
      stock.each do |st|
        cek_stock = Stock.where(short_item: st.liitm.to_i, branch: st.limcu.strip)
        st.update_attributes!(onhand: 0, available: 0) if stock.empty?
        if cek_stock.present?
          cek_stock.first.update_attributes!(onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000)
        end
      end
    end
  end
  
  def self.trial_stock_cam
    stock_cek = Stock.find_by_sql("SELECT * FROM stocks WHERE updated_at <= '2018-02-04' AND branch = 18011")
    stock_cek.each do |sc|
      stock = self.find_by_sql("SELECT IA.liitm AS liitm, 
      IA.limcu AS limcu, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom 
      FROM PRODDTA.F41021 IA WHERE liitm = '#{sc.short_item}' AND 
      limcu LIKE '%#{sc.branch}' AND lipbin = 'S' GROUP BY IA.liitm, IA.limcu")
      stock.each do |st|
        cek_stock = Stock.where(short_item: st.liitm.to_i, branch: st.limcu.strip)
        st.update_attributes!(onhand: 0, available: 0) if stock.empty?
        if cek_stock.present?
          cek_stock.first.update_attributes!(onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000)
        end
      end
    end
  end

  def self.import_stock_hourly_display
    stock = find_by_sql("Select ST.sdshan, IL.ildoco, imsrp1, IA.liitm AS liitm, IM.imlitm, IA.limcu,
    IL.ildoc, IL.ildct, IA.lipqoh, IA.lihcom, IA.lilotn, IM.imlitm, IM.imdsc1, IM.imdsc2, 
    IA.liglpt, NVL(CM.abalph, IL.iltrex) AS abalph, IL.ilcrdj FROM (
      (
        SELECT MAX(lilrcj) AS lilrcj, MAX(liitm) AS liitm, limcu, SUM(lipqoh) AS lipqoh, 
        SUM(lihcom) AS lihcom, lilotn, MAX(liglpt) AS liglpt FROM PRODDTA.F41021
        WHERE REGEXP_LIKE(liglpt,'KM|HB|DV|SA|SB|ST|KB') 
        GROUP BY limcu, lilotn
      ) IA                  
      LEFT JOIN
      (
        SELECT MAX(ilcrdj) AS ilcrdj, ildoco, ildoc, ildct, illotn, MAX(iltrex) AS iltrex 
          FROM PRODDTA.F4111 GROUP BY ildoco, ildoc, ildct, illotn ORDER BY ilcrdj DESC
      ) IL ON IA.lilotn = IL.illotn AND IA.lilrcj = IL.ilcrdj
      LEFT JOIN
      (
        SELECT sdshan, sdlotn, sddoco, MAX(sdrorn) AS sdrorn FROM PRODDTA.F4211
        GROUP BY sdshan, sdlotn, sddoco
      ) ST ON IL.ildoco LIKE ST.sdrorn AND IL.illotn = ST.sdlotn
      LEFT JOIN
      (
        SELECT imitm, MAX(imsrp1) AS imsrp1, MAX(imlitm) AS imlitm, 
        MAX(imdsc1) AS imdsc1, MAX(imdsc2) AS imdsc2 FROM PRODDTA.F4101
        WHERE imtmpl LIKE '%BJ MATRASS%' AND REGEXP_LIKE(imsrp2,'KM|HB|DV|SA|SB|ST|KB') GROUP BY imitm
      ) IM ON IA.liitm = IM.imitm
      LEFT JOIN
      (
        SELECT abalph, aban8 FROM PRODDTA.F0101 
      ) CM ON ST.sdshan = CM.aban8
    )")
    stock.each do |st|
        unless st.imdsc1.nil?
        status = /\A\d+\z/ === st.limcu.strip.last ? 'N' : st.limcu.strip.last
        description = st.imdsc1.nil? ? '-' : (st.imdsc1.strip+' '+st.imdsc2.strip)
        v_age = Date.today - julian_to_date(st.ilcrdj)
        cek_stock = DisplayStock.where(lot_serial: st.lilotn.strip)
        if cek_stock.empty? || cek_stock.nil?
          DisplayStock.create(branch: st.limcu.strip, brand: st.liglpt.strip[2], description: description,
          item_number: st.imlitm.strip, onhand: st.lipqoh/10000, 
          available: (st.lipqoh - st.lihcom)/10000, status: status, customer: st.abalph,
          lot_serial: st.lilotn.strip, doc_number: st.ildoc, age: v_age, doc_type: st.ildct, 
          product: st.imlitm.strip[0..1])
        elsif st.lilotn.strip == cek_stock.first.lot_serial && 
          (st.ildoc != cek_stock.first.doc_number || st.lipqoh/10000 != cek_stock.first.onhand || 
          st.lihcom/10000 != cek_stock.first.available || 
          (st.abalph.nil? ? st.abalph : st.abalph.strip) != cek_stock.first.customer)
           cek_stock.first.update_attributes!( doc_number: st.ildoc, customer: (st.abalph.nil? ? st.abalph : st.abalph.strip),
           onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000, product: st.imlitm.strip[0..1])
        end
      end
    end
  end

  #import beginning of week stock
  def self.import_beginning_week_of_stock
    stock = self.find_by_sql("SELECT IA.liitm AS liitm, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom, 
    MAX(IM.imlitm) AS imlitm, MAX(IM.imdsc1) AS imdsc1, MAX(IM.imdsc2) AS imdsc2, MAX(IM.imaitm) AS imaitm, MAX(IM.imseg1) AS imseg1, 
    MAX(IM.imseg2) AS imseg2, IA.limcu, MAX(IM.imseg2) AS imseg2, MAX(IM.imseg6) AS imseg6,
    MAX(IM.imseg5) AS imseg5, MAX(IM.imprgr) AS imprgr FROM PRODDTA.F41021 IA 
    JOIN PRODDTA.F4101 IM ON IA.liitm = IM.imitm
    WHERE IA.lipqoh >= 1 AND IM.imtmpl LIKE '%BJ MATRASS%' AND REGEXP_LIKE(IM.imsrp2,'KM|HB|DV|KB')
    GROUP BY IA.liitm, IA.limcu")
    stock.each do |st|
      item_master = JdeItemMaster.find_by_imitm(st.liitm)
      artikel = JdeUdc.artikel_udc(st.imseg2.strip)
      description = st.imdsc1.strip+' '+st.imdsc2.strip
      cabang = jde_cabang(st.limcu.to_i.to_s.strip)
      status = /\A\d+\z/ === st.limcu.strip.last ? 'N' : st.limcu.strip.last
      BomStock.create!(branch: cabang, brand: st.imprgr.strip, fiscal_year: Date.today.year, 
      fiscal_month: Date.today.month, week: Date.today.cweek, item_number: st.imaitm.strip, description: description, product: st.imseg1.strip,
      article: artikel, long: st.imseg5.to_i, wide: st.imseg6.to_i, qty: st.lipqoh/10000, status: status)
    end
  end
  

  def self.available
    where("limcu like ? and lipqoh >= ?", "%11011", 1)
  end
  
  def self.stock_periods
    find_by_sql("SELECT * FROM PRODDTA.F41021 WHERE lilotn > 1 AND 
    limcu LIKE '%#{11011}' AND lipqoh >= 1 GROUP BY ")
  end
  
  def self.update_last_receipt(serial, branch, date)
    a = find_by_sql("SELECT * FROM PRODDTA.F41021 WHERE lilotn LIKE '%#{serial}%' AND 
    limcu LIKE '%#{branch}'").first
    unless a.nil?
      # a.lilrcj = date
      # a.save!
      a.update_attributes!(lilrcj: date)
      CsYearBarcode.find_by_barcode(serial).update_attributes!(updated: true)
    end
  end
  
  def self.find_last_receipt
    serialized = find_by_sql("SELECT liitm, limcu, lilotn, liglpt, lilrcj FROM PRODDTA.F41021 
    WHERE lipqoh >= 1 AND liupmj >= '#{date_to_julian(Date.yesterday)}'")
    serialized.each do |sr|
      find_serial = PeriodSerialStock.find_by_serial_and_branch(sr.lilotn, limcu)
      if find_serial.present?
        find_serial.update_attributes!(onhand: sr.lipqoh)
      else
        date_receipt = julian_to_date(lilrcj)
        PerioSerialStock.create!(short_item_no: sr.liitm, serial: sr.lilotn, product: sr.liglpt,
        branch: sr.limcu, last_receipt_date: date_receipt, last_receipt_day: date_receipt.day,
        last_receipt_month: date_receipt.month, last_receipt_year: date_receipt_year,
        last_updated_at: Date.today, onhand: sr.lipqoh)
      end
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
    elsif bu == "18031" || bu == "18031C" || bu == "18031D" || bu == "18032" || bu == "18031S" || bu == "18031K" #narogong
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
    end
  end
end
