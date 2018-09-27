class JdeSoDetail < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F4211" #sd
  
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
  
  def self.import_sales_for_asong
    st = find_by_sql("SELECT MAX(sditm) AS sditm, MAX(sdtrdj), MAX(sdcomm), MAX(sdshan) AS sdshan, 
      sdmcu, MAX(sddeln) AS sddeln, MAX(sddrqj) AS sddrqj, SUM(sduorg) AS jumlah, MAX(sdsrp1) AS sdsrp1, 
      MAX(sddcto) AS sddcto, sddoco, MAX(sddsc1) AS sddsc1, MAX(sddsc2) AS sddsc2,
      MAX(sdlitm) AS sdlitm, MAX(sdtrdj) AS sdtrdj, MAX(sdlotn) AS sdlotn, MAX(sdaddj) AS sdaddj,
      MAX(sdvr01) AS vr, MAX(sdtday) AS sdtday, MAX(sdan8) AS sdan8 FROM PRODDTA.F4211 WHERE 
      sdtrdj = '#{date_to_julian(Date.today.to_date)}' AND  sdtday BETWEEN 
      '#{60.minutes.ago.change(sec: 0).strftime('%k%M%S')}' AND '#{Time.now.change(sec: 0).strftime('%k%M%S')}'
      AND sddcto IN ('SO','ZO') AND REGEXP_LIKE(sdsrp2,'KB|KM|DV|HB|SA|SB|ST') 
      GROUP BY sditm, sdmcu, sddoco ORDER BY sdtday")
    st.each do |det|
      item_master = JdeItemMaster.find_by_imitm(det.sditm)
      sales = JdeSalesman.find_salesman(det.sdan8.to_i, det.sdsrp1.strip)
      check_order = AsongOrder.find_by_sql("SELECT order_number FROM asong_orders WHERE order_number = '#{det.sddoco.to_i}'")
      unless check_order.present?
        AsongOrder.create!(branch_plant: det.sdmcu.strip, item_number: det.sdlitm.strip, branch: find_area(jde_cabang(det.sdmcu.strip)), short_item: det.sditm.to_i,
          description: det.sddsc1.strip + ' ' + det.sddsc2.strip, brand: item_master.imprgr.strip, 
          quantity: det.jumlah/10000, order_date: julian_to_date(det.sdtrdj), order_number: det.sddoco.to_i,
          order_time: det.sdtday.to_i, sales_name: sales)
      end
    end
  end
  
  def self.import_transfers_consigment
    cons = find_by_sql("SELECT ph.phrorn, MAX(ph.phrcto) AS phrcto, MAX(ph.phmcu) AS phmcu
    FROM PRODDTA.F4301 ph WHERE ph.phtrdj = '#{date_to_julian(Date.yesterday.to_date)}' 
    AND ph.phmcu LIKE '%#{'K'}' GROUP BY ph.phrorn
    ")
    cons.each do |c|
      st = find_by_sql("SELECT MAX(sditm) AS sditm, MAX(sdtrdj), MAX(sdcomm), MAX(sdshan) AS sdshan, MAX(sdmcu) AS sdmcu, 
        MAX(sddeln) AS sddeln, MAX(sddrqj) AS sddrqj, SUM(sduorg) AS jumlah, MAX(sdsrp1) AS sdsrp1, 
        MAX(sddcto) AS sddcto, MAX(sddoco) AS sddoco, MAX(sddsc1) AS sddsc1, MAX(sddsc2) AS sddsc2,
        MAX(sdlitm) AS sdlitm, MAX(sdtrdj) AS sdtrdj, MAX(sdlotn) AS sdlotn, MAX(sdaddj) AS sdaddj
        FROM PRODDTA.F4211
        WHERE sddoco = '#{c.phrorn}' AND sdcomm NOT LIKE '%#{'K'}%' AND sdnxtr = '999' AND sdlttr = '580' 
        GROUP BY sditm, sdlotn")
      st.each do |det|
        item_master = JdeItemMaster.find_by_imitm(det.sditm)
        customer = JdeCustomerMaster.find_by_aban8(det.sdshan.to_i)
        Consigment.create!(order_no: c.phrorn, sales_id: det.sdshan.to_i, branch: jde_cabang(det.sdmcu),
          brand: item_master.imprgr, item_number: det.sdlitm.strip, description: "#{det.sddsc1.strip} " "#{det.sddsc2.strip}",
          quantity: det.jumlah/10000, order_date: julian_to_date(det.sdtrdj.to_i), lot_number: det.sdlotn.strip,
          sales_name: customer.abalph.strip, delivery_date: julian_to_date(det.sdaddj)
        )
      end
    end
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
    AND so.sddrqj > '#{date_to_julian(Date.today.to_date)}' AND sddcto LIKE '%#{'SO'}%' AND 
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
    MAX(so.sdsrp1) AS sdsrp1, MAX(so.sdmcu) AS sdmcu, MAX(so.sddrqj) AS sddrqj, MAX(so.sdtrdj) AS sdtrdj
    FROM PRODDTA.F4211 so
    JOIN PRODDTA.F0101 cust ON so.sdshan = cust.aban8
    JOIN PRODDTA.F40344 sls ON so.sdshan = sls.saan8
    JOIN PRODDTA.F0101 cust1 ON cust1.aban8 = sls.saslsm
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    WHERE cust.absic LIKE '%RET%' AND itm.imseg4 NOT LIKE '%K%' 
    AND so.sddrqj < '#{date_to_julian(Date.today.to_date)}' AND REGEXP_LIKE(sddcto,'SO|ZO') AND 
    so.sdnxtr LIKE '%#{525}%'
    AND REGEXP_LIKE(so.sdsrp2,'KM|HB|DV|SA|SB|KB') GROUP BY so.sddoco, so.sdan8, so.sdsrp1, so.sdmcu")
    SalesOutstandingOrder.delete_all
    outstanding.each do |ou|
      SalesOutstandingOrder.create(order_no: ou.sddoco.to_i, customer: ou.abalph.strip, 
      promised_delivery: julian_to_date(ou.sddrqj), branch: ou.sdmcu.strip, 
      brand: ou.sdsrp1.strip, exceeds: (Date.today - julian_to_date(ou.sdopdj)).to_i, 
      salesman: ou.salesman.strip, order_date: julian_to_date(ou.sdtrdj), area: find_area(jde_cabang(ou.sdmcu.strip)))
    end
  end

  #import sales order, tax and return from standard invoices
  def self.import_sales
    invoices = find_by_sql("SELECT * FROM PRODDTA.F03B11 WHERE 
    rpdicj BETWEEN '#{date_to_julian(Date.yesterday.to_date)}' AND '#{date_to_julian(Date.today.to_date)}'  
    AND REGEXP_LIKE(rpdct,'RI|RX|RO|RM') AND rpsdoc > 1")
    invoices.each do |iv|
      order = 
      if iv.rpdct.strip == 'RM'
        where("sddoco = ? and sdlitm = ? and sdnxtr = ? and sdlttr = ?
      and sddcto IN ('SO','ZO','CO')", iv.rpsdoc, iv.rprmk, "999", "580").first
      else
        where("sddoco = ? and sddcto IN ('SO','ZO','CO') and sdlnid = '#{iv.rplnid}'", iv.rpsdoc).first
      end
      if order.present?
        checking =
        if iv.rpdct.strip == 'RM'
          LaporanCabang.find_by_sql("SELECT id FROM tblaporancabang WHERE noso LIKE '#{order.sddoco}'
        AND kodebrg LIKE '#{order.sdlitm.strip}' AND harganetto2 = '#{iv.rpag.to_i}' AND orty = '#{iv.rpdct.strip}'")
        else
          LaporanCabang.find_by_sql("SELECT id FROM tblaporancabang WHERE nosj LIKE '#{order.sddeln.to_i}'
        AND kodebrg LIKE '#{order.sdlitm.strip}' AND lnid = '#{order.sdlnid.to_i}'")
        end
        if checking.empty?
        fullnamabarang = "#{order.sddsc1.strip} " "#{order.sddsc2.strip}"
        customer = JdeCustomerMaster.find_by_aban8(order.sdan8)
        bonus = iv.rpag.to_i == 0 ?  'BONUS' : '-'
        if customer.abat1.strip == "C" && order.sdaddj != 0
          namacustomer = customer.abalph.strip
          cabang = jde_cabang(iv.rpmcu.to_i.to_s.strip)
          area = find_area(cabang)
          item_master = JdeItemMaster.find_by_imitm(order.sditm)
          jenis = JdeUdc.jenis_udc(item_master.imseg1.strip)
          artikel = JdeUdc.artikel_udc(item_master.imseg2.strip)
          kain = JdeUdc.kain_udc(item_master.imseg3.strip)
          groupitem = JdeUdc.group_item_udc(order.sdsrp3.strip)
          harga = JdeBasePrice.harga_satuan(order.sditm, order.sdmcu.strip, order.sdtrdj)
          kota = JdeAddressByDate.get_city(order.sdan8.to_i)
          group = JdeCustomerMaster.get_group_customer(order.sdan8.to_i)
          variance = order.sdaddj == 0 ? 0 : (julian_to_date(order.sdaddj)-julian_to_date(order.sdppdj)).to_i
          sales = JdeSalesman.find_salesman(order.sdan8.to_i, order.sdsrp1.strip)
          sales_id = JdeSalesman.find_salesman_id(order.sdan8.to_i, order.sdsrp1.strip)
          # customer_master = Customer.where(address_number: order.sdan8.to_i)
          customer_brand = CustomerBrand.where(address_number: order.sdan8.to_i, brand: item_master.imprgr.strip)
          if customer_brand.empty? || customer_brand.nil?
            CustomerBrand.create!(address_number: order.sdan8.to_i, brand: item_master.imprgr.strip, 
            last_order: julian_to_date(order.sdaddj), branch: area, customer: namacustomer, channel_group: group)
          elsif customer_brand.first.last_order != julian_to_date(order.sdaddj)
            customer_brand.first.update_attributes!(last_order: julian_to_date(order.sdaddj), branch: area)
            # customer_master.first.update_attributes!(last_order_date: julian_to_date(order.sdaddj))
          end
          vorty = iv.rpdct.strip == 'RM' ? 'RM' : order.sddcto.strip
          sales_type = iv.rpmcu.to_i.to_s.strip.include?("K") ? 1 : 0 #checking if konsinyasi
          LaporanCabang.create(cabang_id: cabang, noso: order.sddoco.to_i, tanggal: julian_to_date(order.sdtrdj), nosj: order.sddeln.to_i, tanggalsj: julian_to_date(iv.rpdivj),
            kodebrg: order.sdlitm.strip,
            namabrg: fullnamabarang, kode_customer: order.sdan8.to_i, customer: namacustomer, jumlah: iv.rpu.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: item_master.imprgr.strip, kodejenis: item_master.imseg1.strip, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..7], namaartikel: artikel,
            kodekain: item_master.imseg3.strip, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
            hargasatuan: harga/10000, harganetto1: iv.rpag, harganetto2: iv.rpag, kota: kota, tipecust: group, bonus: bonus, lnid: order.sdlnid.to_i, ketppb: "",
            salesman: sales, diskon5: variance, orty: vorty, nopo: sales_id, fiscal_year: julian_to_date(iv.rpdivj).to_date.year,
            fiscal_month: julian_to_date(iv.rpdivj).to_date.month, week: julian_to_date(iv.rpdivj).to_date.cweek,
            area_id: area, ketppb: iv.rpmcu.strip, totalnetto1: sales_type)
         end
        end
      end
    end
  end

  #import credit note
  def self.import_credit_note
    credit_note = find_by_sql("SELECT * FROM PRODDTA.F03B11 WHERE 
    rpupmj = '#{date_to_julian(Date.yesterday.to_date)}'  
    AND rpdct LIKE '%RM' AND rpsdoc > 1")
    credit_note.each do |cr|
      no_doc = cr.rpsdoc
      lp = LaporanCabang.where("noso = '#{no_doc}' AND kodebrg = '#{cr.rprmk.strip}'").first
      unless lp.nil?
        rm = LaporanCabang.where("noso = '#{no_doc}' AND kodebrg = '#{cr.rprmk.strip}' AND orty = 'RM' AND
        lnid = '#{cr.rpsfx}' AND kode_customer = 'cr.rpan8'").first
        if rm.nil?
          LaporanCabang.create(cabang_id: lp.cabang_id, noso: lp.noso, tanggal: lp.tanggal, 
            nosj: lp.nosj, tanggalsj: julian_to_date(cr.rpdivj), kodebrg: lp.kodebrg,
            namabrg: lp.namabrg, kode_customer: lp.kode_customer, customer: lp.customer, 
            jumlah: lp.jumlah, satuan: "PC", nofaktur: cr.rpdoc,
            jenisbrgdisc: lp.jenisbrgdisc, kodejenis: lp.kodejenis, jenisbrg: lp.jenisbrg, 
            kodeartikel: lp.kodeartikel, namaartikel: lp.namaartikel,
            kodekain: lp.kodekain, namakain: lp.namakain, panjang: lp.panjang, 
            lebar: lp.lebar, namabrand: lp.namabrand, hargasatuan: lp.hargasatuan, 
            harganetto1: cr.rpaap, harganetto2: cr.rpaap, kota: lp.kota, 
            tipecust: lp.tipecust, bonus: lp.bonus, lnid: cr.rpsfx, ketppb: "", 
            salesman: lp.salesman, diskon5: lp.diskon5, orty: 'RM', 
            nopo: lp.nopo, fiscal_year: julian_to_date(cr.rpdivj).year, fiscal_month: julian_to_date(cr.rpdivj).month, week: julian_to_date(cr.rpdivj).cweek,
            area_id: lp.area_id)
        end
      end
      # end
    end
  end
  
  # import account receivable 
  def self.import_acc_receivable
    ar = find_by_sql("SELECT MAX(RPDOC) AS RPDOC, MAX(RPDCT) AS RPDCT, SUM(RPAG) AS RPAG,
    SUM(RPAAP) AS RPAAP, MAX(RPMCU) AS RPMCU, MAX(RPPST) AS RPPST, MAX(RPRMK) AS RPRMK,
    MAX(RPAN8) AS RPAN8, MAX(RPALPH) AS RPALPH, MAX(RPSFX) AS RPSFX, MAX(RPAR10) AS RPAR10,
    MAX(RPDDJ) AS RPDDJ, MAX(RPOMOD) AS RPOMOD, MAX(RPDIVJ) AS RPDIVJ, MAX(RPDGJ) AS RPDGJ,
    MAX(RPJCL) AS RPJCL, MAX(RPUPMJ) AS RPUPMJ, MAX(RPAR10) AS RPAR10 FROM PRODDTA.F03B11 WHERE rpupmj =
    '#{date_to_julian(Date.today.to_date)}' 
    AND REGEXP_LIKE(rpdct,'RI|RX|RO|RM')
    AND rpsdoc > 1 GROUP BY RPMCU, RPAN8, RPDOC, RPDCT")
    ar.each do |ars|
      cek_ava = AccountReceivable.where(doc_number: ars.rpdoc, doc_type: ars.rpdct, branch: ars.rpmcu.strip)
      if cek_ava.empty?
        group = JdeCustomerMaster.get_group_customer(ars.rpan8.to_i)
        if group == 'RETAIL'
          cabang = jde_cabang(ars.rpmcu.to_i.to_s.strip)
          dpd = Date.today - julian_to_date(ars.rpddj)
          sales = JdeSalesman.find_salesman(ars.rpan8.to_i, ars.rpar10.strip)
          sales_id = JdeSalesman.find_salesman_id(ars.rpan8.to_i, ars.rpar10.strip)
          im = JdeItemMaster.where("imlitm LIKE '%#{ars.rprmk.strip}%'").first
          item_master = ars.rpomod == '3' ? (im.nil? ? '-' : im.imprgr.strip) : '-'
          AccountReceivable.create(doc_number: ars.rpdoc, doc_type: ars.rpdct.strip,
          invoice_date: julian_to_date(ars.rpdivj), gross_amount: ars.rpag, open_amount: ars.rpaap,
          due_date: julian_to_date(ars.rpddj), days_past_due: dpd, branch: cabang,
          pay_status: ars.rppst, remark: ars.rprmk.strip, customer_number: ars.rpan8,
          customer: ars.rpalph.strip, gl_date: julian_to_date(ars.rpdgj),
          actual_close_date: julian_to_date(ars.rpjcl), date_updated: julian_to_date(ars.rpupmj),
          fiscal_month: julian_to_date(ars.rpddj).month, fiscal_year: julian_to_date(ars.rpddj).year,
          pay_item: ars.rpsfx, customer_group: group, updated_at: Time.zone.now, salesman: sales, 
          salesman_no: sales_id, brand: item_master)
        end
      elsif cek_ava.first.open_amount != ars.rpaap
        # dpd = julian_to_date(ars.rpjcl) - julian_to_date(ars.rpddj)
        cek_ava.first.update_attributes!(open_amount: ars.rpaap, actual_close_date: julian_to_date(ars.rpjcl), pay_status: ars.rppst)
      end
    end
  end

  # monthly calculate success rate
  def self.calculate_success_rate
  end

  #use this if sales of a branch not working
  def self.import_so_detail_with_range
    where("sdnxtr >= ? and sdlttr >= ? and sddcto = ? and sdaddj BETWEEN ? AND ?",
    "580", "565", "SO", date_to_julian('01/01/2018'.to_date), date_to_julian('09/01/2017'.to_date)).each do |a|
      find_sj = LaporanCabang.where(nosj: a.sddeln.to_i, lnid: a.sdlnid.to_i)
      if find_sj.empty?
        fullnamabarang = "#{a.sddsc1.strip} " "#{a.sddsc2.strip}"
        customer = JdeCustomerMaster.find_by_aban8(a.sdan8)
        bonus = a.sdaexp == 0 ?  'BONUS' : '-'
        if customer.abat1.strip == "C"
          namacustomer = customer.abalph.strip
          cabang = jde_cabang(a.sdmcu.to_i.to_s.strip)
          item_master = JdeItemMaster.find_by_imitm(a.sditm)
          jenis = JdeUdc.jenis_udc(item_master.imseg1.strip)
          artikel = JdeUdc.artikel_udc(item_master.imseg2.strip)
          kain = JdeUdc.kain_udc(item_master.imseg3.strip)
          groupitem = JdeUdc.group_item_udc(a.sdsrp3.strip)
          harga = JdeBasePrice.harga_satuan(a.sditm, a.sdmcu.strip, a.sdtrdj)
          kota = JdeAddressByDate.get_city(a.sdan8.to_i)
          group = JdeCustomerMaster.get_group_customer(a.sdan8.to_i)
         sales = JdeSalesman.find_salesman(a.sdan8.to_i, a.sdsrp1.strip)
          LaporanCabang.create(cabang_id: cabang, noso: a.sddoco.to_i, nosj: a.sddeln.to_i, tanggalsj: julian_to_date(a.sdaddj),kodebrg: a.sdlitm.strip,
            namabrg: fullnamabarang, kode_customer: a.sdan8.to_i, customer: namacustomer, jumlah: a.sdsoqs.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: item_master.imprgr.strip, kodejenis: item_master.imseg1.strip, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..5], namaartikel: artikel,
            kodekain: item_master.imseg3.strip, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
            hargasatuan: harga/10000, harganetto1: a.sdaexp, harganetto2: a.sdaexp, kota: kota, tipecust: group, bonus: bonus, lnid: a.sdlnid.to_i, ketppb: "",
            salesman: sales)
        end
      end
    end
  end
  
  def self.update_salesman
    reports = LaporanCabang.select("kode_customer, nopo, salesman, jenisbrgdisc").where("fiscal_year = 2017 and nopo is null or nopo = ''")
    reports.each do |rp|
      if rp.jenisbrgdisc.present?
        sales = JdeSalesman.find_salesman(rp.kode_customer, rp.jenisbrgdisc[0])
        sales_id = JdeSalesman.find_salesman_id(rp.kode_customer, rp.jenisbrgdisc[0])
        rp.update_attributes!(salesman: sales, nopo: sales_id)
      end
    end
  end

  #test_import sales order, tax and return from standard invoices
  def self.test_import_sales
    invoices = find_by_sql("SELECT * FROM PRODDTA.F03B11 WHERE 
    rpdicj BETWEEN '#{date_to_julian('01/08/2018'.to_date)}' AND '#{date_to_julian('31/08/2018'.to_date)}'  
    AND REGEXP_LIKE(rpdct,'RI|RX|RO|RM') AND rpsdoc > 1")
    invoices.each do |iv|
        customer = JdeCustomerMaster.find_by_aban8(iv.rpan8)
        bonus = iv.rpag.to_i == 0 ?  'BONUS' : '-'
        if customer.abat1.strip == "C" && order.sdaddj != 0
          namacustomer = customer.abalph.strip
          cabang = jde_cabang(iv.rpmcu.to_i.to_s.strip)
          area = find_area(cabang)
          item_master = JdeItemMaster.find_by_imitm(iv.rpitm)
        fullnamabarang = "#{item_master.imdsc1.strip} " "#{item_master.imdsc2.strip}"
          jenis = JdeUdc.jenis_udc(item_master.imseg1.strip)
          artikel = JdeUdc.artikel_udc(item_master.imseg2.strip)
          kain = JdeUdc.kain_udc(item_master.imseg3.strip)
          groupitem = JdeUdc.group_item_udc(order.sdsrp3.strip)
          # harga = JdeBasePrice.harga_satuan(order.sditm, order.sdmcu.strip, order.sdtrdj)
          kota = JdeAddressByDate.get_city(iv.rpan8.to_i)
          group = JdeCustomerMaster.get_group_customer(iv.rpan8.to_i)
          # variance = order.sdaddj == 0 ? 0 : (julian_to_date(order.sdaddj)-julian_to_date(order.sdppdj)).to_i
          sales = JdeSalesman.find_salesman(iv.rpan8.to_i, order.sdsrp1.strip)
          sales_id = JdeSalesman.find_salesman_id(order.sdan8.to_i, order.sdsrp1.strip)
          # customer_master = Customer.where(address_number: order.sdan8.to_i)
          customer_brand = CustomerBrand.where(address_number: iv.rpan8.to_i, brand: item_master.imprgr.strip)
          if customer_brand.empty? || customer_brand.nil?
            CustomerBrand.create!(address_number: iv.rpan8.to_i, brand: item_master.imprgr.strip, 
            last_order: julian_to_date(iv.rpdivj), branch: area, customer: namacustomer, channel_group: group)
          elsif customer_brand.first.last_order != julian_to_date(iv.rpdivj)
            customer_brand.first.update_attributes!(last_order: julian_to_date(iv.rpdivj), branch: area)
            # customer_master.first.update_attributes!(last_order_date: julian_to_date(order.sdaddj))
          end
          vorty = iv.rpdct.strip == 'RM' ? 'RM' : order.sddcto.strip
          sales_type = iv.rpmcu.to_i.to_s.strip.include?("K") ? 1 : 0 #checking if konsinyasi
          LaporanCabang.create(cabang_id: cabang, noso: iv.rpsdoc.to_i, nosj: order.sddeln.to_i, tanggalsj: julian_to_date(iv.rpdivj),
            kodebrg: item_master.imlitm.strip,
            namabrg: fullnamabarang, kode_customer: iv.rpan8.to_i, customer: namacustomer, jumlah: iv.rpu.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: item_master.imprgr.strip, kodejenis: item_master.imseg1.strip, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..7], namaartikel: artikel,
            kodekain: item_master.imseg3.strip, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
            hargasatuan: harga/10000, harganetto1: iv.rpag, harganetto2: iv.rpag, kota: kota, tipecust: group, bonus: bonus, ketppb: "",
            salesman: sales, diskon5: variance, orty: vorty, nopo: sales_id, fiscal_year: julian_to_date(iv.rpdivj).to_date.year,
            fiscal_month: julian_to_date(iv.rpdivj).to_date.month, week: julian_to_date(iv.rpdivj).to_date.cweek,
            area_id: area, ketppb: iv.rpmcu.strip, totalnetto1: sales_type)
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
