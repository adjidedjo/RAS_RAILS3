class JdeSoDetail < ActiveRecord::Base
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
    outstanding = find_by_sql("SELECT MAX(so.sdopdj) AS sdopdj, so.sddoco, so.sdan8, MAX(so.sdshan), MAX(so.sddrqj), 
    MAX(cust.abalph) AS abalph, MAX(so.sdshan), MAX(cust1.abalph) AS salesman, SUM(so.sduorg) AS jumlah,
    MAX(so.sdsrp1) AS sdsrp1, MAX(so.sdmcu) AS sdmcu
    FROM PRODDTA.F4211 so
    JOIN PRODDTA.F0101 cust ON so.sdshan = cust.aban8
    JOIN PRODDTA.F40344 sls ON so.sdshan = sls.saan8
    JOIN PRODDTA.F0101 cust1 ON cust1.aban8 = sls.saslsm
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    WHERE cust.absic LIKE '%RET%' AND so.sdcomm NOT LIKE '%#{'K'}%' 
    AND sls.saexdj > '#{date_to_julian(Date.today.to_date)}' AND sddcto LIKE '%#{'SO'}%' AND 
    so.sdnxtr LIKE '%#{560}%'
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
    MAX(so.sdsrp1) AS sdsrp1, MAX(so.sdmcu) AS sdmcu
    FROM PRODDTA.F4211 so
    JOIN PRODDTA.F0101 cust ON so.sdshan = cust.aban8
    JOIN PRODDTA.F40344 sls ON so.sdshan = sls.saan8
    JOIN PRODDTA.F0101 cust1 ON cust1.aban8 = sls.saslsm
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    WHERE cust.absic LIKE '%RET%' AND so.sdcomm NOT LIKE '%#{'K'}%' 
    AND sls.saexdj > '#{date_to_julian(Date.today.to_date)}' AND sddcto LIKE '%#{'SO'}%' AND 
    so.sdnxtr LIKE '%#{525}%'
    AND REGEXP_LIKE(so.sdsrp2,'KM|HB|DV|SA|SB|KB') GROUP BY so.sddoco, so.sdan8, so.sdsrp1, so.sdmcu")
    outstanding.each do |ou|
      OutstandingOrder.create(order_no: ou.sddoco.to_i, customer: ou.abalph.strip, 
      promised_delivery: julian_to_date(ou.sdopdj), branch: ou.sdmcu.strip, 
      brand: ou.sdsrp1.strip, exceeds: (Date.today - julian_to_date(ou.sdopdj)).to_i, 
      salesman: ou.salesman.strip)
    end
  end

  #import sales order, tax and return from standard invoices
  def self.import_sales
    invoices = find_by_sql("SELECT * FROM PRODDTA.F03B11 WHERE 
    rpdivj = '#{date_to_julian(Date.yesterday.to_date)}' 
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
          LaporanCabang.find_by_sql("SELECT id FROM tblaporancabang WHERE noso LIKE '#{order.sddoco}'
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
          customer_master = Customer.where(address_number: order.sdan8.to_i)
          unless customer_master.nil? || customer_master.blank?
            customer_master.first.update_attributes!(last_order_date: julian_to_date(order.sdaddj))
          end
          LaporanCabang.create(cabang_id: cabang, noso: order.sddoco.to_i, tanggal: julian_to_date(order.sdtrdj), nosj: order.sddeln.to_i, tanggalsj: julian_to_date(iv.rpdivj),
            kodebrg: order.sdlitm.strip,
            namabrg: fullnamabarang, kode_customer: order.sdan8.to_i, customer: namacustomer, jumlah: iv.rpu.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: item_master.imprgr.strip, kodejenis: item_master.imseg1.strip, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..7], namaartikel: artikel,
            kodekain: item_master.imseg3.strip, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
            hargasatuan: harga/10000, harganetto1: iv.rpag, harganetto2: iv.rpag, kota: kota, tipecust: group, bonus: bonus, lnid: order.sdlnid.to_i, ketppb: "",
            salesman: sales, diskon5: variance, orty: order.sddcto.strip, nopo: sales_id, fiscal_year: julian_to_date(iv.rpdivj).to_date.year,
            fiscal_month: julian_to_date(iv.rpdivj).to_date.month, week: julian_to_date(iv.rpdivj).to_date.cweek,
            area_id: area)
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
    sales = SalesTarget.find_by_sql("SELECT name, user_id, brand FROM sales_targets WHERE address_number IS NOT NULL GROUP BY user_id, brand")
    sales.each do |sl|
      unless sl.user_id.nil? || sl.user_id == 0
        sum_visit = SalesProductivity.where(salesmen_id: sl.user_id, brand: sl.brand, month: (1.month.ago - 2.days).month).sum("nvc")
        sum_close_deal_visit = SalesProductivity.where(salesmen_id: sl.user_id, brand: sl.brand, month: (1.month.ago - 2.days).month).sum("ncdv")
        sum_sold_product = LaporanCabang.select("SUM(jumlah) AS jumlah").where("fiscal_month = '#{(1.month.ago - 2.days).month}' AND fiscal_year = '#{(1.month.ago - 2.days).year}' 
        AND nopo = '#{User.find(sl.user_id).address_number}' AND jenisbrgdisc LIKE '#{sl.brand}' 
        AND kodejenis IN ('KM', 'KB') AND bonus = '-' AND orty = 'SO'")
        sum_call_close_deal = SalesProductivity.where(salesmen_id: sl.user_id, brand: sl.brand, month: (1.month.ago - 2.days).month).sum("ncdc")
        sum_call_customer = SalesProductivity.where(salesmen_id: sl.user_id, brand: sl.brand, month: (1.month.ago - 2.days).month).sum("ncc")
        sum_available = SalesProductivity.where(salesmen_id: sl.user_id, brand: sl.brand, month: (1.month.ago - 2.days).month)
        unless sum_available.empty?
          average_visit_day = (sum_visit.to_f/sum_available.count.to_f)%100.0
          success_rate_visit = (sum_close_deal_visit.to_f/sum_visit.to_f)%100.0
          order_visit = (sum_sold_product.first.jumlah.to_f/sum_call_close_deal.to_f)%100.0
          call_day = (sum_sold_product.first.jumlah.to_f/sum_available.count.to_f)%100.0
          
          SalesProductivityReport.create(salesmen_id: sl.user_id, branch_id: User.find(sl.user_id).branch1, 
          month: (1.month.ago - 2.days).month, year: (1.month.ago - 2.days).year,
          average_visit_day: average_visit_day, success_rate_visit: success_rate_visit,
          average_order_deal: order_visit, average_call_day: call_day, brand: sl.brand)
        end
      end
    end
  end

  #use this if sales of a branch not working
  def self.import_so_detail_with_range(from)
    where("sdnxtr >= ? and sdlttr >= ? and sddcto = ? and sdaddj = ?",
    "580", "565", "SO", date_to_julian(from.to_date)).each do |a|
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
    rpdivj BETWEEN '#{date_to_julian('01/07/2017'.to_date)}' AND '#{date_to_julian('31/07/2017'.to_date)}'
    AND REGEXP_LIKE(rpdct,'RI|RX|RM|RO') AND rpsdoc > 1 AND REGEXP_LIKE (rpmcu, '13151|13151D|13151C') ")
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
          LaporanCabang.find_by_sql("SELECT id FROM tblaporancabang WHERE noso LIKE '#{order.sddoco}'
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
          customer_master = Customer.where(address_number: order.sdan8.to_i)
          unless customer_master.nil? || customer_master.blank?
            customer_master.first.update_attributes!(last_order_date: julian_to_date(order.sdaddj))
          end
          LaporanCabang.create(cabang_id: cabang, noso: order.sddoco.to_i, tanggal: julian_to_date(order.sdtrdj), nosj: order.sddeln.to_i, tanggalsj: julian_to_date(iv.rpdivj),
            kodebrg: order.sdlitm.strip,
            namabrg: fullnamabarang, kode_customer: order.sdan8.to_i, customer: namacustomer, jumlah: iv.rpu.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: item_master.imprgr.strip, kodejenis: item_master.imseg1.strip, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..7], namaartikel: artikel,
            kodekain: item_master.imseg3.strip, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
            hargasatuan: harga/10000, harganetto1: iv.rpag, harganetto2: iv.rpag, kota: kota, tipecust: group, bonus: bonus, lnid: order.sdlnid.to_i, ketppb: "",
            salesman: sales, diskon5: variance, orty: order.sddcto.strip, nopo: sales_id, fiscal_year: julian_to_date(iv.rpdivj).to_date.year,
            fiscal_month: julian_to_date(iv.rpdivj).to_date.month, week: julian_to_date(order.sdaddj).to_date.cweek,
            area_id: area)
         end
        end
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
    if bu.include?("1100") || bu == "11001" || bu == "11001D" || bu == "11001C" #pusat
      "01"
    elsif bu.include?("1110") || bu == "11101" || bu == "11102" || bu == "13101" || bu == "11101C" || bu == "11101D" || bu == "13101C" || bu == "13101D" || bu == "11101S" || bu == "13101S" #lampung
      "13" 
    elsif bu == "11010" || bu.include?("1101") || bu == "11011C" || bu == "11011D" || bu == "11002" || bu == "13011D" || bu == "13011" || bu == "13011C" || bu == "11011S" || bu == "13011S" #jabar
      "02"
    elsif bu.include?("1102") || bu == "11021" || bu == "11022" || bu == "13021" || bu == "13021D" || bu == "13021C" || bu == "11021C" || bu == "11021D" || bu == "11021S" || bu == "13021S" #cirebon
      "09"
    elsif bu.include?("1200") || bu == "12001" || bu == "12002" || bu == "12001C" || bu == "12001D" #bestari mulia
      "50"
    elsif bu.include?("1206") || bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "13061"|| bu == "13001" || bu == "13061C" || bu == "13061D" || bu == "12061S" || bu == "13061S" #surabay
      "07"
    elsif bu.include?("1115") || bu == "11151" || bu == "11152" || bu == "13151" || bu == "13151C" || bu == "13151D" || bu == "11151C" || bu == "11151D" || bu == "11151S" || bu == "13151S" #cikupa
      "23"
    elsif bu.include?("1103") || bu == "11031" || bu == "11032" || bu == "11031C" || bu == "11031D" || bu == "13031C" || bu == "13031D" || bu == "13031" || bu == "11031S" || bu == "13031S" #narogong
      "03"
    elsif bu.include?("1311") || bu.include?("1211") || bu == "12111" || bu == "12112" || bu == "13111" || bu == "12111C" || bu == "12111D" || bu == "13111C" || bu == "13111D" || bu == "12111S" || bu == "13111S" #makasar
      "19"
    elsif bu.include?("1207") || bu == "12071" || bu == "12072" || bu == "13071" || bu == "12071C" || bu == "12071D" || bu == "13071C" || bu == "13071D" || bu == "12111S" || bu == "13071S" #bali
      "04"
    elsif bu.include?("1213") || bu == "12131" || bu == "12132" || bu == "13131" || bu == "12131C" || bu == "12131D" || bu == "13131C" || bu == "13131D" || bu == "12131S" || bu == "13131S" #jember
      "22" 
    elsif bu.include?("1109") || bu == "11091" || bu == "11092" || bu == "13091" || bu == "11091C" || bu == "11091D" || bu == "13091C" || bu == "13091D" || bu == "11091S" || bu == "13091S" #palembang
      "11"
    elsif bu.include?("1104") || bu == "11041" || bu == "11042" || bu == "13041" || bu == "11041C" || bu == "11041D" || bu == "13041C" || bu == "13041D" || bu == "11041S" || bu == "13041S"#yogyakarta
      "10"
    elsif bu.include?("1105") || bu == "11051" || bu == "11052" || bu == "13051" || bu == "11051C" || bu == "11051D" || bu == "13051C" || bu == "13051D" || bu == "11051S" || bu == "13051S" #semarang
      "08"
    elsif bu.include?("1108") || bu == "11081" || bu == "11082" || bu == "13081" || bu == "11081C" || bu == "11081D" || bu == "13081C" || bu == "13081D" || bu == "11081S" || bu == "13081S" #medan
      "05"
    elsif bu.include?("1112") || bu == "11121" || bu == "11122" || bu == "13121" || bu == "11121C" || bu == "11121D" || bu == "13121C" || bu == "13121D" || bu == "11121S" || bu == "13121S" #pekanbaru
      "20"
    end
  end
end
