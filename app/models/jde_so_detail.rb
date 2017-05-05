class JdeSoDetail < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4211" #sd

  def self.outstanding_so(item_number, first_week, branch_plan)
    select("sum(sduorg) as sduorg").where("sditm = ? and sdnxtr < ? and sdlttr < ? and sddcto like ? and sdtrdj = ? and sdmcu like ?",
      item_number, "999", "580", "SO", date_to_julian(first_week), "%#{branch_plan}%")
  end

  def self.delivered_so(item_number, first_week, last_week)
    select("sum(sdsoqs) as sdsoqs").where("sditm = ? and sdnxtr = ? and sdlttr = ? and sddcto like ? and sdaddj = ?",
      item_number, "999", "580", "SO", date_to_julian(first_week))
  end
  
  # import account receivable 
  def self.import_acc_receivable
    ar = find_by_sql("SELECT * FROM PRODDTA.F03B11 WHERE rpddj between
    '#{date_to_julian('4/04/2017'.to_date)}' AND
    '#{date_to_julian('30/04/2017'.to_date)}' AND REGEXP_LIKE(rpomod, '0|3') ")
    ar.each do |ars|
      cek_ava = AccountReceivable.where(doc_number: ars.rpdoc, doc_type: ars.rpdct, branch: ars.rpmcu.strip, pay_item: ars.rpsfx)
      if cek_ava.empty?
        group = JdeCustomerMaster.get_group_customer(ars.rpan8.to_i)
        if group == 'RETAIL'
          cabang = jde_cabang(ars.rpmcu.to_i.to_s.strip)
          dpd = Date.today - julian_to_date(ars.rpddj)
          sales = JdeSalesman.find_salesman(ars.rpan8.to_i, ars.rpar10.strip)
          sales_id = JdeSalesman.find_salesman_id(ars.rpan8.to_i, ars.rpar10.strip)
          item_master = ars.rpomod == '3' ? JdeItemMaster.where("imlitm LIKE '%#{ars.rprmk.strip}%'").first.imprgr.strip : '-'
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

  # #jde to mysql tblaporancabang
  def self.import_so_detail
    where("sdnxtr >= ? and sdlttr >= ? and sddcto IN ('SO','ZO') and sdaddj = ?",
    "580", "565", date_to_julian(Date.yesterday.to_date)).each do |a|
      find_sj = LaporanCabang.where(nosj: a.sddeln.to_i, lnid: a.sdlnid.to_i)
      if find_sj.empty?
        fullnamabarang = "#{a.sddsc1.strip} " "#{a.sddsc2.strip}"
        customer = JdeCustomerMaster.find_by_aban8(a.sdan8)
        bonus = a.sdaexp == 0 ?  'BONUS' : '-'
        if customer.abat1.strip == "C"
          namacustomer = customer.abalph.strip
          cabang = jde_cabang(a.sdmcu.to_i.to_s.strip)
          area = find_area(cabang)
          item_master = JdeItemMaster.find_by_imitm(a.sditm)
          jenis = JdeUdc.jenis_udc(item_master.imseg1.strip)
          artikel = JdeUdc.artikel_udc(item_master.imseg2.strip)
          kain = JdeUdc.kain_udc(item_master.imseg3.strip)
          groupitem = JdeUdc.group_item_udc(a.sdsrp3.strip)
          harga = JdeBasePrice.harga_satuan(a.sditm, a.sdmcu.strip, a.sdtrdj)
          kota = JdeAddressByDate.get_city(a.sdan8.to_i)
          group = JdeCustomerMaster.get_group_customer(a.sdan8.to_i)
          variance = (julian_to_date(a.sdaddj)-julian_to_date(a.sdppdj)).to_i
         sales = JdeSalesman.find_salesman(a.sdan8.to_i, a.sdsrp1.strip)
         sales_id = JdeSalesman.find_salesman_id(a.sdan8.to_i, a.sdsrp1.strip)
          LaporanCabang.create(cabang_id: cabang, noso: a.sddoco.to_i, tanggal: julian_to_date(a.sdtrdj), nosj: a.sddeln.to_i, tanggalsj: julian_to_date(a.sdaddj),kodebrg: a.sdaitm.strip,
            namabrg: fullnamabarang, kode_customer: a.sdan8.to_i, customer: namacustomer, jumlah: a.sdsoqs.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: item_master.imprgr.strip, kodejenis: item_master.imseg1.strip, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..5], namaartikel: artikel,
            kodekain: item_master.imseg3.strip, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
            hargasatuan: harga/10000, harganetto1: a.sdaexp, harganetto2: a.sdaexp, kota: kota, tipecust: group, bonus: bonus, lnid: a.sdlnid.to_i, ketppb: "",
            salesman: sales, diskon5: variance, orty: a.sddcto.strip, nopo: sales_id, fiscal_year: julian_to_date(a.sdaddj).to_date.year,
            fiscal_month: julian_to_date(a.sdaddj).to_date.month, week: julian_to_date(a.sdaddj).to_date.cweek,
            area_id: area)
        end
      end
    end
  end

  #import retur
  def self.import_retur
    where("sdnxtr >= ? and sdlttr >= ? and sddcto = 'CO' and sdtrdj = ?",
    "999", "580", date_to_julian(Date.yesterday.to_date)).each do |a|
      find_sj = LaporanCabang.where(noso: a.sddoco.to_i, orty: a.sddcto.strip)
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
          LaporanCabang.create(cabang_id: cabang, noso: a.sddoco.to_i, tanggal: julian_to_date(a.sdtrdj), nosj: a.sddeln.to_i, tanggalsj: julian_to_date(a.sdtrdj),kodebrg: a.sdaitm.strip,
            namabrg: fullnamabarang, kode_customer: a.sdan8.to_i, customer: namacustomer, jumlah: a.sdsoqs.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: item_master.imprgr.strip, kodejenis: item_master.imseg1.strip, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..5], namaartikel: artikel,
            kodekain: item_master.imseg3.strip, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
            hargasatuan: harga/10000, harganetto1: a.sdaexp, harganetto2: a.sdaexp, kota: kota, tipecust: group, bonus: bonus, lnid: a.sdlnid.to_i, ketppb: "",
            salesman: sales, orty: a.sddcto.strip, fiscal_month: julian_to_date(a.sdtrdj).to_date.month, fiscal_year: julian_to_date(a.sdtrdj).to_date.year,
            week: julian_to_date(a.sdtrdj).to_date.cweek)
        end
      end
    end
  end
  
  #import credit note
  def self.import_credit_note
    credit_note = self.find_by_sql("SELECT * FROM PRODDTA.F03B11 WHERE 
    rpdivj BETWEEN '#{date_to_julian('01/03/2017'.to_date)}' AND'#{date_to_julian(Date.yesterday.to_date)}' 
    AND rpdct LIKE '%RM%'")
    credit_note.each do |cr|
      # no_doc = cr.rprmk[0..7].to_i.to_s
      # no_so = self.find_by_sql("SELECT sdtrdj, sdan8, sdmcu, sddoco, sddeln, sdsrp1
      # FROM PRODDTA.F4211 WHERE sddoc LIKE '%#{no_doc}%'")
      # if no_doc.length == 8 && no_so.present?
        if LaporanCabang.where(orty: "RM", nofaktur: cr.rpdoc, lnid: cr.rpsfx).empty?
          # no_so = no_so.first
          namacustomer = JdeCustomerMaster.find_by_aban8(cr.rpan8).abalph.strip
          cabang = jde_cabang(cr.rpmcu.to_i.to_s.strip)
          area = find_area(cabang)
          group = JdeCustomerMaster.get_group_customer(cr.rpan8.to_i)
          kota = JdeAddressByDate.get_city(cr.rpan8.to_i)
          # sales = JdeSalesman.find_salesman(cr.rpan8.to_i, cr.sdsrp1.strip)
          # sales_id = JdeSalesman.find_salesman_id(no_so.sdan8.to_i, no_so.sdsrp1.strip)
          LaporanCabang.create(cabang_id: cabang, nofaktur: cr.rpdoc, 
            tanggal: julian_to_date(cr.rpdgj), tanggalsj: julian_to_date(cr.rpdivj), 
            kode_customer: cr.rpan8.to_i, customer: namacustomer, harganetto1: cr.rpag, 
            kota: kota, tipecust: group, orty: cr.rpdct.strip,
            fiscal_month: julian_to_date(cr.rpdivj).to_date.month, 
            fiscal_year: julian_to_date(cr.rpdivj).to_date.year,
            week: julian_to_date(cr.rpdivj).to_date.cweek, lnid: cr.rpsfx, area_id: area)
        end
      # end
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
  
  #import stock hourly
  def self.import_stock_hourly
    stock = self.find_by_sql("SELECT MAX(imsrp1) AS imsrp1, IA.liitm AS liitm, MAX(IM.imlitm) AS imlitm, 
    IA.limcu AS limcu, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom,
    MAX(IM.imlitm) AS imlitm, MAX(IM.imdsc1) AS imdsc1, MAX(IM.imdsc2) AS imdsc2 FROM PRODDTA.F41021 IA
    JOIN PRODDTA.F4101 IM ON IA.liitm = IM.imitm
    WHERE IA.lipqoh >= 0 AND IM.imtmpl LIKE '%BJ MATRASS%' AND REGEXP_LIKE(IM.imsrp2,'KM|HB|DV|SA|SB|ST|KB')
    GROUP BY IA.liitm, IA.limcu")
    stock.each do |st|
      status = /\A\d+\z/ === st.limcu.strip.last ? 'N' : st.limcu.strip.last
      description = st.imdsc1.strip+' '+st.imdsc2.strip
      cek_stock = Stock.where(item_number: st.imlitm.strip, branch: st.limcu.strip, status: status)
      if cek_stock.empty? || cek_stock.nil?
        Stock.create(branch: st.limcu.strip, brand: st.imsrp1.strip, description: description,
        item_number: st.imlitm.strip, onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000, 
        status: status, product: st.imlitm.strip[0..1])
      elsif ((st.lipqoh/10000) != cek_stock.first.onhand && st.limcu.strip == cek_stock.first.branch && 
       st.imsrp1.strip == cek_stock.first.brand && status == cek_stock.first.status) ||
        (((st.lipqoh - st.lihcom)/10000) != cek_stock.first.available  && st.limcu.strip == cek_stock.first.branch && st.imsrp1.strip == cek_stock.first.brand && status == cek_stock.first.status)
         cek_stock.first.update_attributes!(onhand: st.lipqoh/10000, 
         available: (st.lipqoh - st.lihcom)/10000, product: st.imlitm.strip[0..1])
      end
    end
  end
  
  def self.import_stock_hourly_display
    stock = find_by_sql("SELECT imsrp1, IA.liitm AS liitm, IM.imlitm, IA.limcu,
    IL.ildoc, IL.ildct, IA.lipqoh, IA.lihcom, IA.lilotn, IM.imlitm, IM.imdsc1, IM.imdsc2, 
    NVL(CM.abalph, IL.iltrex) AS abalph, IL.ilcrdj FROM 
    (
      SELECT TOD.liitm, TOD.limcu, SUM(AU.lipqoh) AS lipqoh, SUM(AU.lihcom) AS lihcom, TOD.lilotn FROM PRODDTA.F41021 TOD
      LEFT JOIN
      (
        SELECT liitm, limcu, SUM(lipqoh) AS lipqoh, SUM(lihcom) AS lihcom FROM PRODDTA.F41021 GROUP BY liitm, limcu
      ) AU ON TOD.liitm = AU.liitm AND TOD.limcu = AU.limcu
      WHERE TOD.liupmj = '#{date_to_julian(Date.today)}' AND TOD.limcu LIKE '%D' AND 
      REGEXP_LIKE(TOD.liglpt,'KM|HB|DV|SA|SB|ST|KB') 
      AND TOD.lipbin LIKE '%S' GROUP BY TOD.liitm, TOD.limcu, TOD.lilotn
    ) IA
    LEFT JOIN
    (
      SELECT MAX(ildoc) AS ildoc, max(ildct) as ildct, illotn, ilitm, MAX(iltrex) AS iltrex, MAX(ilcrdj) AS ilcrdj 
      FROM PRODDTA.F4111 WHERE REGEXP_LIKE(ildct,'ST|RO|IA')
      GROUP BY illotn, ilitm ORDER BY ildoc DESC
    ) IL ON IA.lilotn = IL.illotn
    LEFT JOIN
    (
      SELECT sdshan, sdlotn, sddoco FROM PRODDTA.F4211
      GROUP BY sdshan, sdlotn, sddoco
    ) ST ON IL.ildoc = ST.sddoco AND IL.illotn = ST.sdlotn
    LEFT JOIN
    (
      SELECT imitm, MAX(imsrp1) AS imsrp1, MAX(imlitm) AS imlitm, 
      MAX(imdsc1) AS imdsc1, MAX(imdsc2) AS imdsc2 FROM PRODDTA.F4101
      WHERE imtmpl LIKE '%BJ MATRASS%' AND REGEXP_LIKE(imsrp2,'KM|HB|DV|SA|SB|ST|KB') GROUP BY imitm
    ) IM ON IA.liitm = IM.imitm
    LEFT JOIN
    (
      SELECT abalph, aban8 FROM PRODDTA.F0101 
    ) CM ON ST.sdshan = CM.aban8")
    stock.each do |st|
        unless st.imdsc1.nil?
        status = /\A\d+\z/ === st.limcu.strip.last ? 'N' : st.limcu.strip.last
        description = st.imdsc1.nil? ? '-' : (st.imdsc1.strip+' '+st.imdsc2.strip)
        v_age = Date.today - julian_to_date(st.ilcrdj)
        cek_stock = DisplayStock.where(lot_serial: st.lilotn.strip)
        if cek_stock.empty? || cek_stock.nil?
          DisplayStock.create(branch: st.limcu.strip, brand: st.imsrp1.strip, description: description,
          item_number: st.imlitm.strip, onhand: st.lipqoh/10000, 
          available: (st.lipqoh - st.lihcom)/10000, status: status, customer: st.abalph,
          lot_serial: st.lilotn.strip, doc_number: st.ildoc, age: v_age, doc_type: st.ildct)
        elsif st.lilotn.strip == cek_stock.first.lot_serial && 
          (st.ildoc != cek_stock.first.doc_number || st.lipqoh/10000 != cek_stock.first.onhand || 
          st.lihcom/10000 != cek_stock.first.available)
           cek_stock.first.update_attributes!( doc_number: st.ildoc, customer: st.abalph.strip,
           onhand: st.lipqoh/10000, available: (st.lipqoh - st.lihcom)/10000)
        end
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
          LaporanCabang.create(cabang_id: cabang, noso: a.sddoco.to_i, nosj: a.sddeln.to_i, tanggalsj: julian_to_date(a.sdaddj),kodebrg: a.sdaitm.strip,
            namabrg: fullnamabarang, kode_customer: a.sdan8.to_i, customer: namacustomer, jumlah: a.sdsoqs.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: item_master.imprgr.strip, kodejenis: item_master.imseg1.strip, jenisbrg: jenis, kodeartikel: item_master.imaitm[2..5], namaartikel: artikel,
            kodekain: item_master.imseg3.strip, namakain: kain, panjang: item_master.imseg5.to_i, lebar: item_master.imseg6.to_i, namabrand: groupitem,
            hargasatuan: harga/10000, harganetto1: a.sdaexp, harganetto2: a.sdaexp, kota: kota, tipecust: group, bonus: bonus, lnid: a.sdlnid.to_i, ketppb: "",
            salesman: sales)
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
