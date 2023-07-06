class JdeForecast < ActiveRecord::Base
    establish_connection "jdeoracle"
    self.table_name = "PRODDTA.F03B11" #rp

    def self.forecast_data
        fore = find_by_sql("SELECT TO_CHAR(TO_DATE(TO_CHAR(SA.RPDIVJ+1900000),'YYYYDDD'), 'YYYY-MM-DD') AS INVOICEDATE,
            TO_CHAR(TO_DATE(TO_CHAR(SA.RPDIVJ+1900000),'YYYYDDD'), 'MM') AS FMONTH, 
            TO_CHAR(TO_DATE(TO_CHAR(SA.RPDIVJ+1900000),'YYYYDDD'), 'IW') AS FWEEK,
            TO_CHAR(TO_DATE(TO_CHAR(SA.RPDIVJ+1900000),'YYYYDDD'), 'YYYY') AS YEAR,
            MAX(SA.RPDOC) AS RPDOC, TRIM(SA.RPMCU) AS BRANCH, TRIM(MAX(BO.DRKY)) AS cabang_id, 
            SM.SASLSM AS KODESALES,MAX(TRIM(CM1.ABALPH)) AS NAMASALES, TRIM(MAX(CT.DRDL01)) AS TIPECUST, 
            IM.IMLITM AS ITEM_NUMBER,MAX(IM.IMSEG1) AS TIPE, MAX(IM.IMSEG2) AS ARTICLE, 
            MAX(NVL(IM.IMSEG3, '-')) AS KAIN, MAX(IM.IMSEG5) AS PANJANG, MAX(IM.IMSEG6) AS LEBAR,
            TRIM(MAX(BR.DRDL01)) AS GROUP_FORECAST, 
            SUM(SA.RPU/100) AS JUMLAH, MAX(TRIM(IM.IMDSC1)) AS DSC1, MAX(TRIM(IM.IMDSC2)) AS DSC2  FROM
            (
            SELECT * FROM PRODDTA.F03B11 WHERE RPDIVJ BETWEEN '#{date_to_julian(Date.yesterday.to_date)}' 
            AND '#{date_to_julian(Date.today.to_date)}' AND REGEXP_LIKE(rpdct,'RI|RO|RX')
            ) SA
            LEFT JOIN
            (
            SELECT IMLITM, IMPRGR, IMSEG1, IMSEG2, IMSEG3, IMSEG4, IMSEG5, IMSEG6, IMSRP3, IMDSC1, IMDSC2,
            NVL(CASE
            WHEN IMSRP1 = 'C' THEN 'S'
            WHEN IMSEG1 NOT IN ('KM', 'KB', 'SA', 'SB', 'ST', 'HB', 'DV', 'ET', 'LT') THEN 'A'
            END, IMSRP1) AS FOR_BRAND_GROUP, IMSRP1
            FROM PRODDTA.F4101 WHERE IMTMPL LIKE '%BJ MATRASS%'
            ) IM ON TRIM(IM.IMLITM) = TRIM(SA.RPRMK)
            LEFT JOIN
            (
            SELECT * FROM PRODDTA.F0006
            ) BU ON TRIM(SA.RPMCU) = TRIM(BU.MCMCU)
            LEFT JOIN
            (
            SELECT * FROM PRODCTL.F0005 WHERE DRSY = '41' AND DRRT = 'S1'
            ) BR ON TRIM(IM.FOR_BRAND_GROUP) = TRIM(BR.DRKY)
            LEFT JOIN
            (
            SELECT * FROM PRODCTL.F0005 WHERE DRSY = '00' AND DRRT = '04'
            ) BO ON TRIM(BU.MCRP04) = TRIM(BO.DRKY)
            LEFT JOIN
            (
            SELECT * FROM PRODDTA.F0101
            ) CM ON TRIM(SA.RPAN8) = TRIM(CM.ABAN8)
            LEFT JOIN
            (
            SELECT * FROM PRODCTL.F0005 WHERE DRSY = '01' AND DRRT = '02'
            ) CT ON TRIM(CM.ABAC02) = TRIM(CT.DRKY)
            LEFT JOIN
            (
            SELECT SASLSM, SAIT44, SAAN8, SAEFTJ, SAEXDJ FROM PRODDTA.F40344
            ) SM ON SM.SAAN8 = SA.RPAN8 AND SM.SAIT44 = IM.IMSRP1 AND (SA.RPDIVJ BETWEEN SM.SAEFTJ AND SM.SAEXDJ)
            LEFT JOIN
            (
            SELECT * FROM PRODDTA.F0101
            ) CM1 ON TRIM(SM.SASLSM) = TRIM(CM1.ABAN8)
            WHERE IM.IMPRGR IS NOT NULL AND SM.SASLSM IS NOT NULL
            AND SA.RPU = (CASE WHEN IM.IMSEG1 NOT IN ('KM', 'KB', 'SA', 'SB', 'ST', 'HB', 'DV') AND SA.RPAG = 0 THEN 0 ELSE SA.RPU END)
            GROUP BY SA.RPDIVJ, IM.IMLITM, SM.SASLSM, CM.ABAC02, SA.RPMCU")
        fore.each do |a|
            SourceForecast.insert_into_table(a.invoicedate.to_date, a.fmonth, a.fweek, a.year, a.cabang_id, a.rpdoc, a.branch,
                a.kodesales, a.namasales, a.tipecust, a.item_number, a.tipe, a.article, a.kain, a.panjang, 
                a.lebar, a.group_forecast, a.jumlah, a.dsc1, a.dsc2)
        end
    end

    def self.date_to_julian(date)
      1000*(date.year-1900)+date.yday
    end
end
