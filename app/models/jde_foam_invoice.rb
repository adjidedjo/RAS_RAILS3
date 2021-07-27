class JdeFoamInvoice < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F03B11" #rp

  def self.import_sales_foam(date)
    kandang = find_by_sql("SELECT SA.RPLNID AS LINEFAKTUR, SA.RPDOC AS NOFAKTUR, SA.RPDCT AS ORTY, SA.RPSDOC AS NOSO, SA.RPSDCT AS DOC, SA.RPSFX AS LINESO, 
       SA.RPDIVJ AS TANGGALINVOICE, SA.RPU/100 AS JUMLAH, SA.RPAG AS TOTAL, 
       SA.RPMCU AS BP, SA.RPAN8 AS KODECUSTOMER, SA.RPALPH AS CUSTOMER, CM.ABAC02 AS TIPECUST, NVL(TRIM(CIT.ALCTY1), '-') AS KOTA, SM.SASLSM AS KODESALES, 
       CM1.ABALPH AS NAMASALES, SA.RPACR AS HARGAUSD,
       IM.IMITM AS SHORTITEM, SA.RPRMK AS KODEBARANG, IM.IMDSC1 AS DSC1, IM.IMDSC2 AS DSC2, NVL(BR.DRDL01, '-') AS BRAND, NVL(SBR.DRDL01, '-') AS SUBBRAND, 
       IM.IMSEG2 AS TIPE, NVL(JN.DRDL01, '-') AS NAMATIPE, IM.IMSEG3 AS DENSITYID, NVL(DE.DRDL01, '-') AS DENSITYDESC, 
       IM.IMSEG4 AS FEELID, NVL(FE.DRDL01, '-') AS FEELDESC, IM.IMSEG5 AS FITURID, NVL(FI.DRDL01, '-') AS FITURBUSA, 
       IM.IMSEG6 AS WARNAID, NVL(WB.DRDL01, '-') AS WARNADESC, IMSEG7 AS PANJANG, IMSEG8 AS LEBAR, IMSEG9 AS TEBAL,
       (CASE WHEN SA.RPDCT = 'RM' THEN SUBSTR(SA.RPRMR1, 1, 8) ELSE SA.RPRMR1 END) AS REFEREN1, SA.RPVR01 AS REFEREN,
       MC.MCDL01 AS BPDESC, CB.DRKY AS BRANCHID, CB.DRDL01 AS BRANCHDESC, CM.ABAC08 AS AREAID, AB.DRDL01 AS AREADESC FROM
       (
         SELECT * FROM PRODDTA.F03B11 WHERE RPUPMJ BETWEEN '#{date_to_julian(Date.yesterday.to_date)}' AND
         '#{date_to_julian(Date.today.to_date)}' 
         AND REGEXP_LIKE(rpdct,'RI|RO|RX')
         AND REGEXP_LIKE(RPMCU,'CL|CR')
       ) SA
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F4101
       ) IM ON TRIM(IM.IMLITM) = TRIM(SA.RPRMK)
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0006
       ) MC ON TRIM(MC.MCMCU) = TRIM(SA.RPMCU)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '00' AND DRRT = '04'
       ) CB ON TRIM(CB.DRKY) = TRIM(MC.MCRP04)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '41' AND DRRT = 'S1'
       ) BR ON TRIM(BR.DRKY) = TRIM(IM.IMSRP1)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '41' AND DRRT = 'S2'
       ) SBR ON TRIM(SBR.DRKY) = TRIM(IM.IMSRP2)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '56' AND DRRT = 'TI' 
       ) JN ON TRIM(JN.DRKY) = TRIM(IM.IMSEG2)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = '08'
       ) DE ON TRIM(DE.DRKY) = TRIM(IM.IMSEG3)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '56' AND DRRT = 'FB'
       ) FE ON TRIM(FE.DRKY) = TRIM(IM.IMSEG4)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '56' AND DRRT = 'FI'
       ) FI ON TRIM(FI.DRKY) = TRIM(IM.IMSEG5)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '56' AND DRRT = 'WB'
       ) WB ON TRIM(WB.DRKY) = TRIM(IM.IMSEG6)
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM ON TRIM(SA.RPAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '01' AND DRRT = '08'
       ) AB ON TRIM(AB.DRKY) = TRIM(CM.ABAC08)
       LEFT JOIN
       (
       SELECT ALAN8, MAX(ALCTY1) AS ALCTY1 FROM PRODDTA.F0116 GROUP BY ALAN8
       ) CIT ON TRIM(CIT.ALAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT SASLSM, SAIT44, SAAN8 FROM PRODDTA.F40344 WHERE SAIT44 = 'F' AND 
       SAEXDJ > (select 1000*(to_char(sysdate, 'yyyy')-1900)+to_char(sysdate, 'ddd') as julian from dual)
       ) SM ON SM.SAAN8 = SA.RPAN8
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM1 ON TRIM(SM.SASLSM) = TRIM(CM1.ABAN8)
       WHERE REGEXP_LIKE(IM.IMTMPL, 'WASTE_BUSA|BUSA|18 BARANG CETAKAN') AND CM.ABAC02 != '17'")
    kandang.each do |k|
      insert_to_warehouse(k)
    end
    import_credit_note(date)
    revise_credit_note(date)
    date = Date.today.day > 5 ? Date.today : 1.month.ago.to_date 
    BatchToMart.batch_transform_foam_datawarehouse(date.month, date.year)
    BatchToMart.batch_transform_whs_datawarehouse(date.month, date.year)
  end
  
  def self.insert_to_warehouse(iv)
    year = julian_to_date(iv.tanggalinvoice).to_date.year
    month = julian_to_date(iv.tanggalinvoice).to_date.month
    check = SalesWarehouse.find_by_sql("SELECT nofaktur, orty, lnid, harganetto2 FROM foam_datawarehouse.sales_warehouses 
      WHERE nofaktur = '#{iv.nofaktur.to_i}' 
      AND orty = '#{iv.orty.strip}' AND kode_customer = '#{iv.kodecustomer.to_i}'  
      AND nosj = '#{iv.linefaktur.to_i}' AND tanggalsj = '#{julian_to_date(iv.tanggalinvoice)}' AND
      kodebrg = '#{iv.kodebarang.strip}'")
      if check.empty?
        fullnamabarang = "#{iv.dsc1.strip} " "#{iv.dsc2.strip}"
        alamat_so = iv.orty == 'RI' ? (get_address_from_order(iv.noso, iv.doc).nil? ? '-' : get_address_from_order(iv.noso, iv.doc).address) : '-'
        adj = import_adjustment(iv.linefaktur.to_i, iv.noso.to_i, iv.doc) #find price_adjustment
        SalesWarehouse.create!(cabang_id: iv.branchid.strip, cabang_desc: iv.branchdesc.strip, noso: iv.nofaktur.to_i, tanggalsj: julian_to_date(iv.tanggalinvoice),
          kodebrg: iv.kodebarang.strip, namabrg: fullnamabarang, kode_customer: iv.kodecustomer.to_i, customer: iv.customer, 
          jumlah: iv.jumlah.to_s.gsub(/0/,"").to_i, satuan: "PC", brand: iv.brand.strip, subbrand: iv.subbrand.strip,
          tipeid: (iv.tipe.nil? ? '' : iv.tipe.strip), tipedesc: (iv.namatipe.nil? ? '' : iv.namatipe.strip), 
          densityid: (iv.densityid.nil? ? '' : iv.densityid.strip), densitydesc: (iv.densitydesc.nil? ? '' : iv.densitydesc.strip),
          feelid: (iv.feelid.nil? ? '' : iv.feelid.strip), feeldesc: (iv.feeldesc.nil? ? '' : iv.feeldesc.strip), 
          fiturid: iv.fiturid.strip, fiturdesc: (iv.fiturbusa.nil? ? '' : iv.fiturbusa.strip), warnaid: iv.warnaid.strip,
          warnadesc: (iv.warnadesc.nil? ? '' : iv.warnadesc.strip), panjang: iv.panjang.strip, lebar: iv.lebar.strip, tebal: iv.tebal.strip,
          harganetto1: iv.total, harganetto2: iv.total, kota: iv.kota, tipecust: get_group_customer(iv.tipecust), 
          ketppb: "", tanggal_fetched: Date.today.to_date, salesman: iv.namasales, orty: iv.orty.strip, 
          nopo: iv.kodesales, fiscal_year: year, fiscal_month: month, 
          week: julian_to_date(iv.tanggalinvoice).to_date.cweek, area_id: (iv.areaid.nil? ? 'A1' : iv.areaid.strip), 
          area_desc: (iv.areadesc.nil? ? 'AREA 1' : iv.areadesc.strip), ketppb: iv.bp.strip, 
          tanggal: julian_to_date(iv.tanggalinvoice), nofaktur: iv.nofaktur.to_i, 
          lnid: iv.lineso, nosj: iv.linefaktur.to_i, alamatkirim: iv.doc,
          alamat_so: '', reference: iv.referen1, customerpo_so: iv.referen,
          diskon1: adj.nil? ? 0 : adj.diskon1,
          diskon2: adj.nil? ? 0 : adj.diskon2,
          diskon3: adj.nil? ? 0 : adj.diskon3,
          diskon4: adj.nil? ? 0 : adj.diskon4,
          diskon5: adj.nil? ? 0 : adj.diskon5,
          diskonsum: adj.nil? ? 0 : adj.diskon6,
          diskonrp: adj.nil? ? 0 : adj.diskon7,
          cashback: adj.nil? ? 0 : adj.diskon8,
          nupgrade: adj.nil? ? 0 : adj.diskon9,
          hargausd: (iv.hargausd.to_f / 100))
      end
  end
  
  def self.get_delivery_number(so_pos)
    find_by_sql("SELECT SDDOC, SDDELN, MAX(SDVR01) AS SDVR01 FROM PRODDTA.F4211 
    WHERE SDVR01 LIKE '#{so_pos}%' AND SDDELN > 0 GROUP BY SDDELN, SDDOC")
  end
  
  def self.get_group_customer(grup)
    if grup.nil?
      '-'  
    elsif grup.strip == '15'
      'RETAIL FOAM'
    elsif grup.strip == '12'
      'MODERN'
    elsif grup.strip == '16'
      'DIRECT'
    elsif grup.strip == '14'
      'PROJECT'
    elsif grup.strip == '13'
      'ONLINE'
    elsif grup.strip == '11'
      'INDUSTRI'
    elsif grup.strip == '18'
      'PERUSAHAAN'
    elsif grup.strip == '20'
      'RETAIL FOAM'
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
  def self.import_credit_note(date)
    invoices = find_by_sql("SELECT SA.RPLNID AS LINEFAKTUR, SA.RPDOC AS NOFAKTUR, SA.RPDCT AS ORTY, SA.RPSDOC AS NOSO, SA.RPSDCT AS DOC, SA.RPSFX AS LINESO, 
       SA.RPDIVJ AS TANGGALINVOICE, SA.RPU/100 AS JUMLAH, SA.RPAG AS TOTAL, 
       SA.RPMCU AS BP, SA.RPAN8 AS KODECUSTOMER, SA.RPALPH AS CUSTOMER, CM.ABAC02 AS TIPECUST, NVL(TRIM(CIT.ALCTY1), '-') AS KOTA, SM.SASLSM AS KODESALES, 
       CM1.ABALPH AS NAMASALES, SA.RPACR AS HARGAUSD,
       IM.IMITM AS SHORTITEM, SA.RPRMK AS KODEBARANG, IM.IMDSC1 AS DSC1, IM.IMDSC2 AS DSC2, NVL(BR.DRDL01, '-') AS BRAND, NVL(SBR.DRDL01, '-') AS SUBBRAND, 
       IM.IMSEG2 AS TIPE, NVL(JN.DRDL01, '-') AS NAMATIPE, IM.IMSEG3 AS DENSITYID, NVL(DE.DRDL01, '-') AS DENSITYDESC, 
       IM.IMSEG4 AS FEELID, NVL(FE.DRDL01, '-') AS FEELDESC, IM.IMSEG5 AS FITURID, NVL(FI.DRDL01, '-') AS FITURBUSA, 
       IM.IMSEG6 AS WARNAID, NVL(WB.DRDL01, '-') AS WARNADESC, IMSEG7 AS PANJANG, IMSEG8 AS LEBAR, IMSEG9 AS TEBAL,
       (CASE WHEN SA.RPDCT = 'RM' THEN SUBSTR(SA.RPRMR1, 1, 8) ELSE SA.RPRMR1 END) AS REFEREN1, SA.RPVR01 AS REFEREN,
       MC.MCDL01 AS BPDESC, CB.DRKY AS BRANCHID, CB.DRDL01 AS BRANCHDESC, CM.ABAC08 AS AREAID, AB.DRDL01 AS AREADESC FROM
       (
         SELECT * FROM PRODDTA.F03B11 WHERE RPUPMJ BETWEEN '#{date_to_julian(Date.yesterday.to_date)}' AND
         '#{date_to_julian(Date.today.to_date)}' 
         AND REGEXP_LIKE(rpdct,'RM')
         AND REGEXP_LIKE(RPMCU,'CL|CR')
       ) SA
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F4101
       ) IM ON TRIM(IM.IMLITM) = TRIM(SA.RPRMK)
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0006
       ) MC ON TRIM(MC.MCMCU) = TRIM(SA.RPMCU)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '00' AND DRRT = '04'
       ) CB ON TRIM(CB.DRKY) = TRIM(MC.MCRP04)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '41' AND DRRT = 'S1'
       ) BR ON TRIM(BR.DRKY) = TRIM(IM.IMSRP1)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '41' AND DRRT = 'S2'
       ) SBR ON TRIM(SBR.DRKY) = TRIM(IM.IMSRP2)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '56' AND DRRT = 'TI' 
       ) JN ON TRIM(JN.DRKY) = TRIM(IM.IMSEG2)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = '08'
       ) DE ON TRIM(DE.DRKY) = TRIM(IM.IMSEG3)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '56' AND DRRT = 'FB'
       ) FE ON TRIM(FE.DRKY) = TRIM(IM.IMSEG4)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '56' AND DRRT = 'FI'
       ) FI ON TRIM(FI.DRKY) = TRIM(IM.IMSEG5)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '56' AND DRRT = 'WB'
       ) WB ON TRIM(WB.DRKY) = TRIM(IM.IMSEG6)
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM ON TRIM(SA.RPAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '01' AND DRRT = '08'
       ) AB ON TRIM(AB.DRKY) = TRIM(CM.ABAC08)
       LEFT JOIN
       (
       SELECT ALAN8, MAX(ALCTY1) AS ALCTY1 FROM PRODDTA.F0116 GROUP BY ALAN8
       ) CIT ON TRIM(CIT.ALAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT SASLSM, SAIT44, SAAN8 FROM PRODDTA.F40344 WHERE SAIT44 = 'F' AND 
       SAEXDJ > (select 1000*(to_char(sysdate, 'yyyy')-1900)+to_char(sysdate, 'ddd') as julian from dual)
       ) SM ON SM.SAAN8 = SA.RPAN8
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM1 ON TRIM(SM.SASLSM) = TRIM(CM1.ABAN8)
       WHERE REGEXP_LIKE(IM.IMTMPL, 'WASTE_BUSA|BUSA|18 BARANG CETAKAN') AND CM.ABAC02 != '17'")
    invoices.each do |iv|
      year = julian_to_date(iv.tanggalinvoice).to_date.year
      month = julian_to_date(iv.tanggalinvoice).to_date.month
        check = SalesReport.find_by_sql("SELECT nofaktur, orty, lnid, harganetto2 FROM foam_datawarehouse.sales_warehouses
        WHERE nofaktur = '#{iv.nofaktur.to_i}' 
        AND orty = '#{iv.orty.strip}' AND kode_customer = '#{iv.kodecustomer.to_i}'  
        AND lnid = '#{iv.lineso.to_i}' AND tanggalsj = '#{julian_to_date(iv.tanggalinvoice)}'")
        if check.present? && (check.first.harganetto2 != iv.total)
          ActiveRecord::Base.connection.execute("UPDATE dbmarketing.tblaporancabang SET harganetto2 = '#{iv.total}' WHERE
            nofaktur = '#{iv.nofaktur.to_i}' 
            AND orty = '#{iv.orty.strip}' AND kode_customer = '#{iv.kodecustomer.to_i}'  
            AND lnid = '#{iv.lineso.to_i}' AND fiscal_month = '#{month}' AND nofaktur = '#{iv.nofaktur.to_i}'")
        elsif check.empty?
          fullnamabarang = "#{iv.dsc1.strip} " "#{iv.dsc2.strip}"
          alamat_so = iv.orty == 'RI' ? (get_address_from_order(iv.noso, iv.doc).nil? ? '-' : get_address_from_order(iv.noso, iv.doc).address) : '-'
          adj = import_adjustment(iv.linefaktur.to_i, iv.noso.to_i, iv.doc) #find price_adjustment
          SalesWarehouse.create!(cabang_id: iv.branchid.strip, cabang_desc: iv.branchdesc.strip, noso: iv.nofaktur.to_i, tanggalsj: julian_to_date(iv.tanggalinvoice),
            kodebrg: iv.kodebarang.strip, namabrg: fullnamabarang, kode_customer: iv.kodecustomer.to_i, customer: iv.customer, 
            jumlah: iv.jumlah.to_s.gsub(/0/,"").to_i, satuan: "PC", brand: iv.brand.strip, subbrand: iv.subbrand.strip,
            tipeid: (iv.tipe.nil? ? '' : iv.tipe.strip), tipedesc: (iv.namatipe.nil? ? '' : iv.namatipe.strip), 
            densityid: (iv.densityid.nil? ? '' : iv.densityid.strip), densitydesc: (iv.densitydesc.nil? ? '' : iv.densitydesc.strip),
            feelid: (iv.feelid.nil? ? '' : iv.feelid.strip), feeldesc: (iv.feeldesc.nil? ? '' : iv.feeldesc.strip), 
            fiturid: iv.fiturid.strip, fiturdesc: (iv.fiturbusa.nil? ? '' : iv.fiturbusa.strip), warnaid: iv.warnaid.strip,
            warnadesc: (iv.warnadesc.nil? ? '' : iv.warnadesc.strip), panjang: iv.panjang.strip, lebar: iv.lebar.strip, tebal: iv.tebal.strip,
            harganetto1: iv.total, harganetto2: iv.total, kota: iv.kota, tipecust: get_group_customer(iv.tipecust), 
            ketppb: "", tanggal_fetched: Date.today.to_date, salesman: iv.namasales, orty: iv.orty.strip, 
            nopo: iv.kodesales, fiscal_year: year, fiscal_month: month, 
            week: julian_to_date(iv.tanggalinvoice).to_date.cweek, area_id: (iv.areaid.nil? ? 'A1' : iv.areaid.strip), 
            area_desc: (iv.areadesc.nil? ? 'AREA 1' : iv.areadesc.strip), ketppb: iv.bp.strip, 
            tanggal: julian_to_date(iv.tanggalinvoice), nofaktur: iv.nofaktur.to_i, 
            lnid: iv.lineso, nosj: iv.linefaktur.to_i, alamatkirim: iv.doc,
            alamat_so: '', reference: iv.referen1, customerpo_so: iv.referen,
            diskon1: adj.nil? ? 0 : adj.diskon1,
            diskon2: adj.nil? ? 0 : adj.diskon2,
            diskon3: adj.nil? ? 0 : adj.diskon3,
            diskon4: adj.nil? ? 0 : adj.diskon4,
            diskon5: adj.nil? ? 0 : adj.diskon5,
            diskonsum: adj.nil? ? 0 : adj.diskon6,
            diskonrp: adj.nil? ? 0 : adj.diskon7,
            cashback: adj.nil? ? 0 : adj.diskon8,
            nupgrade: adj.nil? ? 0 : adj.diskon9,
            hargausd: (iv.hargausd.to_f / 100))
        end
    end
  end

  def self.revise_credit_note(date)
    invoices = find_by_sql("SELECT * FROM PRODDTA.F03B112 WHERE 
    RWDIVJ = '#{date_to_julian(date.to_date)}' 
    AND REGEXP_LIKE(RWODCT,'RM')")
    invoices.each do |iv|
        check = SalesReport.find_by_sql("SELECT nofaktur, orty, lnid, 
        harganetto2 FROM foam_datawarehouse.sales_warehouses
        WHERE nofaktur = '#{iv.rwdoc.to_i}' 
        AND orty = '#{iv.rwodct.strip}' AND kode_customer = '#{iv.rwan8.to_i}'  
        AND lnid = '#{iv.rwsfx.to_i}'")
        if check.present?
          ActiveRecord::Base.connection.execute("UPDATE foam_datawarehouse.sales_warehouses
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
    end
  end
end
