class JdeInvoice < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F03B11" #rp
  
  def self.test_import_sales
    invoices = find_by_sql("SELECT SA.RPLNID AS LINEFAKTUR, SA.RPDOC AS NOFAKTUR, SA.RPDCT AS ORTY, SA.RPSDOC AS NOSO, SA.RPSDCT AS DOC, SA.RPSFX AS LINESO, 
       SA.RPDIVJ AS TANGGALINVOICE, SA.RPU/100 AS JUMLAH, SA.RPAG AS TOTAL, 
       SA.RPMCU AS BP, SA.RPAN8 AS KODECUSTOMER, SA.RPALPH AS CUSTOMER, CM.ABSIC AS TIPECUST, NVL(TRIM(CIT.ALCTY1), '-') AS KOTA, SM.SASLSM AS KODESALES, 
       CM1.ABALPH AS NAMASALES,
       IM.IMITM AS SHORTITEM, SA.RPRMK AS KODEBARANG, IM.IMDSC1 AS DSC1, IM.IMDSC2 AS DSC2, IM.IMPRGR AS BRAND, IM.IMSEG1 AS TIPE, 
       JN.DRDL01 AS NAMATIPE, IM.IMSRP3, NVL(GI.DRDL01,'-') AS GROUPITEM, IM.IMSEG2 AS KODEARTIKEL, 
       ART.DRDL01 AS ARTICLE, IM.IMSEG3 AS KODEKAIN, KA.DRDL01 AS KAIN, 
       IM.IMSEG4 AS ST, IM.IMSEG5 AS PANJANG, IM.IMSEG6 AS LEBAR, (CASE WHEN SA.RPDCT = 'RM' THEN SUBSTR(SA.RPRMR1, 1, 8) ELSE SA.RPRMR1 END) AS REFEREN1, SA.RPVR01 AS REFEREN FROM
       (
         SELECT * FROM PRODDTA.F03B11 WHERE RPDIVJ BETWEEN '119007' AND '119007' AND REGEXP_LIKE(rpdct,'RI|RO|RX|RM')
       ) SA
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F4101 WHERE IMTMPL LIKE '%BJ MATRASS%'
       ) IM ON TRIM(IM.IMLITM) = TRIM(SA.RPRMK)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'JN'
       ) JN ON JN.DRKY LIKE '%'||TRIM(IM.IMSEG1)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'AT'
       ) ART ON ART.DRKY LIKE '%'||TRIM(IM.IMSEG2)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'KA'
       ) KA ON KA.DRKY LIKE '%'||TRIM(IM.IMSEG3)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '41' AND DRRT = 'S3'
       ) GI ON GI.DRKY LIKE '%'||IM.IMSRP3
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM ON TRIM(SA.RPAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT ALAN8, MAX(ALCTY1) AS ALCTY1 FROM PRODDTA.F0116 GROUP BY ALAN8
       ) CIT ON TRIM(CIT.ALAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT SASLSM, SAIT44, SAAN8 FROM PRODDTA.F40344 WHERE SAEXDJ > (select 1000*(to_char(sysdate, 'yyyy')-1900)+to_char(sysdate, 'ddd') as julian from dual)
       ) SM ON SM.SAAN8 = SA.RPAN8 AND SM.SAIT44 = IM.IMSRP1
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM1 ON TRIM(SM.SASLSM) = TRIM(CM1.ABAN8)
       
       WHERE IM.IMPRGR IS NOT NULL ORDER BY NOFAKTUR")
    invoices.each do |iv|
          cabang = jde_cabang(iv.bp.to_i.to_s.strip)
          area = find_area(cabang)
          fullnamabarang = "#{iv.dsc1.strip} " "#{iv.dsc2.strip}"
          alamat_so = iv.orty == 'RI' ? (get_address_from_order(iv.noso, iv.doc).nil? ? '-' : get_address_from_order(iv.noso, iv.doc).address) : '-'
          adj = import_adjustment(iv.linefaktur.to_i, iv.noso.to_i, iv.doc) #find price_adjustment
          LaporanCabang.create!(cabang_id: cabang, noso: iv.nofaktur.to_i, tanggalsj: julian_to_date(iv.tanggalinvoice),
            kodebrg: iv.kodebarang.strip, namabrg: fullnamabarang, kode_customer: iv.kodecustomer.to_i, customer: iv.customer, 
            jumlah: iv.jumlah.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: iv.brand.strip, kodejenis: iv.tipe.strip, jenisbrg: iv.namatipe.strip, kodeartikel: iv.kodeartikel, namaartikel: iv.article,
            kodekain: iv.kodekain.strip, namakain: iv.kain.nil? ? '-' : iv.kain.strip, panjang: iv.panjang.to_i, lebar: iv.lebar.to_i, namabrand: iv.groupitem.strip,
            harganetto1: iv.total, harganetto2: iv.total, kota: iv.kota, tipecust: get_group_customer(iv.tipecust), 
            ketppb: "", tanggal_fetched: Date.today.to_date,
            salesman: iv.namasales, orty: iv.orty.strip, nopo: iv.kodesales, 
            fiscal_year: julian_to_date(iv.tanggalinvoice).to_date.year,
            fiscal_month: julian_to_date(iv.tanggalinvoice).to_date.month, week: julian_to_date(iv.tanggalinvoice).to_date.cweek,
              area_id: area, ketppb: iv.bp.strip, tanggal: julian_to_date(iv.tanggalinvoice),
              nofaktur: iv.nofaktur.to_i, lnid: iv.lineso, nosj: iv.linefaktur.to_i, alamatkirim: iv.doc,
              alamat_so: alamat_so, reference: iv.referen1, customerpo_so: iv.referen,
              diskon1: adj.nil? ? 0 : adj.diskon1,
              diskon2: adj.nil? ? 0 : adj.diskon2,
              diskon3: adj.nil? ? 0 : adj.diskon3,
              diskon4: adj.nil? ? 0 : adj.diskon4,
              diskon5: adj.nil? ? 0 : adj.diskon5,
              diskonsum: adj.nil? ? 0 : adj.diskon6,
              diskonrp: adj.nil? ? 0 : adj.diskon7,
              cashback: adj.nil? ? 0 : adj.diskon8,
              nupgrade: adj.nil? ? 0 : adj.diskon9)
          Warehouse::Invoice.create!(cabang_id: cabang, noso: iv.nofaktur.to_i, tanggalsj: julian_to_date(iv.tanggalinvoice),
            kodebrg: iv.kodebarang.strip, namabrg: fullnamabarang, kode_customer: iv.kodecustomer.to_i, customer: iv.customer, 
            jumlah: iv.jumlah.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: iv.brand.strip, kodejenis: iv.tipe.strip, jenisbrg: iv.namatipe.strip, kodeartikel: iv.kodeartikel, namaartikel: iv.article,
            kodekain: iv.kodekain.strip, namakain: iv.kain.nil? ? '-' : iv.kain.strip, panjang: iv.panjang.to_i, lebar: iv.lebar.to_i, namabrand: iv.groupitem.strip,
            harganetto1: iv.total, harganetto2: iv.total, kota: iv.kota, tipecust: get_group_customer(iv.tipecust), 
            ketppb: "",
            salesman: iv.namasales, orty: iv.orty.strip, nopo: iv.kodesales, 
            fiscal_year: julian_to_date(iv.tanggalinvoice).to_date.year,
            fiscal_month: julian_to_date(iv.tanggalinvoice).to_date.month, week: julian_to_date(iv.tanggalinvoice).to_date.cweek,
              area_id: area, ketppb: iv.bp.strip, tanggal: julian_to_date(iv.tanggalinvoice),
              nofaktur: iv.nofaktur.to_i, lnid: iv.lineso, nosj: iv.linefaktur.to_i, alamatkirim: iv.doc,
              alamat_so: alamat_so, reference: iv.referen1, customerpo_so: iv.referen,
              diskon1: adj.nil? ? 0 : adj.diskon1,
              diskon2: adj.nil? ? 0 : adj.diskon2,
              diskon3: adj.nil? ? 0 : adj.diskon3,
              diskon4: adj.nil? ? 0 : adj.diskon4,
              diskon5: adj.nil? ? 0 : adj.diskon5,
              diskonsum: adj.nil? ? 0 : adj.diskon6,
              diskonrp: adj.nil? ? 0 : adj.diskon7,
              cashback: adj.nil? ? 0 : adj.diskon8,
              nupgrade: adj.nil? ? 0 : adj.diskon9)
    end
  end
  
  # import account receivable 
  def self.import_acc_receivable
    AccountReceivable.destroy_all
    ar = find_by_sql("SELECT RP.RPMCU AS BRANCH, RP.RPAN8 AS KODECUS, MAX(CS.ABALPH) AS CUSTOMER, MAX(SM.SASLSM) AS KODESALES, 
      MAX(CS.ABSIC) AS GR, NVL(MAX(CM1.ABALPH), '-') AS SALESMAN, MAX(IM.IMLITM) AS ITEM_NUMBER, IM.IMPRGR, RP.RPDDJ, SUM(RP.RPAAP) AS OPEN_AMOUNT FROM
       (
         SELECT * FROM PRODDTA.F03B11 WHERE rpddj >= '#{date_to_julian(3.months.ago.beginning_of_month.to_date)}' AND rpaap > 0 AND RPSDCT = 'SO'
         AND REGEXP_LIKE(rpdct,'RI|RX|RO|RM')
         AND rpsdoc > 1
       ) RP
       LEFT JOIN
       (
         SELECT * FROM PRODDTA.F4101
       ) IM ON IMLITM = RP.RPRMK
       LEFT JOIN
       (
         SELECT * FROM PRODDTA.F0101 WHERE ABSIC = 'RET'
       ) CS ON CS.ABAN8 = RP.RPAN8
       LEFT JOIN
       (
         SELECT SASLSM, SAIT44, SAAN8 FROM PRODDTA.F40344 WHERE SAEXDJ > (select 1000*(to_char(sysdate, 'yyyy')-1900)+to_char(sysdate, 'ddd') as julian from dual)
       ) SM ON SM.SAAN8 = RP.RPAN8 AND SM.SAIT44 = IM.IMSRP1
       LEFT JOIN
       (
         SELECT * FROM PRODDTA.F0101
       ) CM1 ON TRIM(SM.SASLSM) = TRIM(CM1.ABAN8)
       WHERE CS.ABSIC = 'RET' GROUP BY RP.RPAN8, RP.RPMCU, RP.RPDDJ, IM.IMPRGR")
    ar.each do |ars|
      if ars.present?
        cabang = jde_cabang(ars.branch.to_i.to_s.strip)
        dpd = Date.today - julian_to_date(ars.rpddj)
        AccountReceivable.create(open_amount: ars.open_amount,
          due_date: julian_to_date(ars.rpddj), days_past_due: dpd, branch: cabang,
          fiscal_month: julian_to_date(ars.rpddj).month, fiscal_year: julian_to_date(ars.rpddj).year,
          remark: ars.item_number.nil? ? '-' : ars.item_number.strip, customer_number: ars.kodecus,
          customer: ars.customer.strip, customer_group: ars.gr, updated_at: Time.now, salesman: ars.salesman, 
          salesman_no: ars.kodesales, brand: ars.imprgr.strip)
      end
    end
  end

  def self.import_sales
    invoices = find_by_sql("SELECT SA.RPLNID AS LINEFAKTUR, SA.RPDOC AS NOFAKTUR, SA.RPDCT AS ORTY, SA.RPSDOC AS NOSO, SA.RPSDCT AS DOC, SA.RPSFX AS LINESO, 
       SA.RPDIVJ AS TANGGALINVOICE, SA.RPU/100 AS JUMLAH, SA.RPAG AS TOTAL, 
       SA.RPMCU AS BP, SA.RPAN8 AS KODECUSTOMER, SA.RPALPH AS CUSTOMER, CM.ABSIC AS TIPECUST, NVL(TRIM(CIT.ALCTY1), '-') AS KOTA, SM.SASLSM AS KODESALES, 
       CM1.ABALPH AS NAMASALES,
       IM.IMITM AS SHORTITEM, SA.RPRMK AS KODEBARANG, IM.IMDSC1 AS DSC1, IM.IMDSC2 AS DSC2, IM.IMPRGR AS BRAND, IM.IMSEG1 AS TIPE, 
       JN.DRDL01 AS NAMATIPE, IM.IMSRP3, NVL(GI.DRDL01,'-') AS GROUPITEM, IM.IMSEG2 AS KODEARTIKEL, 
       ART.DRDL01 AS ARTICLE, IM.IMSEG3 AS KODEKAIN, KA.DRDL01 AS KAIN, 
       IM.IMSEG4 AS ST, IM.IMSEG5 AS PANJANG, IM.IMSEG6 AS LEBAR, (CASE WHEN SA.RPDCT = 'RM' THEN SUBSTR(SA.RPRMR1, 1, 8) ELSE SA.RPRMR1 END) AS REFEREN1, SA.RPVR01 AS REFEREN FROM
       (
         SELECT * FROM PRODDTA.F03B11 WHERE RPUPMJ BETWEEN '#{date_to_julian(Date.yesterday.to_date)}' AND '#{date_to_julian(Date.today.to_date)}' AND REGEXP_LIKE(rpdct,'RI|RO|RX')
       ) SA
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F4101 WHERE IMTMPL LIKE '%BJ MATRASS%'
       ) IM ON TRIM(IM.IMLITM) = TRIM(SA.RPRMK)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'JN'
       ) JN ON JN.DRKY LIKE '%'||TRIM(IM.IMSEG1)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'AT'
       ) ART ON ART.DRKY LIKE '%'||TRIM(IM.IMSEG2)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'KA'
       ) KA ON KA.DRKY LIKE '%'||TRIM(IM.IMSEG3)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '41' AND DRRT = 'S3'
       ) GI ON GI.DRKY LIKE '%'||IM.IMSRP3
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM ON TRIM(SA.RPAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT ALAN8, MAX(ALCTY1) AS ALCTY1 FROM PRODDTA.F0116 GROUP BY ALAN8
       ) CIT ON TRIM(CIT.ALAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT SASLSM, SAIT44, SAAN8 FROM PRODDTA.F40344 WHERE SAEXDJ > (select 1000*(to_char(sysdate, 'yyyy')-1900)+to_char(sysdate, 'ddd') as julian from dual)
       ) SM ON SM.SAAN8 = SA.RPAN8 AND SM.SAIT44 = IM.IMSRP1
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM1 ON TRIM(SM.SASLSM) = TRIM(CM1.ABAN8)
       
       WHERE IM.IMPRGR IS NOT NULL ORDER BY NOFAKTUR")
    invoices.each do |iv|
      year = julian_to_date(iv.tanggalinvoice).to_date.year
      month = julian_to_date(iv.tanggalinvoice).to_date.month
        check = SalesReport.find_by_sql("SELECT nofaktur, orty, lnid, harganetto2 FROM dbmarketing.tblaporancabang 
        WHERE nofaktur = '#{iv.nofaktur.to_i}' 
        AND orty = '#{iv.orty.strip}' AND kode_customer = '#{iv.kodecustomer.to_i}'  
        AND lnid = '#{iv.lineso.to_i}' AND tanggalsj = '#{julian_to_date(iv.tanggalinvoice)}'")
        if check.empty?
          cabang = jde_cabang(iv.bp.to_i.to_s.strip)
          area = find_area(cabang)
          fullnamabarang = "#{iv.dsc1.strip} " "#{iv.dsc2.strip}"
          alamat_so = iv.orty == 'RI' ? (get_address_from_order(iv.noso, iv.doc).nil? ? '-' : get_address_from_order(iv.noso, iv.doc).address) : '-'
          adj = import_adjustment(iv.linefaktur.to_i, iv.noso.to_i, iv.doc) #find price_adjustment
          LaporanCabang.create!(cabang_id: cabang, noso: iv.nofaktur.to_i, tanggalsj: julian_to_date(iv.tanggalinvoice),
            kodebrg: iv.kodebarang.strip, namabrg: fullnamabarang, kode_customer: iv.kodecustomer.to_i, customer: iv.customer, 
            jumlah: iv.jumlah.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: iv.brand.strip, kodejenis: iv.tipe.strip, jenisbrg: iv.namatipe.strip, kodeartikel: iv.kodeartikel, namaartikel: iv.article,
            kodekain: iv.kodekain.strip, namakain: iv.kain.nil? ? '-' : iv.kain.strip, panjang: iv.panjang.to_i, lebar: iv.lebar.to_i, namabrand: iv.groupitem.strip,
            harganetto1: iv.total, harganetto2: iv.total, kota: iv.kota, tipecust: get_group_customer(iv.tipecust), 
            ketppb: "", tanggal_fetched: Date.today.to_date,
            salesman: iv.namasales, orty: iv.orty.strip, nopo: iv.kodesales, 
            fiscal_year: year,
            fiscal_month: month, week: julian_to_date(iv.tanggalinvoice).to_date.cweek,
              area_id: area, ketppb: iv.bp.strip, tanggal: julian_to_date(iv.tanggalinvoice),
              nofaktur: iv.nofaktur.to_i, lnid: iv.lineso, nosj: iv.linefaktur.to_i, alamatkirim: iv.doc,
              alamat_so: alamat_so, reference: iv.referen1, customerpo_so: iv.referen,
              diskon1: adj.nil? ? 0 : adj.diskon1,
              diskon2: adj.nil? ? 0 : adj.diskon2,
              diskon3: adj.nil? ? 0 : adj.diskon3,
              diskon4: adj.nil? ? 0 : adj.diskon4,
              diskon5: adj.nil? ? 0 : adj.diskon5,
              diskonsum: adj.nil? ? 0 : adj.diskon6,
              diskonrp: adj.nil? ? 0 : adj.diskon7,
              cashback: adj.nil? ? 0 : adj.diskon8,
              nupgrade: adj.nil? ? 0 : adj.diskon9)
          Warehouse::Invoice.create!(cabang_id: cabang, noso: iv.nofaktur.to_i, tanggalsj: julian_to_date(iv.tanggalinvoice),
            kodebrg: iv.kodebarang.strip, namabrg: fullnamabarang, kode_customer: iv.kodecustomer.to_i, customer: iv.customer, 
            jumlah: iv.jumlah.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: iv.brand.strip, kodejenis: iv.tipe.strip, jenisbrg: iv.namatipe.strip, kodeartikel: iv.kodeartikel, namaartikel: iv.article,
            kodekain: iv.kodekain.strip, namakain: iv.kain.nil? ? '-' : iv.kain.strip, panjang: iv.panjang.to_i, lebar: iv.lebar.to_i, namabrand: iv.groupitem.strip,
            harganetto1: iv.total, harganetto2: iv.total, kota: iv.kota, tipecust: get_group_customer(iv.tipecust), 
            ketppb: "", tanggal_fetched: Date.today.to_date,
            salesman: iv.namasales, orty: iv.orty.strip, nopo: iv.kodesales, 
            fiscal_year: year,
            fiscal_month: month, week: julian_to_date(iv.tanggalinvoice).to_date.cweek,
              area_id: area, ketppb: iv.bp.strip, tanggal: julian_to_date(iv.tanggalinvoice),
              nofaktur: iv.nofaktur.to_i, lnid: iv.lineso, nosj: iv.linefaktur.to_i, alamatkirim: iv.doc,
              alamat_so: alamat_so, reference: iv.referen1, customerpo_so: iv.referen,
              diskon1: adj.nil? ? 0 : adj.diskon1,
              diskon2: adj.nil? ? 0 : adj.diskon2,
              diskon3: adj.nil? ? 0 : adj.diskon3,
              diskon4: adj.nil? ? 0 : adj.diskon4,
              diskon5: adj.nil? ? 0 : adj.diskon5,
              diskonsum: adj.nil? ? 0 : adj.diskon6,
              diskonrp: adj.nil? ? 0 : adj.diskon7,
              cashback: adj.nil? ? 0 : adj.diskon8,
              nupgrade: adj.nil? ? 0 : adj.diskon9)
      end
    end
    #Customer.batch_customer_active
    #Customer.batch_calculate_customer_active
    import_credit_note
    revise_credit_note
    date = Date.today.day > 5 ? Date.today : 1.month.ago.to_date 
    batch_transform(date.month, date.year)
  end
  
  def self.get_group_customer(grup)
    if grup.strip == 'DEA' || grup.strip == 'RET'
      'RETAIL'
    elsif grup.strip == 'SHO'
      'SHOWROOM'
    elsif grup.strip == 'MOD'
      'MODERN'
    elsif grup.strip == 'DIR'
      'DIRECT'
    elsif grup.strip == 'PRO'
      'PROJECT'
    elsif grup.strip == 'OLN'
      'ONLINE'
    elsif grup.strip == 'COM'
      'COMPANY'
    else
      '-'
    end
  end

  def self.get_address_from_order(order, orty)
    order = find_by_sql("SELECT TRIM(oamlnm)||' '||TRIM(oaadd1)||' '||TRIM(oaadd2)||' ' ||TRIM(oaadd3) address 
    FROM PRODDTA.F4006 WHERE oadoco = '#{order}' AND oadcto = '#{orty}'").first
  end
  
  def self.get_info_from_order(line, order, orty)
    invoices = find_by_sql("SELECT * FROM PRODDTA.F4211 WHERE
    sddoco = '#{order}' AND sdlnid = '#{line}' AND sddcto = '#{orty}'").first
  end

  def self.import_adjustment(lnid, order, orty)
      adjustment = find_by_sql("SELECT ALDOCO,
          ALDCTO,
          ALLNID,
          SUM(DECODE(RowNum, 1, ALFVTR/10000)) DISKON1,
          SUM(DECODE(RowNum, 2, ALFVTR/10000)) DISKON2,
          SUM(DECODE(RowNum, 3, ALFVTR/10000)) DISKON3,
          SUM(DECODE(RowNum, 4, ALFVTR/10000)) DISKON4,
          SUM(DECODE(RowNum, 5, ALFVTR/10000)) DISKON5,
          SUM(DECODE(RowNum, 6, ALFVTR/10000)) DISKON6,
          SUM(DECODE(RowNum, 7, ALFVTR/10000)) DISKON7,
          SUM(DECODE(RowNum, 8, ALFVTR/10000)) DISKON8,
          SUM(DECODE(RowNum, 9, ALFVTR/10000)) DISKON9,
          SUM(DECODE(RowNum, 10, ALFVTR/10000)) DISKON10
        FROM PRODDTA.F4074
        WHERE PRODDTA.F4074.ALDOCO = '#{order}'
        AND PRODDTA.F4074.ALDCTO = '#{orty}'
        AND PRODDTA.F4074.ALPROV  != '1'
        AND PRODDTA.F4074.ALLNID = '#{lnid}'
        GROUP BY PRODDTA.F4074.ALDOCO,
          PRODDTA.F4074.ALDCTO,
          PRODDTA.F4074.ALLNID").first
  end
  
  def self.batch_transform(month, year)
    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.RET1BRAND (fiscal_day, fiscal_month, fiscal_year, branch, brand, sales_quantity, sales_amount, updated_at)
      SELECT DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, SUM(jumlah), SUM(harganetto2), NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' 
            GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc;")
    ActiveRecord::Base.connection.execute("
      REPLACE INTO sales_mart.RET1PRODUCT (branch, brand, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis;")
    ActiveRecord::Base.connection.execute("
    REPLACE INTO sales_mart.RET1ARTICLE (branch, brand, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET2CUSBRAND (branch, brand, customer, customer_desc, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, kode_customer, customer, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET2CUSPRODUCT (branch, brand, customer, customer_desc, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET2CUSARTICLE (branch, brand, customer, customer_desc, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, kode_customer, customer, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, kode_customer, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET3SALBRAND (branch, brand, salesmen, salesmen_desc, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, nopo, salesman, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET3SALPRODUCT (branch, brand, salesmen, salesmen_desc, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, nopo, salesman, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM warehouse.F03B11_INVOICES WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo, kodejenis;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET3SALARTICLE (branch, brand, salesmen, salesmen_desc, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, nopo, salesman, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo, kodejenis, kodeartikel, lebar;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET4CITYBRAND (branch, brand, city, sales_quantity, sales_amount, fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, kota, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' AND nopo IS NOT NULL
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET4CITYPRODUCT (branch, brand, city, product, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, kota, kodejenis, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL'
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo, kodejenis;")

    ActiveRecord::Base.connection.execute("REPLACE INTO sales_mart.RET4CITYARTICLE (branch, brand, city, product, article, article_desc, size, sales_quantity, sales_amount,
        fiscal_day, fiscal_month, fiscal_year, updated_at)
      SELECT area_id, jenisbrgdisc, kota, kodejenis, kodeartikel, namaartikel, lebar, SUM(jumlah), SUM(harganetto2), DAY(tanggalsj), fiscal_month, fiscal_year, NOW()
            FROM dbmarketing.tblaporancabang WHERE jenisbrgdisc != ' ' AND area_id IS NOT NULL AND tipecust = 'RETAIL' 
            AND fiscal_month = '#{month}' AND fiscal_year = '#{year}' GROUP BY DAY(tanggalsj), fiscal_month, fiscal_year, area_id, jenisbrgdisc, nopo, kodejenis, kodeartikel, lebar;")
  end

  def self.batch_price_adjustment
    date = Date.yesterday
    jde = find_by_sql("
      SELECT ALDOCO, ALDCTO, ALLNID,
      MAX(DECODE(ROWNUM, 1, ALFVTR)) DISKON1,
      MAX(DECODE(ROWNUM, 2, ALFVTR)) DISKON2,
      MAX(DECODE(ROWNUM, 3, ALFVTR)) DISKON3,
      MAX(DECODE(ROWNUM, 4, ALFVTR)) DISKON4,
      MAX(DECODE(ROWNUM, 5, ALFVTR)) DISKON5,
      MAX(DECODE(ROWNUM, 6, ALFVTR)) DISKON6,
      MAX(DECODE(ROWNUM, 7, ALFVTR)) DISKON7,
      MAX(DECODE(ROWNUM, 8, ALFVTR)) DISKON8,
      MAX(DECODE(ROWNUM, 9, ALFVTR)) DISKON9,
      MAX(DECODE(ROWNUM, 10, ALFVTR)) DISKON10
      FROM PRODDTA.F4074 WHERE ALDCTO IN ('SO', 'ZO', 'CO') 
      AND ALPROV != '1' AND ALUPMJ BETWEEN '#{date_to_julian('01/10/2018'.to_date)}' AND '#{date_to_julian(Date.today)}' 
      GROUP BY ALDOCO, ALDCTO, ALLNID")
    jde.each do |j|
      ActiveRecord::Base.connection.execute("INSERT INTO warehouse.F4074_PRICE (order_number, orty, 
      lnid, diskon1, diskon2, diskon3, diskon4, diskon5, diskon6, diskon7, diskon8, diskon9, diskon10, created_at)
      VALUES ('#{j.aldoco}', '#{j.aldcto}', '#{j.allnid}', '#{j.diskon1}', '#{j.diskon2}', '#{j.diskon3}', '#{j.diskon4}', 
      '#{j.diskon5}', '#{j.diskon6}', '#{j.diskon7}', '#{j.diskon8}', '#{j.diskon9}', '#{j.diskon10}', '#{Time.now}')")
    end
  end

  private
  def self.import_credit_note
    invoices = find_by_sql("SELECT SA.RPLNID AS LINEFAKTUR, SA.RPDOC AS NOFAKTUR, SA.RPDCT AS ORTY, SA.RPSDOC AS NOSO, SA.RPSDCT AS DOC, SA.RPSFX AS LINESO, 
       SA.RPDIVJ AS TANGGALINVOICE, SA.RPU/100 AS JUMLAH, SA.RPAG AS TOTAL, 
       SA.RPMCU AS BP, SA.RPAN8 AS KODECUSTOMER, SA.RPALPH AS CUSTOMER, CM.ABSIC AS TIPECUST, NVL(TRIM(CIT.ALCTY1), '-') AS KOTA, SM.SASLSM AS KODESALES, 
       CM1.ABALPH AS NAMASALES,
       IM.IMITM AS SHORTITEM, SA.RPRMK AS KODEBARANG, IM.IMDSC1 AS DSC1, IM.IMDSC2 AS DSC2, IM.IMPRGR AS BRAND, IM.IMSEG1 AS TIPE, 
       JN.DRDL01 AS NAMATIPE, IM.IMSRP3, NVL(GI.DRDL01,'-') AS GROUPITEM, IM.IMSEG2 AS KODEARTIKEL, 
       ART.DRDL01 AS ARTICLE, IM.IMSEG3 AS KODEKAIN, KA.DRDL01 AS KAIN, 
       IM.IMSEG4 AS ST, IM.IMSEG5 AS PANJANG, IM.IMSEG6 AS LEBAR, (CASE WHEN SA.RPDCT = 'RM' THEN SUBSTR(SA.RPRMR1, 1, 8) ELSE SA.RPRMR1 END) AS REFEREN1, SA.RPVR01 AS REFEREN FROM
       (
         SELECT * FROM PRODDTA.F03B11 WHERE RPUPMJ BETWEEN '#{date_to_julian(1.week.ago.to_date)}' AND '#{date_to_julian(Date.today.to_date)}' AND REGEXP_LIKE(rpdct,'RM')
       ) SA
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F4101 WHERE IMTMPL LIKE '%BJ MATRASS%'
       ) IM ON TRIM(IM.IMLITM) = TRIM(SA.RPRMK)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'JN'
       ) JN ON JN.DRKY LIKE '%'||TRIM(IM.IMSEG1)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'AT'
       ) ART ON ART.DRKY LIKE '%'||TRIM(IM.IMSEG2)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'KA'
       ) KA ON KA.DRKY LIKE '%'||TRIM(IM.IMSEG3)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '41' AND DRRT = 'S3'
       ) GI ON GI.DRKY LIKE '%'||IM.IMSRP3
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM ON TRIM(SA.RPAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT ALAN8, MAX(ALCTY1) AS ALCTY1 FROM PRODDTA.F0116 GROUP BY ALAN8
       ) CIT ON TRIM(CIT.ALAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT SASLSM, SAIT44, SAAN8 FROM PRODDTA.F40344 WHERE SAEXDJ > (select 1000*(to_char(sysdate, 'yyyy')-1900)+to_char(sysdate, 'ddd') as julian from dual)
       ) SM ON SM.SAAN8 = SA.RPAN8 AND SM.SAIT44 = IM.IMSRP1
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM1 ON TRIM(SM.SASLSM) = TRIM(CM1.ABAN8)
       
       WHERE IM.IMPRGR IS NOT NULL ORDER BY NOFAKTUR")
    invoices.each do |iv|
      year = julian_to_date(iv.tanggalinvoice).to_date.year
      month = julian_to_date(iv.tanggalinvoice).to_date.month
        check = SalesReport.find_by_sql("SELECT nofaktur, orty, lnid, harganetto2 FROM dbmarketing.tblaporancabang 
        WHERE nofaktur = '#{iv.nofaktur.to_i}' 
        AND orty = '#{iv.orty.strip}' AND kode_customer = '#{iv.kodecustomer.to_i}'  
        AND lnid = '#{iv.lineso.to_i}' AND tanggalsj = '#{julian_to_date(iv.tanggalinvoice)}'")
        if check.present? && (check.first.harganetto2 != iv.total)
          ActiveRecord::Base.connection.execute("UPDATE dbmarketing.tblaporancabang SET harganetto2 = '#{iv.total}' WHERE
            nofaktur = '#{iv.nofaktur.to_i}' 
            AND orty = '#{iv.orty.strip}' AND kode_customer = '#{iv.kodecustomer.to_i}'  
            AND lnid = '#{iv.lineso.to_i}' AND fiscal_month = '#{month}' AND nofaktur = '#{iv.nofaktur.to_i}'")
            
          ActiveRecord::Base.connection.execute("UPDATE warehouse.F03B11_INVOICES SET harganetto2 = '#{iv.total}' WHERE
            nofaktur = '#{iv.nofaktur.to_i}' 
            AND orty = '#{iv.orty.strip}' AND kode_customer = '#{iv.kodecustomer.to_i}'  
            AND lnid = '#{iv.lineso.to_i}' AND fiscal_month = '#{month}' AND nofaktur = '#{iv.nofaktur.to_i}'")
        elsif check.empty?
          cabang = jde_cabang(iv.bp.to_i.to_s.strip)
          area = find_area(cabang)
          fullnamabarang = "#{iv.dsc1.strip} " "#{iv.dsc2.strip}"
          alamat_so = iv.orty == 'RI' ? (get_address_from_order(iv.noso, iv.doc).nil? ? '-' : get_address_from_order(iv.noso, iv.doc).address) : '-'
          adj = import_adjustment(iv.linefaktur.to_i, iv.noso.to_i, iv.doc) #find price_adjustment
          LaporanCabang.create!(cabang_id: cabang, noso: iv.nofaktur.to_i, tanggalsj: julian_to_date(iv.tanggalinvoice),
            kodebrg: iv.kodebarang.strip, namabrg: fullnamabarang, kode_customer: iv.kodecustomer.to_i, customer: iv.customer, 
            jumlah: iv.jumlah.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: iv.brand.strip, kodejenis: iv.tipe.strip, jenisbrg: iv.namatipe.strip, kodeartikel: iv.kodeartikel, namaartikel: iv.article,
            kodekain: iv.kodekain.strip, namakain: iv.kain.strip, panjang: iv.panjang.to_i, lebar: iv.lebar.to_i, namabrand: iv.groupitem.strip,
            harganetto1: iv.total, harganetto2: iv.total, kota: iv.kota, tipecust: get_group_customer(iv.tipecust), 
            ketppb: "", tanggal_fetched: Date.today.to_date,
            salesman: iv.namasales, orty: iv.orty.strip, nopo: iv.kodesales, 
            fiscal_year: year,
            fiscal_month: month, week: julian_to_date(iv.tanggalinvoice).to_date.cweek,
              area_id: area, ketppb: iv.bp.strip, tanggal: julian_to_date(iv.tanggalinvoice),
              nofaktur: iv.nofaktur.to_i, lnid: iv.lineso, nosj: iv.linefaktur.to_i, alamatkirim: iv.doc,
              alamat_so: alamat_so, reference: iv.referen1, customerpo_so: iv.referen,
              diskon1: adj.nil? ? 0 : adj.diskon1,
              diskon2: adj.nil? ? 0 : adj.diskon2,
              diskon3: adj.nil? ? 0 : adj.diskon3,
              diskon4: adj.nil? ? 0 : adj.diskon4,
              diskon5: adj.nil? ? 0 : adj.diskon5,
              diskonsum: adj.nil? ? 0 : adj.diskon6,
              diskonrp: adj.nil? ? 0 : adj.diskon7,
              cashback: adj.nil? ? 0 : adj.diskon8,
              nupgrade: adj.nil? ? 0 : adj.diskon9)
          Warehouse::Invoice.create!(cabang_id: cabang, noso: iv.nofaktur.to_i, tanggalsj: julian_to_date(iv.tanggalinvoice),
            kodebrg: iv.kodebarang.strip, namabrg: fullnamabarang, kode_customer: iv.kodecustomer.to_i, customer: iv.customer, 
            jumlah: iv.jumlah.to_s.gsub(/0/,"").to_i, satuan: "PC",
            jenisbrgdisc: iv.brand.strip, kodejenis: iv.tipe.strip, jenisbrg: iv.namatipe.strip, kodeartikel: iv.kodeartikel, namaartikel: iv.article,
            kodekain: iv.kodekain.strip, namakain: iv.kain.strip, panjang: iv.panjang.to_i, lebar: iv.lebar.to_i, namabrand: iv.groupitem.strip,
            harganetto1: iv.total, harganetto2: iv.total, kota: iv.kota, tipecust: get_group_customer(iv.tipecust), 
            ketppb: "", tanggal_fetched: Date.today.to_date,
            salesman: iv.namasales, orty: iv.orty.strip, nopo: iv.kodesales, 
            fiscal_year: year,
            fiscal_month: month, week: julian_to_date(iv.tanggalinvoice).to_date.cweek,
              area_id: area, ketppb: iv.bp.strip, tanggal: julian_to_date(iv.tanggalinvoice),
              nofaktur: iv.nofaktur.to_i, lnid: iv.lineso, nosj: iv.linefaktur.to_i, alamatkirim: iv.doc,
              alamat_so: alamat_so, reference: iv.referen1, customerpo_so: iv.referen,
              diskon1: adj.nil? ? 0 : adj.diskon1,
              diskon2: adj.nil? ? 0 : adj.diskon2,
              diskon3: adj.nil? ? 0 : adj.diskon3,
              diskon4: adj.nil? ? 0 : adj.diskon4,
              diskon5: adj.nil? ? 0 : adj.diskon5,
              diskonsum: adj.nil? ? 0 : adj.diskon6,
              diskonrp: adj.nil? ? 0 : adj.diskon7,
              cashback: adj.nil? ? 0 : adj.diskon8,
              nupgrade: adj.nil? ? 0 : adj.diskon9)
      end
    end
  end
  
  def self.revise_credit_note
    invoices = find_by_sql("SELECT * FROM PRODDTA.F03B112 WHERE 
    RWUPMJ BETWEEN '#{date_to_julian(1.month.ago.to_date)}' AND '#{date_to_julian(Date.today.to_date)}' 
    AND REGEXP_LIKE(RWODCT,'RM')")
    invoices.each do |iv|
        check = SalesReport.find_by_sql("SELECT nofaktur, orty, lnid, 
        harganetto2 FROM dbmarketing.tblaporancabang 
        WHERE nofaktur = '#{iv.rwdoc.to_i}' 
        AND orty = '#{iv.rwodct.strip}' AND kode_customer = '#{iv.rwan8.to_i}'  
        AND lnid = '#{iv.rwsfx.to_i}'")
        if check.present?
          ActiveRecord::Base.connection.execute("UPDATE dbmarketing.tblaporancabang 
            SET harganetto2 = '#{iv.rwoag + iv.rwatad}' WHERE
            nofaktur = '#{iv.rwdoc.to_i}' 
            AND orty = '#{iv.rwodct.strip}' AND kode_customer = '#{iv.rwan8.to_i}'  
            AND lnid = '#{iv.rwsfx.to_i}'")
            
          ActiveRecord::Base.connection.execute("UPDATE warehouse.F03B11_INVOICES 
            SET harganetto2 = '#{iv.rwoag + iv.rwatad}' WHERE
            nofaktur = '#{iv.rwdoc.to_i}' 
            AND orty = '#{iv.rwodct.strip}' AND kode_customer = '#{iv.rwan8.to_i}'  
            AND lnid = '#{iv.rwsfx.to_i}'")
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
    elsif cabang == "01"
      1
    elsif cabang == "03"
      23
    elsif cabang == "23"
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
    elsif cabang == "25"
      25
    elsif cabang == "26"
      26
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
    elsif bu.include?('180120') || bu.include?("180110") #tasikmalaya
      "02"
    elsif bu.include?('1515') #new cikupa
      "23"
    elsif bu == "12171" || bu == "12172" || bu == "12171C" || bu == "12171D" || bu == "12171S" || bu == "18171" || bu == "18172" || bu == "18171C" || bu == "18171D" || bu == "18171S" || bu == "18172D" || bu == "18172" || bu == "18172K" #manado
      "26"
    end
  end
end
