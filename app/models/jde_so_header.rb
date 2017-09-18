class JdeSoHeader < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4201"
  def self.get_order_today
    find_by_sql("
      SELECT MAX(cs.shdrqj) AS shdrqj, MAX(cs.shdcto) AS shdcto, MAX(cs.shdoco) AS shdoco, cs.shan8, MAX(dy.oamlnm) AS oamlnm, MAX(dy.oaadd1) AS oaadd1,
      MAX(dy.oaadd2) AS oaadd2, MAX(dy.oacty1) AS oacty1, MAX(cs.shdrqj) AS shdrqj, MAX(ad.aladd1) AS aladd1,
      MAX(ad.alcty1) AS alcty1 FROM
      PRODDTA.F4201 cs
      LEFT JOIN PRODDTA.F4006 dy ON cs.shdoco = dy.oadoco
      LEFT JOIN PRODDTA.F0116 ad ON cs.shan8 = ad.alan8
      LEFT JOIN PRODDTA.F0006 bp ON cs.shmcu = bp.mcmcu
      WHERE cs.shtrdj = '#{date_to_julian(Date.today)}' AND cs.shtday BETWEEN '#{1.hour.ago.change(min: 0).strftime('%k%M%S')}'
      AND '#{Time.now.change(min: 0).strftime('%k%M%S')}' AND cs.shdcto = 'SO' AND cs.shjobn LIKE '%JDE%'
      AND bp.mcdl01 NOT LIKE '%Foam%' GROUP BY cs.shan8
    ")
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
