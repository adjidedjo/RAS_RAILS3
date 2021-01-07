class JdeFetch < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F4102" #sd
  
  def self.import_order_direct
    invoices = find_by_sql("SELECT MAX(SA.SDMCU) AS CABANG, SA.SDAN8 AS KODE, IM.IMPRGR AS BRAND, MAX(CM.ABALPH) AS CUSTOMER, MAX(CIT.ALCTY1) AS KOTA,
       SA.SDTRDJ AS TANGGALORDER, SUM(SA.SDPQOR) AS TOTALJUMLAH, SUM(SA.SDAEXP) AS TOTAL
       FROM
       (
         SELECT * FROM PRODDTA.F4211 WHERE SDTRDJ BETWEEN  '#{date_to_julian(Date.yesterday.to_date)}' AND
         '#{date_to_julian(Date.today.to_date)}'
         AND REGEXP_LIKE(SDDCTO,'SO|ZO') AND SDLTTR != '980'
       ) SA
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F4101
       ) IM ON TRIM(IM.IMLITM) = TRIM(SA.SDLITM)
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0006
       ) MC ON TRIM(MC.MCMCU) = TRIM(SA.SDMCU)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 FROM PRODCTL.F0005 WHERE DRSY = '00' AND DRRT = '04'
       ) CB ON TRIM(CB.DRKY) = TRIM(MC.MCRP04)
       LEFT JOIN
       (
       SELECT * FROM PRODDTA.F0101
       ) CM ON TRIM(SA.SDAN8) = TRIM(CM.ABAN8)
       LEFT JOIN
       (
       SELECT * FROM PRODCTL.F0005 WHERE DRSY = '01' AND DRRT = '08'
       ) AB ON TRIM(AB.DRKY) = TRIM(CM.ABAC08)
       LEFT JOIN
       (
       SELECT ALAN8, MAX(ALCTY1) AS ALCTY1 FROM PRODDTA.F0116 GROUP BY ALAN8
       ) CIT ON TRIM(CIT.ALAN8) = TRIM(CM.ABAN8)
       WHERE REGEXP_LIKE(CM.ABAC02, '16|') AND REGEXP_LIKE(IM.IMTMPL, 'BJ MATRASS') 
       GROUP BY SA.SDAN8, SA.SDTRDJ, IM.IMPRGR ORDER BY SA.SDAN8")
    invoices.each do |iv|
      year = julian_to_date(iv.tanggalorder).to_date.year
      month = julian_to_date(iv.tanggalorder).to_date.month
      week = julian_to_date(iv.tanggalorder).to_date.cweek
      day = julian_to_date(iv.tanggalorder).to_date.day
      cabang = JdeInvoice.jde_cabang(iv.cabang.to_i.to_s.strip)
      area = JdeInvoice.find_area(cabang)
      SalesMart.connection.execute("
        REPLACE INTO SH2CUSBRAND_ORDER (BRANCH, BRAND, CUSTOMER, CUSTOMER_DESC, CITY, FISCAL_DAY, FISCAL_WEEK, 
        FISCAL_MONTH, FISCAL_YEAR, SALES_QUANTITY, SALES_AMOUNT)
        VALUES ('#{area}','#{iv.brand}', '#{iv.kode}', '#{iv.customer}', '#{iv.kota}', #{day}, #{week}, #{month}, #{year}, 
        #{iv.totaljumlah/10000}, #{iv.total}) 
      ")
    end
  end
  
  def self.checking_buffer
    Stock.all.each do |stock|
      buffer_jde = self.find_by_sql("SELECT ibsafe FROM PRODDTA.F4102 WHERE 
      iblitm LIKE '%#{stock.item_number}%' AND ibmcu LIKE '%#{stock.branch}%'")
      unless buffer_jde.empty?
        if stock.buffer != (buffer_jde.first.ibsafe/10000)
          stock.update_attributes!(buffer: (buffer_jde.first.ibsafe/10000))
        end
      end
    end
  end
  
  def self.checking_item_cost
    Stock.all.each do |stock|
      item_cost_jde = self.find_by_sql("SELECT councs FROM PRODDTA.F4105 WHERE coledg LIKE '%07%' AND 
      colitm LIKE '%#{stock.item_number}%' AND comcu LIKE '%#{stock.branch}%'")
      unless item_cost_jde.empty?
        if stock.item_cost != (item_cost_jde.first.councs/10000)
          stock.update_attributes!(item_cost: (item_cost_jde.first.councs/10000))
        end
      end
    end
  end
  
  def self.update_salesman
    LaporanCabang.where("fiscal_month = 4 and fiscal_year = 2017 and cabang_id = 8").each do |lc|
      unless lc.jenisbrgdisc.nil?
      sales_id = JdeSalesman.find_salesman_id(lc.kode_customer, lc.jenisbrgdisc[0])
      sales = JdeSalesman.find_salesman(lc.kode_customer, lc.jenisbrgdisc[0])
      lc.update_attributes!(nopo: sales_id, salesman: sales)
      end
    end
  end
  
  def self.julian_to_date(jd_date)
    if jd_date.nil? || jd_date == 0
      0
    else
      Date.parse((jd_date+1900000).to_s, 'YYYYYDDD')
    end
  end
end