class JdePbj < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F0006" #rp

  def self.order_managements
    pbj = find_by_sql("SELECT MAX(PF.TANGGAL) AS TANGGAL, MAX(PF.SDMCU) AS SDMCU,
        SUM(CASE WHEN PF.PBJ = 'PBJM' THEN TOTAL_QTY ELSE 0 END) AS TOTAL_PBJM,
        SUM(CASE WHEN PF.PBJ = 'PBJO' THEN TOTAL_QTY ELSE 0 END) AS TOTAL_PBJO,
        SUM(CASE WHEN PF.PBJ = 'PBJM' THEN TOTAL_AMOUNT ELSE 0 END) AS TOTAL_PBJM_AMOUNT,
        SUM(CASE WHEN PF.PBJ = 'PBJO' THEN TOTAL_AMOUNT ELSE 0 END) AS TOTAL_PBJO_AMOUNT,
        TRIM(PF.SDSHAN) AS SDSHAN, PF.DES, MAX(BP.MCRP04) AS KODE_BP, MAX(PF.BRAND) AS BRAND,
        MAX(BR.DRDL01) AS BRAND_DESC
      FROM (
        SELECT PBJ.SDMCU, MAX(SUBSTR(PBJ.SDVR01, 0, 4)) AS PBJ, TRIM(PBJ.SDSHAN) AS SDSHAN,
        MAX(ABM.ABALPH) AS DES, SUM(PBJ.SDUORG)/10000 AS TOTAL_QTY,
        SUM(PBJ.SDAEXP) AS TOTAL_AMOUNT, MAX(PBJ.SDTRDJ) AS TANGGAL, PBJ.SDSRP1 AS BRAND FROM (
        SELECT SDTRDJ, SDSRP1, SDSHAN, SDNXTR, SDAEXP, SDVR01, SDMCU, SDUORG FROM PRODDTA.F4211
            WHERE SDTRDJ BETWEEN '#{date_to_julian(Date.today)}' AND '#{date_to_julian(Date.today)}' AND SDSRP1 != 'K'
            AND SDLTTR != '980' AND SDDCTO IN ('SK', 'ST') AND SDPRP4 != 'RM'
            AND SDVR01 LIKE 'PBJ%'
            GROUP BY SDTRDJ, SDSRP1, SDSHAN, SDNXTR, SDAEXP, SDVR01, SDMCU, SDUORG
        ) PBJ 
        LEFT JOIN
        (
            SELECT * FROM PRODDTA.F0101 WHERE ABAT1 = 'O'
        ) ABM ON ABM.ABAN8 = PBJ.SDSHAN
        WHERE ABM.ABAT1 = 'O'
        GROUP BY PBJ.SDSRP1, PBJ.SDMCU, PBJ.SDSHAN, SUBSTR(PBJ.SDVR01, 0, 4), PBJ.SDNXTR, PBJ.SDSRP1
        ORDER BY SDSHAN
      ) PF
      LEFT JOIN
      (
        SELECT * FROM PRODDTA.F0006
      ) BP ON TRIM(BP.MCMCU) = TRIM(PF.SDSHAN)
      LEFT JOIN
      (
        SELECT * FROM PRODCTL.F0005 WHERE DRSY = '41' AND DRRT = 'S1'
      ) BR ON TRIM(BR.DRKY) = TRIM(PF.BRAND)
      GROUP BY PF.SDSHAN, PF.BRAND, PF.DES ORDER BY PF.SDSHAN")
    pbj.each do |p|
      unless p.kode_bp.strip == "00"
        SourcePbj.insert_into_table(p.tanggal, p.sdmcu, p.total_pbjm, p.total_pbjo, p.total_pbjm_amount, p.total_pbjo_amount,
	  p.sdshan, p.des, p.kode_bp, p.brand_desc)
      end
    end
  end

  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end
end

