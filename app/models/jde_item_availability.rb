class JdeItemAvailability < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f41021" #sd
  # attr_accessible :lilotn, :lilrcj
  # self.primary_key = 'lilotn'
  
  #import stock hourly
  def self.import_stock_hourly
    stock = self.find_by_sql("SELECT IA.liitm AS liitm, 
    IA.limcu AS limcu, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom 
    FROM PRODDTA.F41021 IA WHERE IA.lipqoh >= 10000
    GROUP BY IA.liitm, IA.limcu")
    stock.each do |st|
      cek_stock = Stock.where(short_item: st.liitm, branch: st.limcu.strip)
      if cek_stock.present? && cek_stock.first.available != st.lihcom/10000
        cek_stock.first.update_attributes!(onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000)
      elsif cek_stock.nil?
        item_master = ItemMaster.find_by_short_item_no(st.liitm)
        unless item_master.nil?
          status = /\A\d+\z/ === st.limcu.strip.last ? 'N' : st.limcu.strip.last
          description = item_master.desc+' '+item_master.desc2
          Stock.create(branch: st.limcu.strip, brand: item_master.slscd1, description: description,
            item_number: item_master.item_number, onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000, 
            status: status, product: item_master.segment2, short_item: item_master.short_item_no)
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
end
