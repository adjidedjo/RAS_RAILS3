class JdeSoHeader < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "PRODDTA.F4201"
  def self.get_order_today
    find_by_sql("
      SELECT MAX(cs.shdrqj) AS shdrqj, MAX(cs.shdcto) AS shdcto, MAX(cs.shdoco) AS shdoco, cs.shan8, MAX(dy.oamlnm) AS oamlnm, MAX(dy.oaadd1) AS oaadd1,
      MAX(dy.oaadd2) AS oaadd2, MAX(dy.oacty1) AS oacty1, MAX(cs.shdrqj) AS shdrqj, MAX(ad.aladd1) AS aladd1,
      MAX(ad.alcty1) AS alcty1 FROM
      PRODDTA.F4201 cs
      LEFT JOIN PRODDTA.F4006 dy ON cs.shdoco = dy.oadoco
      LEFT JOIN PRODDTA.F0116 ad ON cs.shan8 = ad.alan8
      LEFT JOIN PRODDTA.F0006 bp ON cs.shmcu = bp.mcmcu
      WHERE cs.shtrdj = '#{date_to_julian(Date.yesterday)}' AND cs.shdcto = 'SO' AND cs.shjobn LIKE '%JDE%'
      AND bp.mcdl01 NOT LIKE '%Foam%' AND NOT REGEXP_LIKE(cs.shmcu,'D|C') GROUP BY cs.shan8
    ")
  end

  def self.delete_outstanding
    JdeSoDetail.connection.execute("
        UPDATE PRODDTA.F4211 SET SDNXTR = '999', SDLTTR = '980', SDUORG = '0',
        SDSOQS = '0', SDSOBK = '0', SDSOCN = SDSQOR, SDCNDJ = '117305', SDRFRV = 'CBS'
        WHERE SDNXTR LIKE '561' AND REGEXP_LIKE(SDDCTO, 'WR')
        AND SDTRDJ < '117305'
      ")
  end

  def self.delete_outstanding_ppb_wr
    ou_540 = JdeSoDetail.find_by_sql("
          SELECT SDITM, SDMCU, SDDOCO, SDSOQS FROM PRODDTA.F4211
          WHERE SDNXTR LIKE '%561%' AND SDDCTO LIKE '%WR%'
          AND SDMCU LIKE '%11001' AND SDTRDJ < '117305'
        ")
    ou_540.each do |ou|
    # if ou.sdlotn != ' '
    # JdeSoDetail.connection.execute("
    # UPDATE PRODDTA.F41021 SET LIPCOM = LIPCOM - '#{ou.sdsoqs.to_i}'
    # WHERE LILOTN LIKE '#{ou.sdlotn.strip}%' AND LIMCU LIKE '%#{ou.sdmcu.strip}' AND LIITM LIKE '#{ou.sditm.to_i}'
    # ")
    # else
      JdeSoDetail.connection.execute("
            UPDATE PRODDTA.F41021 SET LIPCOM = LIPCOM - '#{ou.sdsoqs.to_i}'
            WHERE LIMCU LIKE '%#{ou.sdmcu.strip}' AND LIITM LIKE '#{ou.sditm.to_i}'
          ")
    end
  #end
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
